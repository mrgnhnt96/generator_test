import 'dart:io';

import 'package:meta/meta.dart';

/// Input/fixture type for [Content] of the generator
enum PutType {
  /// content that is an input to the generator
  input,

  /// content that is an fixture from the generator
  fixture,
}

/// {@template content}
/// The contents of a local file
/// {@endtemplate}
class Content with GetContentMixin {
  /// {@macro content}
  Content(
    String fileName, {
    required this.directory,
    String? extension,
  })  : type = PutType.input,
        fromFileName = fileName,
        _fileName = fileName,
        _extension = extension;

  /// {@macro content}
  ///
  /// Formats the contents as a generated file
  Content.fixture(
    String fileName, {
    String? fromFileName,
    required this.directory,
    String? extension,
  })  : type = PutType.fixture,
        fromFileName = fromFileName ?? fileName,
        _fileName = fileName,
        _extension = extension;

  final String _fileName;

  /// The name of the file
  String get fileName {
    final name = _fileName;

    if (name.contains('.')) {
      return name.split('.').first;
    }

    return name;
  }

  /// If the content is input or fixture
  final PutType type;

  final String? _extension;

  /// the directory of the file
  final String directory;

  /// the file to use as the source of the file
  final String fromFileName;

  /// The contents of the file as a string
  String get content {
    if (type == PutType.fixture) {
      return fixtureContent(
        fileName,
        fromFileName: fromFileName,
        dirPath: directory,
        isSharedPart: isSharedPartFile,
      );
    }

    return inputContent(
      fromFileName,
      extension: extension(useFixturePart: true),
      dirPath: directory,
    );
  }

  /// whether the part file is shared with other generators
  bool get isSharedPartFile => _extension?.endsWith('.part') ?? false;

  /// The contents of the file as a string, mapped by [filePath]
  Map<String, String> get contentWithPaths {
    return {filePath: content};
  }

  /// The test path directory of the file
  ///
  /// `a|lib/`
  static const String lib = 'a|lib/';

  /// the test path of the file
  String get filePath => '$lib$fileName${extension()}';

  /// The extension of the file
  ///
  /// returns null when the file is a shared part
  String extension({bool useFixturePart = false}) {
    if (type == PutType.input && !useFixturePart) {
      return '.dart';
    }

    var ext = _extension;

    if (isSharedPartFile) {
      return ext!;
    }

    if (ext == null) {
      return '.g.dart';
    }

    if (ext == '.dart') {
      return '.g$ext';
    }

    if (!ext.startsWith('.')) {
      ext = '.$ext';
    }

    if (!ext.endsWith('.dart')) {
      ext = '$ext.dart';
    }

    final extRegex = RegExp(r'^\.[\w]+\.dart$');

    if (!extRegex.hasMatch(ext)) {
      throw Exception('Invalid extension: $ext');
    }

    return ext;
  }
}

/// Methods to get the contents of a file
mixin GetContentMixin {
  /// the file to be used as source for the content
  @visibleForTesting
  File? file;

  /// Retrieves the file content from the [dirPath]/[fileName].dart file.
  String inputContent(
    String fileName, {
    required String dirPath,
    required String extension,
  }) {
    final path = '$dirPath/$fileName.dart';

    final part = "part '$fileName$extension';";

    final content = getFileContent(path);

    final input = updatePart(content, part: part);

    return input;
  }

  /// Retrieves the file content from the [dirPath]/[fileName].dart file.
  ///
  /// Automatically adds
  /// - `part of '[fileName].dart';`
  /// - `// GENERATED CODE - DO NOT MODIFY BY HAND`
  /// - Generator's name (`T`) comment
  String fixtureContent(
    String fileName, {
    required String fromFileName,
    required String dirPath,
    required bool isSharedPart,
  }) {
    final path = '$dirPath/$fromFileName.dart';

    final content = getFileContent(path);

    final fixture = updatePart(
      content,
      part: "part of '$fileName.dart';",
      removePart: isSharedPart,
    );

    final generatedFixture = updateGenerated(fixture);

    return generatedFixture;
  }

  /// gets the file's content from the given [path].
  String getFileContent(String path) {
    final file = this.file ?? File(path);

    if (!file.existsSync()) {
      throw Exception('File not found: $path');
    }

    final content = file.readAsStringSync();

    return content;
  }

  /// Adds or updates the [part] to the [content]
  String updatePart(String content, {String? part, bool removePart = false}) {
    final partRegex = RegExp("^part .*';", multiLine: true);

    if (removePart) {
      return content
          .replaceFirst(partRegex, '')
          .replaceFirst(RegExp(r'^\s+'), '')
          .replaceFirst('\n\n\n', '\n');
    }

    assert(part != null, 'Part cannot be null');
    part!;

    // check for part with specific extension
    if (content.contains(partRegex)) {
      return content.replaceFirst(partRegex, part);
    }

    if (!content.contains(RegExp('import .*;'))) {
      return [part, '\n\n', content].join();
    }

    final lines = content.split('\n');
    var indexAfterImport = lines.indexWhere(
      (line) => !line.startsWith(RegExp(r'^(import|//|\s)')) && line.isNotEmpty,
    );

    if (indexAfterImport == -1) {
      indexAfterImport = lines.length;
    }

    lines.insert(indexAfterImport, '$part\n');

    return lines.join('\n');
  }

  /// Adds the generator name comment to the content
  String updateGenerated(String content) {
    final match = RegExp(r'\/\/ @generator=((\w|\$)+)');

    if (!content.contains(match)) {
      return content;
    }

    final line = '*' * 77;
    String header(String name) => '''
// $line
// $name
// $line
''';

    final results = match.allMatches(content);

    for (final result in results) {
      final generatorName = result.group(1);
      if (generatorName == null) {
        continue;
      }

      // ignore: parameter_assignments
      content = content.replaceAll(
        match,
        header(generatorName),
      );
    }

    return content;
  }
}
