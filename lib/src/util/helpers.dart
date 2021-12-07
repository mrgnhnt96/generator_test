// ignore_for_file: parameter_assignments

import 'dart:io';

import 'package:generator_test/src/domain/domain.dart';

/// Retrieves the file content from the [GeneratorPath.input]/[fileName].dart file.
///
/// [addPart] adds `part '[fileName].g.dart';' to the file after imports
String inputContent(
  String fileName, {
  bool addPart = false,
  required String extension,
}) {
  final path = '${GeneratorPath.input}/$fileName.dart';

  String? part;

  if (addPart) {
    part = "part '$fileName$extension';";
  }

  final content = getFileContent(
    path,
    part: part,
  );

  return content;
}

/// Retrieves the file content from the [GeneratorPath.output]/[fileName].dart file.
///
/// Automatically adds
/// - `part of '[fileName].dart';`
/// - `// GENERATED CODE - DO NOT MODIFY BY HAND`
/// - Generator's name (`T`) comment
String outputContent(
  String fileName,
  String? generatorName,
  String? header,
) {
  final path = '${GeneratorPath.output}/$fileName.dart';

  final output = getFileContent(path);
  final generatedHeader =
      header ?? '// GENERATED CODE - DO NOT MODIFY BY HAND\n';

  final part = "part of '$fileName.dart';\n";

  final generator = '''
// **************************************************************************
// $generatorName
// **************************************************************************
''';

  final result = [
    generatedHeader,
    part,
    if (generatorName != null) generator,
    output,
  ].join('\n');

  return result;
}

/// gets the file's content from the given [path].
String getFileContent(
  String path, {
  String? part,
}) {
  part = part == null ? '' : '$part\n\n';

  String getContent() {
    final file = File(path);

    if (!file.existsSync()) {
      throw Exception('File not found: $path');
    }

    final content = file.readAsStringSync();

    final partRegex = RegExp(r"part .*';[\r\n]+");

    if (content.contains(partRegex)) {
      return content.replaceFirst(partRegex, part ?? '');
    }

    if (!content.contains(RegExp('import .*;'))) {
      return [part ?? '', content].join();
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

    lines.insert(indexAfterImport, part);

    return lines.join('\n');
  }

  final result = getContent();

  return result;
}
