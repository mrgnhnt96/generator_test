import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

/// {@template content}
/// The contents of a local file
/// {@endtemplate}
class Content with GetContentMixin {
  /// {@macro content}
  Content({
    required List<String> inputs,
    required List<String> fixtures,
    required String fixtureDir,
    required String inputDir,
    this.partOfFile,
    required String? extension,
  })  : _extension = extension, //
        _input = inputs.map((file) => p.join(inputDir, file)).toList(),
        _fixtures = fixtures.map((file) => p.join(fixtureDir, file)).toList(),
        _output = fixtures.map((file) => p.join(inputDir, file)).toList();

  /// {@macro content}
  final List<String> _input;
  // the file to be used as source for the content
  final List<String> _fixtures;
  final List<String> _output;
  final String? _extension;

  /// The part directive that will be added to the generated file
  final String? partOfFile;

  /// The contents of the file as a string
  Map<String, String> get output {
    return {
      for (var i = 0; i < _output.length; i++)
        '$lib${_output[i]}': fixtureContent(
          output: _fixtures[i],
          partOfFile: partOfFile,
        ),
    };
  }

  /// whether the part file is shared with other generators
  bool get isSharedPartFile => _extension?.endsWith('.part') ?? false;

  /// The contents of the file as a string, mapped by [_input]
  Map<String, String> get input {
    return {
      for (final file in _input) '$lib$file': inputContent(file),
    };
  }

  /// The test path directory of the file
  ///
  /// `a|lib/`
  static const String lib = 'a|lib/';
}

/// Methods to get the contents of a file
mixin GetContentMixin {
  /// the file to be used as source for the content
  @visibleForTesting
  File? file;

  /// Retrieves the file content from the [path].dart file.
  String inputContent(String path) {
    final part = "part '${p.basename(path)}';";

    final content = getFileContent(path);

    if (p.extension(path) == '.dart') {
      return updatePart(content, part: part);
    }

    return content;
  }

  /// Retrieves the file content from the [partOfFile].dart file.
  ///
  /// Automatically adds
  /// - `part of '[fileName].dart';`
  /// - `// GENERATED CODE - DO NOT MODIFY BY HAND`
  /// - Generator's name (`T`) comment
  String fixtureContent({
    required String? partOfFile,
    required String output,
  }) {
    var content = getFileContent(output);

    if (partOfFile != null && p.extension(output) == '.dart') {
      content = updatePart(content, part: "part of '$partOfFile.dart';");
    }

    final generatedFixture = updateGenerated(content);

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
  String updatePart(String content, {String? part}) {
    // check if content already contains `part of '.*';` since we can only have
    // 1 part of

    if (content.contains(RegExp('part of .*;'))) {
      return content;
    }

    if (part == null) {
      throw Exception('part is null');
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
