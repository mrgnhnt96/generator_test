// ignore_for_file: implementation_imports

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:generator_test/src/content.dart';
import 'package:logging/src/level.dart';
import 'package:logging/src/log_record.dart';
import 'package:logging/src/logger.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

/// provides the build options to return a builder
typedef GetBuilder = Builder Function(BuilderOptions options);

/// the method to be called during the build phase & the logger is used
typedef OnLog = void Function(LogRecord);

/// Prepares the generator and files for testing
class SuccessGenerator {
  /// prepares the generator and file for testing
  const SuccessGenerator(
    this.inputFiles,
    this.fixtureFiles,
    this.generator, {
    required this.partOfFile,
    this.compareWithFixture = true,
    this.inputDir = defaultInputDir,
    this.fixtureDir = defaultFixtureDir,
    OnLog? onLog,
    Level? logLevel,
  })  : _builder = null,
        _logger = onLog,
        _logLevel = logLevel,
        _extension = null,
        _options = null;

  /// uses the provided builder and files for testing
  SuccessGenerator.fromBuilder(
    this.inputFiles,
    this.fixtureFiles,
    GetBuilder builder, {
    this.partOfFile,
    Map<String, dynamic>? options,
    this.compareWithFixture = true,
    String? extension,
    this.inputDir = defaultInputDir,
    this.fixtureDir = defaultFixtureDir,
    OnLog? onLog,
    Level? logLevel,
  })  : generator = null,
        _logger = onLog,
        _logLevel = logLevel,
        _builder = builder,
        _options = options,
        _extension = extension;

  /// the default input file directory
  @visibleForTesting
  static const defaultInputDir = 'test/inputs';

  /// the default fixture file directory
  @visibleForTesting
  static const defaultFixtureDir = 'test/fixtures';

  /// the names of the files to test
  final List<String> inputFiles;

  /// the file to test
  final List<String> fixtureFiles;

  /// the file name to be used for `part of [partOfFile].[extension].dart`
  final String? partOfFile;

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

  /// Gets the content for the input and fixture files
  Content get content {
    return Content(
      inputs: inputFiles,
      fixtures: fixtureFiles,
      fixtureDir: fixtureDir,
      inputDir: inputDir,
      partOfFile: partOfFile,
      outputExtension: extension,
    );
  }

  /// tests the generator
  Future<void> test() async {
    if (_logLevel != null) {
      Logger.root.level = _logLevel;
    }

    await testBuilder(
      builder,
      content.input,
      outputs: compareWithFixture ? content.output : null,
      onLog: _logger ?? print,
    );
  }
}
