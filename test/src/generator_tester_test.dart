import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
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
    String? partOfFile,
  }) {
    final fileName_ = fileName ?? 'fileName';
    return SuccessGenerator(
      [fileName_],
      [fileName_],
      MockGenerator(),
      inputDir: inputDir ?? SuccessGenerator.defaultInputDir,
      fixtureDir: fixtureDir ?? SuccessGenerator.defaultFixtureDir,
      compareWithFixture: compareWithFixture,
      partOfFile: partOfFile ?? fileName_,
    );
  }

  SuccessGenerator builder({
    String? fileName,
    String? inputDir,
    String? fixtureDir,
    bool compareWithFixture = true,
    String? partOfFile,
    String? extension,
    String? builderExtension,
  }) {
    final fileName_ = fileName ?? 'fileName';
    return SuccessGenerator.fromBuilder(
      [fileName_],
      [fileName_],
      (_) => FakeBuilder(extension: builderExtension),
      inputDir: inputDir ?? SuccessGenerator.defaultInputDir,
      fixtureDir: fixtureDir ?? SuccessGenerator.defaultFixtureDir,
      compareWithFixture: compareWithFixture,
      partOfFile: partOfFile ?? fileName_,
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
        expect(generator().inputDir, 'test/inputs');
        expect(builder().inputDir, 'test/inputs');
      });
    });

    group('#fixtureDir', () {
      test('returns provided directory', () {
        const dir = 'dart_arts';

        expect(generator(fixtureDir: dir).fixtureDir, dir);
        expect(builder(fixtureDir: dir).fixtureDir, dir);
      });

      test('returns default directory when not provided', () {
        expect(generator().fixtureDir, 'test/fixtures');
        expect(builder().fixtureDir, 'test/fixtures');
      });
    });

    group('#partOfFile', () {
      test('returns provided fixture file name', () {
        const name = 'scabbers';
        const fixture = 'worm_tail';

        expect(
          generator(fileName: name, partOfFile: fixture).partOfFile,
          fixture,
        );
        expect(
          builder(fileName: name, partOfFile: fixture).partOfFile,
          fixture,
        );
      });

      test('returns file name when not provided', () {
        const name = 'ron_weasley';
        expect(generator(fileName: name).partOfFile, name);
        expect(builder(fileName: name).partOfFile, name);
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

  test('#test return future void', () {
    final tester = FakeGeneratorTester();

    expect(tester.test(), isA<Future<void>>());
  });
}

class FakeGeneratorTester extends Fake implements SuccessGenerator {
  @override
  Future<void> test({
    TestReaderWriter? readerWriter,
    String? rootPackage,
  }) =>
      Future.value();
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
