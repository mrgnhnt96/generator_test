import 'dart:io';

import 'package:build/build.dart';
import 'package:generator_test/generator_test.dart';
import 'package:test/test.dart';

import '../util/test_annotation.dart';

// TODO: test initializeLibraryReader - but since
//  `initializeLibraryReaderForDirectory` wraps it, not a big hurry
void main() {
  final testReaderMixin = TestReaderMixin<TestAnnotation>();

  group('initializeLibraryReaderForDirectory', () {
    test('valid', () async {
      final reader = await testReaderMixin.initializeLibraryReaderForDirectory(
        'test/util',
        'test_library.dart',
      );

      expect(
        reader.allElements.map((e) => e.name),
        unorderedMatches(<String>[
          '', // this is the library
          'BadTestClass',
          'badTestField',
          'badTestField',
          'badTestFunc',
          'TestClass1',
          'TestClass2',
          'TestClassWithBadMember',
        ]),
      );
    });

    test('bad library name', () async {
      await expectLater(
        () => testReaderMixin.initializeLibraryReaderForDirectory(
          'test/util',
          'test_library_bad.dart',
        ),
        throwsA(
          isArgumentError
              .having(
                (ae) => ae.message,
                'message',
                'Must exist as a file in `sourceDirectory`.',
              )
              .having((ae) => ae.name, 'name', 'targetLibraryFileName'),
        ),
      );
    });

    test('non-existant directory', () async {
      await expectLater(
        () => testReaderMixin.initializeLibraryReaderForDirectory(
          'test/not_src',
          'test_library.dart',
        ),
        throwsA(const TypeMatcher<FileSystemException>()),
      );
    });

    test('part instead', () async {
      await expectLater(
        () => testReaderMixin.initializeLibraryReaderForDirectory(
          'test/util',
          'test_part.dart',
        ),
        throwsA(
          isA<NonLibraryAssetException>().having(
            (ae) => ae.assetId.toString(),
            'assetId.toString()',
            '__test__|lib/test_part.dart',
          ),
        ),
      );
    });
  });
}

class TestReaderMixin<T> with ReaderMixin<T> {}
