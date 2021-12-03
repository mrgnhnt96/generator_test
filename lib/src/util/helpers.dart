import 'dart:io';

import 'package:generator_test/src/domain/domain.dart';

/// Gets the output content from the given [fileName].
String outputContentFromTypes(String fileName, Iterable<String> type) {
  final path = '${GeneratorPath.output}/$fileName.dart';

  final output = getFileContent(path);
  const generatedByHand = '// GENERATED CODE - DO NOT MODIFY BY HAND\n';

  final part = "part of '$fileName.dart';\n";

  // TODO: look into how this looks with multiple generators
  final generator = '''
// **************************************************************************
// ${type.first}
// **************************************************************************''';

  return [generatedByHand, part, generator, output].join('\n');
}

/// gets the file's content from the given [path].
String getFileContent(String path, [String? part]) {
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
