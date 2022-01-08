import 'package:build/build.dart';

/// {@template test_builder_options}
/// Creates a [BuilderOptions] from the given [config]
/// {@endtemplate}
class TestBuilderOptions extends BuilderOptions {
  /// {@macro test_builder_options}
  const TestBuilderOptions(Map<String, dynamic> config) : super(config);
}
