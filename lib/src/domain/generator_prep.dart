import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:generator_test/src/domain/content.dart';
import 'package:generator_test/src/domain/generator_path.dart';
import 'package:source_gen/source_gen.dart';

/// Prepares the generator and files for testing
class GeneratorPrep {
  /// prepares the generator and file for testing
  GeneratorPrep(
    this.fileName,
    this.generator, {
    this.compareWithFixture = false,
    String? inputDir,
    String? fixtureDir,
    String? fixtureFileName,
  })  : _builder = null,
        fixtureFileName = fixtureFileName ?? fileName,
        _extension = null,
        inputDir = inputDir ?? GeneratorPath.input,
        fixtureDir = fixtureDir ?? GeneratorPath.fixture;

  /// uses the provided builder and files for testing
  GeneratorPrep.fromBuilder(
    this.fileName,
    this._builder, {
    this.compareWithFixture = false,
    String? extension,
    String? inputDir,
    String? fixtureDir,
    String? fixtureFileName,
  })  : generator = null,
        _extension = extension,
        fixtureFileName = fixtureFileName ?? fileName,
        inputDir = inputDir ?? GeneratorPath.input,
        fixtureDir = fixtureDir ?? GeneratorPath.fixture;

  /// the names of the files to test
  final String fileName;

  /// the generator to test
  final Generator? generator;

  final Builder? _builder;

  /// compares the input content with the generated fixture
  ///
  /// if false, the test will pass if the generated
  /// fixture contains no generated errors
  final bool compareWithFixture;

  /// the extension of the generated file
  ///
  /// If null, the extension is pulled from the builder extension list\
  /// Throws error if `builder.buildExtensions` is empty or
  /// has more than one element
  String? get extension =>
      _extension ?? builder.buildExtensions.values.single.first;
  final String? _extension;

  /// the directory to use for the input files
  final String inputDir;

  /// the directory to use for the generated fixture
  final String fixtureDir;

  /// the fixture file name. [fileName] is used if not set
  final String fixtureFileName;

  /// the builder for the test
  Builder get builder {
    return _builder ?? PartBuilder([generator!], '.g.dart');
  }

  Content get _inContent {
    return Content(
      fileName,
      addPart: compareWithFixture,
      extension: extension,
      directory: inputDir,
    );
  }

  Content get _fixtureContent {
    return Content.fixture(
      fileName,
      fromFileName: fixtureFileName,
      extension: extension,
      directory: fixtureDir,
    );
  }

  /// the input files for the test
  Map<String, String> get inputs {
    return _toMap(_inContent);
  }

  /// the fixture files for the test
  Map<String, String> get fixtures {
    return compareWithFixture ? _toMap(_fixtureContent) : {};
  }

  Map<String, String> _toMap(Content put) {
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
      outputs: fixtures,
      onLog: print,
      isInput: isInput,
      reader: await reader,
    );
  }
}
