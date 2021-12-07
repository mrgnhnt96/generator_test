// ignore_for_file: avoid_field_initializers_in_const_classes, recursive_getters

import 'package:build/build.dart';
import 'package:generator_test/src/domain/domain.dart';
import 'package:generator_test/src/util/util.dart';
import 'package:source_gen/source_gen.dart';

/// Run test with code generated from [inputContent]
Future<void> testPartGenerator(
  String fileName,
  Generator generator, {
  bool compareWithOutput = true,
}) async {
  final codeGen = GeneratorPrep(
    fileName,
    generator,
    compareWithOutput: compareWithOutput,
  );

  await codeGen.test();
}

/// provides the build options to return a builder
typedef GetBuilder = Builder Function(BuilderOptions options);

/// runs test for the Generator(s) with the given [builder]
///
/// !! If your [builder] contains a header, make sure to include it in
/// the output file.
Future<void> testPackageBuilder(
  String fileName, {
  Map<String, dynamic>? builderOptions,
  String? header,
  required GetBuilder builder,
  bool compareWithOutput = true,
}) async {
  final builderConfig =
      TestBuilderOptions(builderOptions ?? <String, dynamic>{});

  final codeGen = GeneratorPrep.fromBuilder(
    fileName,
    builder(builderConfig),
    compareWithOutput: compareWithOutput,
    header: header,
  );

  await codeGen.test();
}
