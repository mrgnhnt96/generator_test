import 'package:generator_test/src/generator_tests.dart';
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
  const Content(
    this.fileName, {
    required this.addPart,
  })  : type = PutType.input,
        _generators = const [];

  /// {@macro content}
  ///
  /// Formats the contents as a generated file
  const Content.output(
    this.fileName,
    this._generators,
  )   : type = PutType.output,
        addPart = true;

  /// The name of the file
  final String fileName;
  final List<Generator> _generators;

  /// If the content is input or output
  final PutType type;

  /// whether to add a part to the file
  final bool addPart;

  static String? _content;

  /// The contents of the file as a string
  String get content {
    if (type == PutType.output) {
      return _content ??=
          outputContentFromTypes(fileName, _generators.map((e) => '$e'));
    }

    return _content ??= inputContent(fileName, addPart: addPart);
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
