import 'dart:io';

import 'package:build_test/build_test.dart';
import 'package:generator_test/src/domain/generator_path.dart';
import 'package:source_gen/source_gen.dart';

/// Retrieves the file content from the [GeneratorPath.input]/[fileName].dart file.
///
/// [addPart] adds `part '[fileName].g.dart';' to the file after imports
Future<String> inputContent(
  String fileName, {
  bool addPart = false,
}) async {
  final path = '${GeneratorPath.input}/$fileName.dart';

  String? part;

  if (addPart) {
    part = "part '$fileName.g.dart';";
  }

  final content = await _getFileContent(path, part);

  return content;
}

/// Retrieves the file content from the [GeneratorPath.output]/[fileName].dart file.
///
/// Automatically adds
/// - `part of '[fileName].dart';`
/// - `// GENERATED CODE - DO NOT MODIFY BY HAND`
/// - Generator's name (`T`) comment
Future<String> outputContent<T extends Generator>(String fileName) async {
  final path = '${GeneratorPath.output}/$fileName.dart';

  final output = await _getFileContent(path);
  const generatedByHand = '// GENERATED CODE - DO NOT MODIFY BY HAND\n';

  final part = "part of '$fileName.dart';\n";

  final generator = '''
// **************************************************************************
// $T
// **************************************************************************''';

  return [generatedByHand, part, generator, output].join('\n');
}

Future<String> _getFileContent(String path, [String? part]) async {
  final file = File(path);
  late String content;

  try {
    content = await file.readAsString();
  } catch (e) {
    throw Exception('File not found: $path');
  }

  final partRegex = RegExp("part .*';\n");

  if (content.contains(partRegex)) {
    return content.replaceFirst(RegExp("part .*';\n"), part ?? '');
  }

  return content;
}

/// Run test with code generated from [inputContent]
///
/// When [compareWithOutput] is `true`, the generated code is compared
/// with [outputContent]
///
/// When [compareWithOutput] is `false`, the test will pass if there
/// are no errors in the generated code.
void testGenerator<T extends Generator>(
  String fileName, {
  required T Function() generator,
  bool compareWithOutput = false,
}) =>
    _testGenerator(
      fileName,
      generator,
      compareWithOutput: compareWithOutput,
    );

Future<void> _testGenerator<T extends Generator>(
  String fileName,
  T Function() generator, {
  bool compareWithOutput = false,
}) async {
  final inputs = <String, String>{};
  final outputs = <String, String>{};
  final fileBase = 'a|lib/$fileName';

  // If the output is requested, then we need to add the "part" to the file
  final addPart = compareWithOutput;

  final content = await inputContent(fileName, addPart: addPart);

  inputs['$fileBase.dart'] = content;

  if (compareWithOutput) {
    final output = await outputContent<T>(fileName);

    outputs['$fileBase.g.dart'] = output;
  }

  final builder = PartBuilder([generator()], '.g.dart');

  await testBuilder(
    builder,
    inputs,
    outputs: outputs,
    onLog: print,
    isInput: (String input) => input.contains(fileBase),
    reader: await PackageAssetReader.currentIsolate(),
  );
}
