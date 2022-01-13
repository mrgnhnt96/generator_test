import 'dart:convert';
import 'dart:io';

import 'package:generator_test/src/content.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

extension on Content {
  String fakeFileContent({required bool forFixture}) {
    var part = '';

    if (forFixture) {
      part = "part of '$fileName.dart';";
    } else {
      part = "part '$fileName${extension(useFixturePart: true)}';";
    }

    return [part, '', _fakeFileContent].join('\n');
  }
}

void main() {
  Content getContent({
    String? fileName,
    bool? addPart,
    String? extension,
    bool isFixture = false,
  }) {
    if (isFixture) {
      return Content.fixture(
        fileName ?? 'fileName',
        directory: 'directory',
        extension: extension ?? '.dart',
      );
    }
    return Content(
      fileName ?? 'fileName',
      addPart: addPart ?? true,
      directory: 'directory',
      extension: extension ?? '.dart',
    );
  }

  group('$Content()', () {
    test('#type is input', () {
      expect(getContent().type, PutType.input);
    });

    test(
      'Content should return the file content from input file',
      () {
        final content = getContent()..file = FakeFile();

        final fileContent = content.fakeFileContent(forFixture: false);

        expect(content.content, fileContent);
      },
    );
  });

  group('$Content.fixture()', () {
    test('#type is fixture', () {
      expect(getContent(isFixture: true).type, PutType.fixture);
    });

    test(
      'Content.fixture should return the file content from fixture file',
      () {
        final content = getContent(isFixture: true)..file = FakeFile();

        final fileContent = content.fakeFileContent(forFixture: true);

        expect(content.content, fileContent);
      },
    );
  });

  group('#fileName', () {
    test('should return name provided', () {
      const name = 'harryPotter';

      final content = getContent(fileName: name);

      expect(content.fileName, name);
    });

    test('should strip extension', () {
      const name = 'harryPotter.dart';

      final content = getContent(fileName: name);

      expect(content.fileName, 'harryPotter');
    });

    test('should strip gen extension', () {
      const name = 'harryPotter.gen.dart';

      final content = getContent(fileName: name);

      expect(content.fileName, 'harryPotter');
    });
  });

  test('#contentWithPaths should map content to the file path', () {
    const name = 'harryPotter';
    final content = getContent(fileName: name)..file = FakeFile();

    final fileContent = content.fakeFileContent(forFixture: false);

    final contentWithPaths = content.contentWithPaths;

    expect(contentWithPaths.length, 1);
    expect(contentWithPaths.keys.first, 'a|lib/harryPotter.dart');
    expect(contentWithPaths.values.first, fileContent);
  });

  test('#lib should be default package and folder', () {
    expect(Content.lib, 'a|lib/');
  });

  group('#extension', () {
    test('when content is for input, should be only be dart extension', () {
      final content = getContent();

      expect(content.extension(), '.dart');
    });

    group('when content is for output', () {
      test('when provided extension is null, should be part extension', () {
        // ignore: avoid_redundant_argument_values
        final content = getContent(isFixture: true, extension: null);

        expect(content.extension(), '.g.dart');
      });

      test('when extension is only dart, should be part extension', () {
        final content = getContent(isFixture: true, extension: '.dart');

        expect(content.extension(), '.g.dart');
      });

      test(
        'when extension does not start with period, should prepend period',
        () {
          final content = getContent(isFixture: true, extension: 'g.dart');

          expect(content.extension(), '.g.dart');
        },
      );

      group('when extension is not formatted correctly, should throw exception',
          () {
        const badFormats = <String>[
          '.g.dart.dart',
          '.g.dar',
          '..g.dart',
          '.g-a.dart'
        ];

        for (final format in badFormats) {
          test(
            format,
            () {
              final content = getContent(isFixture: true, extension: format);

              expect(
                content.extension,
                throwsA(isA<Exception>()),
              );
            },
          );
        }
      });
    });
  });

  test(
    '#filePath should be formatted with package, file name and extension',
    () {
      const name = 'dobby';
      final content = getContent(fileName: name);

      expect(content.filePath, 'a|lib/dobby.dart');
    },
  );

  test('#toMap should map content by file path', () {
    const name = 'dobby';
    final content = getContent(fileName: name)..file = FakeFile();

    final contentMap = content.toMap();

    expect(contentMap.keys.first, 'a|lib/dobby.dart');
    expect(contentMap.values.first, content.content);
  });

  group('$GetContentMixin', () {
    late Content content;

    setUp(() {
      content = getContent()..file = FakeFile();
    });

    String input({
      required bool addPart,
      String? extension,
    }) {
      return content.inputContent(
        content.fileName,
        addPart: addPart,
        dirPath: content.directory,
        extension: extension ?? content.extension(),
      );
    }

    String fixture({
      String? fileName,
    }) {
      return content.fixtureContent(
        fileName ?? content.fileName,
        fromFileName: content.fromFileName,
        dirPath: content.directory,
      );
    }

    group('#inputContent', () {
      test('should not add part when set to false', () {
        final inputContent = input(addPart: false);

        expect(inputContent, isNot(contains('part')));
      });

      test('should add part when set to true', () {
        final inputContent = input(addPart: true);

        expect(inputContent, contains('part'));
      });
    });

    test(
      '#inputContent should retrieve file content '
      'and update part with extension',
      () {
        const extension = '.HP.dart';
        final inputContent = input(addPart: true, extension: extension);

        expect(inputContent, contains(extension));
      },
    );

    test(
      '#fixtureContent should retrieve file content '
      'and update part with fileName',
      () {
        const name = 'professor_snape';
        final fixtureContent = fixture(fileName: name);

        expect(fixtureContent, contains(name));
      },
    );

    group('#updatePart', () {
      test('should replace the part with provided', () {
        const fakePart = "part of 'fakeFileContent.dart';";
        const part = 'expeliomus.mag.dart';

        final result = content.updatePart(fakePart, part);

        expect(result, contains(part));
      });

      test('should prepend the part with provided', () {
        const fakeContent = '// fake file content';
        const part = 'vol.de.dart';

        final result = content.updatePart(fakeContent, part);

        expect(result, startsWith(part));
      });

      test('should add the part with provided after imports', () {
        const fakeContents = [
          "import 'package:ministy/magic.dart';",
          '''
import 'package:ministy/magic.dart';

import 'package:ministy/magic.dart';
''',
          '''
import 'package:ministy/magic.dart';
// some comment
import 'package:ministy/magic.dart';
''',
          '''
import 'package:ministy/magic.dart';

// some comment
import 'package:ministy/magic.dart';
''',
          '''
import 'package:ministy/magic.dart';

// some comment
import 'package:ministy/magic.dart';

class DartCode {}
''',
        ];
        const part = 'cornelius.fudge.dart';

        for (final fakeContent in fakeContents) {
          final result = content.updatePart(fakeContent, part);

          expect(result, contains(part));
        }
      });
    });
  });
}

class FakeFile extends Fake implements File {
  @override
  bool existsSync() => true;

  @override
  String readAsStringSync({Encoding encoding = utf8}) => _fakeFileContent;
}

const _fakeFileContent = '''
class Test {
  String test() {
    return 'test';
  }
}''';
