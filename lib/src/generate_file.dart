import 'dart:io';

import 'package:build_test/build_test.dart';
import 'package:generator_test/src/domain/generator_path.dart';
import 'package:source_gen/source_gen.dart';

/// Retrieves the file content from the [GeneratorPath.input]/[fileName].dart file.
///
/// [addPart] adds `part '[fileName].g.dart';' to the file after imports
String inputContent(
  String fileName, {
  bool addPart = false,
}) {
  final path = '${GeneratorPath.input}/$fileName.dart';

  String? part;

  if (addPart) {
    part = "part '$fileName.g.dart';";
  }

  final content = _getFileContent(path, part);

  return content;
}

/// Retrieves the file content from the [GeneratorPath.output]/[fileName].dart file.
///
/// Automatically adds
/// - `part of '[fileName].dart';`
/// - `// GENERATED CODE - DO NOT MODIFY BY HAND`
/// - Generator's name (`T`) comment
String outputContent<T extends Generator>(String fileName) {
  final path = '${GeneratorPath.output}/$fileName.dart';

  final output = _getFileContent(path);
  const generatedByHand = '// GENERATED CODE - DO NOT MODIFY BY HAND\n';

  final part = "part of '$fileName.dart';\n";

  final generator = '''
// **************************************************************************
// $T
// **************************************************************************''';

  return [generatedByHand, part, generator, output].join('\n');
}

String _getFileContent(String path, [String? part]) {
  final file = File(path);

  if (!file.existsSync()) {
    throw Exception('File not found: $path');
  }

  final content = file.readAsStringSync();

  final partRegex = RegExp("part .*';\n");

  if (content.contains(partRegex)) {
    return content.replaceFirst(RegExp("part .*';\n"), part ?? '');
  }

  if (!content.contains(RegExp('import .*;'))) {
    return [part ?? '', content].join('\n');
  }

  if (part == null) {
    return content;
  }

  final lines = content.split('\n');
  final indexAfterImport = lines.indexWhere(
    (line) =>
        !line.startsWith(RegExp(r'^(import|//|\s)', multiLine: true)) &&
        line.isNotEmpty,
  );

  lines.insertAll(indexAfterImport, [part, '']);

  return lines.join('\n');
}

/// Run test with code generated from [inputContent]
///
/// When [compareWithOutput] is `true`, the generated code is compared
/// with [outputContent]
///
/// When [compareWithOutput] is `false`, the test will pass if there
/// are no errors in the generated code.
Future<void> testPartGenerator<T extends Generator>(
  String fileName, {
  required T Function() generator,
  bool compareWithOutput = false,
}) async {
  final inputs = <String, String>{};
  final outputs = <String, String>{};
  final fileBase = 'a|lib/$fileName';

  // If the output is requested, then we need to add the "part" to the file
  final addPart = compareWithOutput;

  final content = inputContent(fileName, addPart: addPart);

  inputs['$fileBase.dart'] = content;

  if (compareWithOutput) {
    final output = outputContent<T>(fileName);

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
