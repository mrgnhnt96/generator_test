// ignore_for_file: implementation_imports

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:generator_test/src/content.dart';
import 'package:logging/src/level.dart';
import 'package:logging/src/log_record.dart';
import 'package:logging/src/logger.dart';
import 'package:source_gen/source_gen.dart';

/// provides the build options to return a builder
typedef GetBuilder = Builder Function(BuilderOptions options);

/// the method to be called during the build phase & the logger is used
typedef OnLog = void Function(LogRecord);

const _defaultInputDir = 'test/fixture';
const _defaultFixtureDir = 'test/fixture/fixtures';

/// Prepares the generator and files for testing
class SuccessGenerator {
  /// prepares the generator and file for testing
  SuccessGenerator(
    this.fileName,
    this.generator, {
    this.compareWithFixture = true,
    this.inputDir = _defaultInputDir,
    this.fixtureDir = _defaultFixtureDir,
    String? fixtureFileName,
    OnLog? onLog,
    Level? logLevel,
  })  : _builder = null,
        _logger = onLog,
        _logLevel = logLevel,
        fixtureFileName = fixtureFileName ?? fileName,
        _extension = null,
        _options = null;

  /// uses the provided builder and files for testing
  SuccessGenerator.fromBuilder(
    this.fileName,
    GetBuilder builder, {
    Map<String, dynamic>? options,
    this.compareWithFixture = true,
    String? extension,
    this.inputDir = _defaultInputDir,
    this.fixtureDir = _defaultFixtureDir,
    String? fixtureFileName,
    OnLog? onLog,
    Level? logLevel,
  })  : generator = null,
        _logger = onLog,
        _logLevel = logLevel,
        _builder = builder,
        _options = options,
        _extension = extension,
        fixtureFileName = fixtureFileName ?? fileName;

  /// the names of the files to test
  final String fileName;

  /// the generator to test
  final Generator? generator;

  /// compares the input content with the generated fixture
  ///
  /// if false, the test will pass if the generated
  /// fixture contains no generated errors
  final bool compareWithFixture;

  final OnLog? _logger;
  final Level? _logLevel;

  /// the extension of the generated file
  ///
  /// If null, the extension is pulled from the builder extension list\
  /// Throws error if `builder.buildExtensions` is empty or
  /// has more than one element
  String? get extension {
    if (_extension != null) {
      return _extension;
    }

    return builder.buildExtensions.values.single.first;
  }

  final String? _extension;

  /// the directory to use for the input files
  final String inputDir;

  /// the builder options used for the [builder]
  BuilderOptions get builderOptions {
    return BuilderOptions(_options ?? <String, dynamic>{});
  }

  final Map<String, dynamic>? _options;

  /// the directory to use for the generated fixture
  final String fixtureDir;

  /// the fixture file name. [fileName] is used if not set
  final String fixtureFileName;

  /// the builder for the test
  Builder get builder {
    if (_builder != null) {
      return _builder!(builderOptions);
    }

    return PartBuilder(
      [generator!],
      '.g.dart',
      options: builderOptions,
    );
  }

  final GetBuilder? _builder;

  /// the content from the input file
  Content get inputContent {
    return Content(
      fileName,
      extension: extension,
      directory: inputDir,
    );
  }

  /// the content from the fixture file
  Content? fixtureContent() {
    if (!compareWithFixture) {
      return null;
    }

    return Content.fixture(
      fileName,
      fromFileName: fixtureFileName,
      extension: extension,
      directory: fixtureDir,
    );
  }

  /// tests the generator
  Future<void> test() async {
    if (_logLevel != null) {
      Logger.root.level = _logLevel;
    }

    await testBuilder(
      builder,
      inputContent.contentWithPaths,
      outputs: fixtureContent()?.contentWithPaths,
      onLog: _logger ?? print,
      reader: await PackageAssetReader.currentIsolate(),
    );
  }
}
