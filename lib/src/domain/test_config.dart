/// {@template test_options}
/// The optional configurations for the test
/// {@endtemplate}
class TestConfig {
  /// {@macro test_options}
  const TestConfig({
    this.formatOutput = true,
    this.formatInput = false,
  });

  /// formats the output content using dart_style
  final bool formatOutput;

  /// formats the input content using dart_style
  final bool formatInput;
}
