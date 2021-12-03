import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:generator_test/src/domain/domain.dart';
import 'package:source_gen/source_gen.dart';

class GeneratorPrep {
  GeneratorPrep(
    this.fileNames,
    Generator generator, {
    this.compareWithOutput = false,
  }) : generators = [generator];

  GeneratorPrep.multi(
    this.fileNames,
    this.generators, {
    this.compareWithOutput = false,
  });

  final List<String> fileNames;
  final List<Generator> generators;
  final bool compareWithOutput;

  Builder get builder {
    return PartBuilder(generators, '.g.dart');
  }

  Iterable<Content> get _inContent {
    return fileNames.map((file) {
      return Content(file, addPart: compareWithOutput);
    });
  }

  Iterable<Content> get _outContent {
    return fileNames.map((file) {
      return Content.output(file, generators);
    });
  }

  Map<String, String> get inputs {
    return _puts(_inContent);
  }

  Map<String, String> get outputs {
    return compareWithOutput ? _puts(_outContent) : {};
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

  Future<MultiPackageAssetReader> get reader async {
    return _reader ??= await PackageAssetReader.currentIsolate();
  }

  bool isInput(String path) {
    final file = path.replaceAll(Content.lib, '');

    return fileNames.contains(file);
  }

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
