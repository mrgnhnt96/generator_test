import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:generator_test/src/domain/domain.dart';
import 'package:source_gen/source_gen.dart';

/// Prepares the generator and files for testing
class GeneratorPrep {
  /// prepares the generator and file for testing
  GeneratorPrep(
    this.fileName,
    this.generator, {
    this.compareWithOutput = false,
  })  : _builder = null,
        extension = null,
        header = null;

  /// uses the provided builder and files for testing
  GeneratorPrep.fromBuilder(
    this.fileName,
    this._builder, {
    this.compareWithOutput = false,
    this.header,
    this.extension,
  }) : generator = null;

  /// the names of the files to test
  final String fileName;

  /// the generator to test
  final Generator? generator;

  final Builder? _builder;

  /// compares the input content with the generated output
  ///
  /// if false, the test will pass if the generated
  /// output contains no generated errors
  final bool compareWithOutput;

  /// the header to use for the generated output
  final String? header;

  /// the extension of the generated file
  final String? extension;

  /// the builder for the test
  Builder get builder {
    return _builder ?? PartBuilder([generator!], '.g.dart');
  }

  Content get _inContent {
    return Content(
      fileName,
      addPart: compareWithOutput,
    );
  }

  Content get _outContent {
    return Content.output(
      fileName,
      generator,
      header: header,
      extension: extension,
    );
  }

  /// the input files for the test
  Map<String, String> get inputs {
    return _puts(_inContent);
  }

  /// the output files for the test
  Map<String, String> get outputs {
    return compareWithOutput ? _puts(_outContent) : {};
  }

  Map<String, String> _puts(Content put) {
    return {put.filePath: put.content};
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

    return fileName.contains(file);
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
