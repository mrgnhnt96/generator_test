dryRun=$1
if [ ! -z "$dryRun"]; then
  echo "Dry run"
  dryRun=1
fi

function runtests() {
  if [ ! -d "test" ]; then
    return
  fi

  echo "\nRunning tests...\n"

  dart run test --coverage coverage -r expanded --test-randomize-ordering-seed random --timeout 60s

  format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib

  genhtml coverage/lcov.info -o coverage

  curl -Os https://uploader.codecov.io/latest/macos/codecov
  coverageKey=$(cat ../../.codecov_secret)
  ./codecov -t $coverageKey
}

function format() {
  echo "\n Formatting...\n"
  dart format lib --fix
  dart pub global run import_sorter:main --no-comments
}

function prepare() {
  dir=$1
  if [ -z "$dir" ]; then
    echo "Please specify a directory to prepare"
    exit 1
  fi

  echo "\nPreparing $dir package...\n"

  runtests
  format

  echo "Done preparing $dir package..."
}

function publish() {
  dir=$1
  if [ -z "$dir" ]; then
    echo "Please specify a directory to publish"
    exit 1
  fi

  echo "\n\n"

  if [ dryRun ]; then
    echo "[DRY RUN]"
  fi

  echo "Would you like to publish the $dir package? (y|n)"
  read publish

  if [ "$publish" != "y" ]; then
    echo "Skipping $dir package"
    return
  fi

  echo "\nPublishing $dir package...\n"

  path=$dir


  if [ dryRun ]; then
    echo "This is DRY RUN, not publishing"
    pub publish --dry-run -C $path
    echo "DRY RUN complete"
    return
  fi

  echo |
    !!! --- !!!
    Releasing to production...
    !!! --- !!!

  # pub publish -C $path
}

function run() {
  dir=$1
  if [ -z "$dir" ]; then
    echo "Please specify a directory to publish"
    exit 1
  fi

  echo "\nStarting $dir package...\n"
  prepare $dir

  publish $dir

  echo "Finished $dir package..."
}

run annotation