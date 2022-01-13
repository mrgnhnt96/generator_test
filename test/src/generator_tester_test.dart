import 'package:build/build.dart';
import 'package:generator_test/src/content.dart';
import 'package:generator_test/src/success_generator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

void main() {
  SuccessGenerator generator({
    String? fileName,
    String? inputDir,
    String? fixtureDir,
    bool compareWithFixture = true,
    String? fixtureFileName,
  }) {
    return SuccessGenerator(
      fileName ?? 'fileName',
      MockGenerator(),
      inputDir: inputDir ?? 'test/fixture',
      fixtureDir: fixtureDir ?? 'test/fixture/fixtures',
      compareWithFixture: compareWithFixture,
      fixtureFileName: fixtureFileName,
    );
  }

  SuccessGenerator builder({
    String? fileName,
    String? inputDir,
    String? fixtureDir,
    bool compareWithFixture = true,
    String? fixtureFileName,
    String? extension,
    String? builderExtension,
  }) {
    return SuccessGenerator.fromBuilder(
      fileName ?? 'fileName',
      (_) => FakeBuilder(extension: builderExtension),
      inputDir: inputDir ?? 'test/fixture',
      fixtureDir: fixtureDir ?? 'test/fixture/fixtures',
      compareWithFixture: compareWithFixture,
      fixtureFileName: fixtureFileName,
      extension: extension,
    );
  }

  group('constructors', () {
    test('should be different instances', () {
      expect(generator(), isNot(builder()));
    });

    group('#inputDir', () {
      test('returns provided directory', () {
        const dir = 'dart_arts';

        expect(generator(inputDir: dir).inputDir, dir);
        expect(builder(inputDir: dir).inputDir, dir);
      });

      test('returns default directory when not provided', () {
        expect(generator().inputDir, 'test/fixture');
        expect(builder().inputDir, 'test/fixture');
      });
    });

    group('#fixtureDir', () {
      test('returns provided directory', () {
        const dir = 'dart_arts';

        expect(generator(fixtureDir: dir).fixtureDir, dir);
        expect(builder(fixtureDir: dir).fixtureDir, dir);
      });

      test('returns default directory when not provided', () {
        expect(generator().fixtureDir, 'test/fixture/fixtures');
        expect(builder().fixtureDir, 'test/fixture/fixtures');
      });
    });

    group('#fixtureFileName', () {
      test('returns provided fixture file name', () {
        const name = 'scabbers';
        const fixture = 'worm_tail';

        expect(
          generator(fileName: name, fixtureFileName: fixture).fixtureFileName,
          fixture,
        );
        expect(
          builder(fileName: name, fixtureFileName: fixture).fixtureFileName,
          fixture,
        );
      });

      test('returns file name when not provided', () {
        const name = 'ron_weasley';
        expect(generator(fileName: name).fixtureFileName, name);
        expect(builder(fileName: name).fixtureFileName, name);
      });
    });
  });

  group('#extension', () {
    test('should return extension from builder when not provided', () {
      const ext = 'grin.darts';

      expect(builder(builderExtension: ext).extension, ext);
    });

    test('should return extension provided', () {
      const ext = 'hog.darts';

      expect(builder(extension: ext).extension, ext);
    });

    test(
      'should return default extension when using generator constructor',
      () {
        expect(generator().extension, '.g.dart');
      },
    );
  });

  group('#builder', () {
    test('should return the provided builder', () {
      expect(builder().builder, isA<FakeBuilder>());
    });

    test('should create builder when not provided', () {
      expect(generator().builder, isA<PartBuilder>());
    });
  });

  test('#inputContent should return content', () {
    expect(builder().inputContent, isA<Content>());
    expect(generator().inputContent, isA<Content>());
  });

  group('#fixtureContent', () {
    test('should return content from fixture', () {
      expect(builder().fixtureContent(), isA<Content>());
      expect(generator().fixtureContent(), isA<Content>());
    });

    test(
      'should return null from fixture when not comparing with fixture',
      () {
        expect(builder(compareWithFixture: false).fixtureContent(), isNull);
        expect(generator(compareWithFixture: false).fixtureContent(), isNull);
      },
    );
  });

  test('#test return future void', () {
    final tester = FakeGeneratorTester();

    expect(tester.test(), isA<Future<void>>());
  });
}

class FakeGeneratorTester extends Fake implements SuccessGenerator {
  @override
  Future<void> test() => Future.value();
}

class MockGenerator extends Mock implements Generator {}

class FakeBuilder extends Fake implements Builder {
  FakeBuilder({
    String? extension,
  }) : extension = extension ?? '.g.dart';

  final String extension;

  @override
  Map<String, List<String>> get buildExtensions {
    return {
      '.dart': [extension],
    };
  }
}
