/// {@template test_options}
/// The optional configurations for the test
/// {@endtemplate}
class TestConfig {
  /// {@macro test_options}
  const TestConfig({
    this.compareWithOutput = false,
    this.formatOutput = true,
    this.formatInput = false,
  });

  /// compares the input content with the generated output
  ///
  /// if false, the test will pass if the generated
  /// output contains no generated errors
  final bool compareWithOutput;

  /// formats the output content using dart_style
  final bool formatOutput;

  /// formats the input content using dart_style
  final bool formatInput;
}
