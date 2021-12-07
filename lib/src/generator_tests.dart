// ignore_for_file: avoid_field_initializers_in_const_classes, recursive_getters

import 'package:build/build.dart';
import 'package:generator_test/src/domain/domain.dart';
import 'package:generator_test/src/util/util.dart';
import 'package:source_gen/source_gen.dart';

/// Run test with code generated from [inputContent]
Future<void> testPartGenerator(
  String fileName, {
  required Generator generator,
  TestConfig? config,
}) async {
  final codeGens = GeneratorPrep(
    fileName,
    generator,
    config: config,
  );

  await codeGens.test();
}

/// Test builder that impact a group of files.
Future<void> testPackageBuilder(
  String fileName, {
  Map<String, dynamic>? builderOptions,
  required GetBuilder builder,
  TestConfig? config,
}) async {
  final builderConfig =
      TestBuilderOptions(builderOptions ?? <String, dynamic>{});

  final codeGens = GeneratorPrep.fromBuilder(
    fileName,
    builder(builderConfig),
    config: config,
  );

  await codeGens.test();
}

/// provides the build options to return a builder
typedef GetBuilder = Builder Function(BuilderOptions options);
