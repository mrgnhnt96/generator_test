// ignore_for_file: parameter_assignments

import 'dart:io';

import 'package:generator_test/src/domain/domain.dart';

/// Retrieves the file content from the [GeneratorPath.input]/[fileName].dart file.
///
/// [addPart] adds `part '[fileName].g.dart';' to the file after imports
String inputContent(
  String fileName, {
  bool addPart = false,
  required String dirPath,
  required String extension,
}) {
  final path = '$dirPath/$fileName.dart';

  final part = "part '$fileName$extension';";

  final content = getFileContent(
    path,
    part: part,
    addPart: addPart,
  );

  return content;
}

/// Retrieves the file content from the [GeneratorPath.fixture]/[fileName].dart file.
///
/// Automatically adds
/// - `part of '[fileName].dart';`
/// - `// GENERATED CODE - DO NOT MODIFY BY HAND`
/// - Generator's name (`T`) comment
String fixtureContent(
  String fileName, {
  required String fromFileName,
  required String dirPath,
}) {
  final path = '$dirPath/$fromFileName.dart';

  final fixture = getFileContent(path, part: "part of '$fileName.dart';\n\n");

  return fixture;
}

/// gets the file's content from the given [path].
String getFileContent(
  String path, {
  required String part,
  bool addPart = true,
}) {
  String getContent() {
    final file = File(path);

    if (!file.existsSync()) {
      throw Exception('File not found: $path');
    }

    final content = file.readAsStringSync();

    if (!addPart) {
      return content;
    }

    final partRegex = RegExp(r"part .*';[\r\n]+");

    // check for part with specific extension
    if (content.contains(partRegex)) {
      return content.replaceFirst(partRegex, part);
    }

    if (!content.contains(RegExp('import .*;'))) {
      return [part, content].join();
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
