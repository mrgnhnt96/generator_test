///
class GeneratorPath {
  static const _defaultPath = 'test/generator';
  static const _defaultInput = '$_defaultPath/input';
  static const _defaultOutput = '$_defaultPath/output';

  static var _inputPath = _defaultInput;
  static var _outputPath = _defaultOutput;

  /// The input path for the generator test files
  ///
  /// defaults to: `test/generator/input`
  static String get input => _inputPath;

  /// The output path for the generator test files
  ///
  /// defaults to: `test/generator/output`
  static String get output => _outputPath;

  /// Set the [input] and [output] directory paths for the generator test files
  ///
  /// [input] defaults to: `test/generator/input`\
  /// [output] defaults to: `test/generator/output`
  static void setDirPath({
    String? input,
    String? output,
  }) {
    input ??= _defaultInput;
    output ??= _defaultOutput;

    _inputPath = input;
    _outputPath = output;
  }
}
