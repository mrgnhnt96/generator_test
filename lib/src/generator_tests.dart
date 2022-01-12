// ignore_for_file: avoid_field_initializers_in_const_classes, recursive_getters

import 'package:build/build.dart';
import 'package:generator_test/src/domain/generator_prep.dart';
import 'package:source_gen/source_gen.dart';

/// Run test with code generated from the [fileName] file
Future<void> testPartGenerator(
  String fileName,
  Generator generator, {
  bool compareWithFixture = true,
  String? inputDir,
  String? fixtureDir,
  String? fixtureFileName,
}) async {
  final codeGen = GeneratorPrep(
    fileName,
    generator,
    compareWithFixture: compareWithFixture,
    inputDir: inputDir,
    fixtureDir: fixtureDir,
    fixtureFileName: fixtureFileName,
  );

  await codeGen.test();
}

/// provides the build options to return a builder
typedef GetBuilder = Builder Function(BuilderOptions options);

/// runs test for the Generator(s) with the given [builder]
Future<void> testPackageBuilder(
  String fileName, {
  Map<String, dynamic>? builderOptions,
  required GetBuilder builder,
  bool compareWithFixture = true,
  String? extension,
  String? inputDir,
  String? fixtureDir,
  String? fixtureFileName,
}) async {
  final builderConfig = BuilderOptions(builderOptions ?? <String, dynamic>{});

  final codeGen = GeneratorPrep.fromBuilder(
    fileName,
    builder(builderConfig),
    compareWithFixture: compareWithFixture,
    extension: extension,
    inputDir: inputDir,
    fixtureDir: fixtureDir,
    fixtureFileName: fixtureFileName,
  );

  await codeGen.test();
}
