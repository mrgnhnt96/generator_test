import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:generator_test/src/domain/domain.dart';
import 'package:source_gen/source_gen.dart';

/// Prepares the generators and files for testing
class GeneratorPrep {
  /// prepares the generator and file for testing
  GeneratorPrep(
    this.fileNames,
    Generator generator, {
    TestConfig? config,
  })  : generators = [generator],
        config = config ?? const TestConfig(),
        _builder = null;

  /// prepares the generators and files for testing
  GeneratorPrep.multi(
    this.fileNames,
    this.generators, {
    TestConfig? config,
  })  : _builder = null,
        config = config ?? const TestConfig();

  /// uses the provided builder and files for testing
  GeneratorPrep.fromBuilder(
    this.fileNames,
    this._builder, {
    TestConfig? config,
  })  : generators = [],
        config = config ?? const TestConfig();

  /// the names of the files to test
  final List<String> fileNames;

  /// the generators to test
  final List<Generator> generators;

  final Builder? _builder;

  /// the options to use for testing
  final TestConfig config;

  /// the builder for the test
  Builder get builder {
    return _builder ?? PartBuilder(generators, '.g.dart');
  }

  Iterable<Content> get _inContent {
    return fileNames.map((file) {
      return Content(
        file,
        addPart: config.compareWithOutput,
        format: config.formatInput,
      );
    });
  }

  Iterable<Content> get _outContent {
    return fileNames.map((file) {
      return Content.output(
        file,
        generators,
        format: config.formatOutput,
      );
    });
  }

  /// the input files for the test
  Map<String, String> get inputs {
    return _puts(_inContent);
  }

  /// the output files for the test
  Map<String, String> get outputs {
    return config.compareWithOutput ? _puts(_outContent) : {};
  }

  Map<String, String> _puts(Iterable<Content> items) {
    final result =
        items.fold<Map<String, String>>({}, (previousValue, content) {
      previousValue[content.filePath] = content.content;

      return previousValue;
    });

    return result;
  }

  MultiPackageAssetReader? _reader;

  /// the asset reader for the test
  Future<MultiPackageAssetReader> get reader async {
    return _reader ??= await PackageAssetReader.currentIsolate();
  }

  /// checks if the path is a provided input file
  bool isInput(String path) {
    if (!path.contains('.dart')) {
      return false;
    }

    final extStart = path.indexOf('.');
    if (extStart == -1) {
      return false;
    }

    final file = path.substring(0, extStart).replaceAll(Content.lib, '');

    return fileNames.contains(file);
  }

  /// tests the generator
  Future<void> test() async {
    await testBuilder(
      builder,
      inputs,
      outputs: outputs,
      onLog: print,
      isInput: isInput,
      reader: await reader,
    );
  }
}