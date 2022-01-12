import 'package:generator_test/generator_test.dart';
import 'package:test/test.dart';

void main() {
  setUp(GeneratorPath.setDirectory);

  group('should be default paths when not setup', () {
    test('input', () {
      expect(GeneratorPath.input, 'test/fixture');
    });

    test('fixture', () {
      expect(GeneratorPath.fixture, 'test/fixture/fixtures');
    });
  });

  group('should be provided paths when set', () {
    test('input', () {
      const path = 'test';

      GeneratorPath.setDirectory(input: path);

      expect(GeneratorPath.input, path);
    });

    test('fixture', () {
      const path = 'test';

      GeneratorPath.setDirectory(fixture: path);

      expect(GeneratorPath.fixture, path);
    });
  });
}
