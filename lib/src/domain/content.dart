import 'package:generator_test/src/util/util.dart';
import 'package:source_gen/source_gen.dart';

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
class Content {
  /// {@macro content}
  Content(
    this.fileName, {
    required this.addPart,
    String? extension,
  })  : type = PutType.input,
        header = null,
        _extension = extension ?? '.dart',
        _generator = null;

  /// {@macro content}
  ///
  /// Formats the contents as a generated file
  Content.fixture(
    this.fileName,
    this._generator, {
    this.header,
    String? extension,
  })  : type = PutType.fixture,
        _extension = extension ?? '.g.dart',
        addPart = true;

  /// The name of the file
  final String fileName;
  final Generator? _generator;

  /// If the content is input or fixture
  final PutType type;

  /// whether to add a part to the file
  final bool addPart;

  /// the header of the fixture file
  final String? header;
  final String _extension;

  String? _content;

  /// The contents of the file as a string
  String get content {
    if (type == PutType.fixture) {
      return _content ??= fixtureContent(
        fileName,
        _generator?.toString(),
        header,
      );
    }

    return _content ??= inputContent(
      fileName,
      addPart: addPart,
      extension: extension(getfixture: true),
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
  String get filePath => '$lib$fileName${extension()}';

  /// The extension of the file
  String extension({bool getfixture = false}) {
    if (type == PutType.input && !getfixture) {
      return '.dart';
    }

    var ext = _extension;

    if (ext == '.dart') {
      return '.g$ext';
    }

    if (!ext.startsWith('.')) {
      ext = '.$ext';
    }

    if (!ext.endsWith('.dart')) {
      ext = '$ext.dart';
    }

    final extRegex = RegExp(r'\.[\w]+\.dart');

    if (!extRegex.hasMatch(ext)) {
      throw Exception('Invalid extension: $ext');
    }

    return ext;
  }
}
