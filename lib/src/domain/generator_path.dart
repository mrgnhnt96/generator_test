///
class GeneratorPath {
  static const _defaultPath = 'test/generator';
  static const _defaultInput = '$_defaultPath/input';
  static const _defaultfixture = '$_defaultPath/fixture';

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
  static void setDirPath({
    String? input,
    String? fixture,
  }) {
    input ??= _defaultInput;
    fixture ??= _defaultfixture;

    _inputPath = input;
    _fixturePath = fixture;
  }
}
