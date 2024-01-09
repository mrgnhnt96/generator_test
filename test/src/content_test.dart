import 'dart:convert';
import 'dart:io';

import 'package:generator_test/src/content.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

extension on Content {
  String fakeFileContent({required bool forFixture}) {
    var part = '';

    if (forFixture) {
      part = "part of '$partOfFile.dart';";
    } else {
      part = "part '$partOfFile';";
    }

    return [part, '', _fakeFileContent].join('\n');
  }
}

void main() {
  Content getContent({
    String? fileName,
    String? extension,
  }) {
    final file = fileName ?? 'fileName.dart';
    return Content(
      inputs: [file],
      fixtures: [file],
      fixtureDir: '',
      inputDir: '',
      partOfFile: file,
      extension: extension ?? '.dart',
    );
  }

  group('$Content()', () {
    test(
      'should return the file content from input file',
      () {
        final content = getContent()..file = FakeFile();

        final fileContent = content.fakeFileContent(forFixture: false);

        expect(content.input.values.first, fileContent);
      },
    );
  });

  group('$Content.fixture()', () {
    test(
      'Content.fixture should return the file content from fixture file',
      () {
        final content = getContent()..file = FakeFile();

        final fileContent = content.fakeFileContent(forFixture: true);

        expect(content.output.values.first, fileContent);
      },
    );
  });

  group('#fileName', () {
    test('should return name provided', () {
      const name = 'harryPotter.dart';

      final content = getContent(fileName: name)..file = FakeFile();

      expect(content.input.keys.first, endsWith(name));
    });
  });

  test('#contentWithPaths should map content to the file path', () {
    const name = 'harryPotter.dart';
    final content = getContent(fileName: name)..file = FakeFile();

    final fileContent = content.fakeFileContent(forFixture: false);

    final contentWithPaths = content.input;

    expect(contentWithPaths.length, 1);
    expect(contentWithPaths.keys.first, 'a|lib/harryPotter.dart');
    expect(contentWithPaths.values.first, fileContent);
  });

  test('#lib should be default package and folder', () {
    expect(Content.lib, 'a|lib/');
  });

  test(
    '#filePath should be formatted with package, file name and extension',
    () {
      const name = 'dobby.dart';
      final content = getContent(fileName: name)..file = FakeFile();

      expect(content.input.keys.first, 'a|lib/dobby.dart');
    },
  );

  group('$GetContentMixin', () {
    late Content content;

    setUp(() {
      content = getContent()..file = FakeFile();
    });

    group('#updatePart', () {
      test('should add the part with provided', () {
        const fakeFileName = 'fakeFileContent.dart';
        const fakeContents = [
          '''
import 'package:ministry/magic.dart';

''',
          '''
// some comment

''',
          '''
import 'package:ministry/magic.dart';

import 'package:ministry/magic.dart';

''',
          '''
import 'package:ministry/magic.dart';
// some comment
import 'package:ministry/magic.dart';

''',
          '''
import 'package:ministry/magic.dart';

// some comment
import 'package:ministry/magic.dart';

''',
          '''
import 'package:ministry/magic.dart';

// some comment
import 'package:ministry/magic.dart';

class DartCode {}
''',
        ];

        const part = "part 'vol.de.dart';";

        for (final fakeContent in fakeContents) {
          final result = content.updatePart(fakeContent, part: part);

          expect(result, contains(part));
          expect(result, isNot(contains(fakeFileName)));
        }
      });

      test('should prepend the part with provided', () {
        const fakeContent = '// fake file content';

        const parts = [
          "part 'vol.de.dart';",
          "part of 'vol.de.dart';",
          "part './you/know/who.dart';",
          "part of '../he/who/should/not/be.named.dart';",
        ];

        for (final part in parts) {
          final result = content.updatePart(fakeContent, part: part);

          expect(result, startsWith(part));
        }
      });

      test('should add the part with provided after imports', () {
        const fakeContents = [
          "import 'package:ministry/magic.dart';",
          '// some comment',
          '''
import 'package:ministry/magic.dart';

import 'package:ministry/magic.dart';
''',
          '''
import 'package:ministry/magic.dart';
// some comment
import 'package:ministry/magic.dart';
''',
          '''
import 'package:ministry/magic.dart';

// some comment
import 'package:ministry/magic.dart';
''',
          '''
import 'package:ministry/magic.dart';

// some comment
import 'package:ministry/magic.dart';

class DartCode {}
''',
        ];
        const part = 'cornelius.fudge.dart';

        for (final fakeContent in fakeContents) {
          final result = content.updatePart(fakeContent, part: part);

          expect(result, contains(part));
        }
      });
    });

    group('updateGenerated', () {
      test('should replace generator name', () {
        const generatorName = 'fakeGenerator';

        const fakeContents = [
          '// @generator=$generatorName',
          '''
// @generator=$generatorName

part 'vol.de.dart';
''',
        ];

        final line = '*' * 77;
        String header(String name) => '''
// $line
// $generatorName
// $line
''';

        for (final fakeContent in fakeContents) {
          final result = content.updateGenerated(fakeContent);

          expect(result, startsWith(header(generatorName)));
        }
      });
    });
  });
}

class FakeFile extends Fake implements File {
  FakeFile({String? prepend}) : prepend = prepend ?? '';

  @override
  bool existsSync() => true;

  final String prepend;

  @override
  String readAsStringSync({Encoding encoding = utf8}) =>
      '$prepend$_fakeFileContent';
}

const _fakeFileContent = '''
class Test {
  String test() {
    return 'test';
  }
}''';
