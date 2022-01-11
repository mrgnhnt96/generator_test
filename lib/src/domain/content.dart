import 'package:generator_test/src/util/util.dart';

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
    required this.directory,
    String? extension,
  })  : type = PutType.input,
        fromFileName = fileName,
        _extension = extension;

  /// {@macro content}
  ///
  /// Formats the contents as a generated file
  Content.fixture(
    this.fileName, {
    String? fromFileName,
    required this.directory,
    String? extension,
  })  : type = PutType.fixture,
        fromFileName = fromFileName ?? fileName,
        _extension = extension,
        addPart = true;

  /// The name of the file
  final String fileName;

  /// If the content is input or fixture
  final PutType type;

  /// whether to add a part to the file
  final bool addPart;

  final String? _extension;

  /// the directory of the file
  final String directory;

  /// the file to use as the source of the file
  final String fromFileName;

  String? _content;

  /// The contents of the file as a string
  String get content {
    if (type == PutType.fixture) {
      return _content ??= fixtureContent(
        fileName,
        fromFileName: fromFileName,
        dirPath: directory,
      );
    }

    return _content ??= inputContent(
      fromFileName,
      addPart: addPart,
      extension: extension(getfixture: true),
      dirPath: directory,
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

    final extRegex = RegExp(r'\.[\w]+\.dart');

    if (!extRegex.hasMatch(ext)) {
      throw Exception('Invalid extension: $ext');
    }

    return ext;
  }
}
