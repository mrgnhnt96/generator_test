///
class GeneratorPath {
  static const _defaultInput = 'test/fixture';
  static const _defaultfixture = 'test/fixture/fixtures';

  static var _inputPath = _defaultInput;
  static var _fixturePath = _defaultfixture;

  /// The input path for the generator test files
  ///
  /// defaults to: `test/generator/input`
  static String get input => _inputPath;

  /// The fixture path for the generator test files
  ///
  /// defaults to: `test/generator/fixture`
  static String get fixture => _fixturePath;

  /// Set the [input] and [fixture] directory paths for the generator test files
  ///
  /// [input] defaults to: `test/generator/input`\
  /// [fixture] defaults to: `test/generator/fixture`
  static void setDirectory({
    String? input,
    String? fixture,
  }) {
    _inputPath = input ?? _defaultInput;
    _fixturePath = fixture ?? _defaultfixture;
  }
}
