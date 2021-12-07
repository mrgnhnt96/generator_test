import 'package:generator_test/src/util/util.dart';
import 'package:source_gen/source_gen.dart';

/// Input/Output type for [Content] of the generator
enum PutType {
  /// content that is an input to the generator
  input,

  /// content that is an output from the generator
  output,
}

/// {@template content}
/// The contents of a local file
/// {@endtemplate}
class Content {
  /// {@macro content}
  Content(
    this.fileName, {
    required this.addPart,
    this.format = false,
  })  : type = PutType.input,
        _generators = const [];

  /// {@macro content}
  ///
  /// Formats the contents as a generated file
  Content.output(
    this.fileName,
    this._generators, {
    this.format = true,
  })  : type = PutType.output,
        addPart = true;

  /// The name of the file
  final String fileName;
  final List<Generator> _generators;

  /// If the content is input or output
  final PutType type;

  /// whether to add a part to the file
  final bool addPart;

  /// whether to format the content
  final bool format;

  String? _content;

  /// The contents of the file as a string
  String get content {
    if (type == PutType.output) {
      return _content ??= outputContentMultiGen(
        fileName,
        _generators.map((e) => '$e'),
        format: format,
      );
    }

    return _content ??= inputContent(
      fileName,
      addPart: addPart,
      format: format,
    );
  }

  /// The contents of the file as a string, mapped by [filePath]
  Map<String, String> get contentWithPaths {
    return {filePath: content};
  }

  /// The test path directory of the file
  ///
  /// `a|lib/`
  static const String lib = 'a|lib/';

  /// the test path of the file
  String get filePath => '$lib$fileName$extension';

  /// The extension of the file
  String get extension => type == PutType.output ? '.g.dart' : '.dart';
}
