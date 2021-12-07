// ignore_for_file: avoid_field_initializers_in_const_classes, recursive_getters

import 'package:build/build.dart';
import 'package:generator_test/src/domain/domain.dart';
import 'package:generator_test/src/util/util.dart';
import 'package:source_gen/source_gen.dart';

Future<void> testPartGenerator(
  String fileName, {
  required Generator generator,
  bool compareWithOutput = false,
}) async {
  final codeGens = GeneratorPrep(
    [fileName],
    generator,
    compareWithOutput: compareWithOutput,
  );

  await codeGens.test();
}

/// Test multiple generators that impact a group of files.
Future<void> testPartGenerators(
  List<String> fileNames,
  List<Generator> generators, {
  bool compareWithOutput = false,
}) async {
  final codeGens = GeneratorPrep.multi(
    fileNames,
    generators,
    compareWithOutput: compareWithOutput,
  );

  await codeGens.test();
}

/// Test builder that impact a group of files.
Future<void> testPackageBuilder(
  List<String> fileNames, {
  Map<String, dynamic>? builderOptions,
  required GetBuilder builder,
  bool compareWithOutput = false,
}) async {
  final options = TestBuilderOptions(builderOptions ?? <String, dynamic>{});

  final codeGens = GeneratorPrep.fromBuilder(
    fileNames,
    builder(options),
    compareWithOutput: compareWithOutput,
  );

  await codeGens.test();
}

/// provides the build options to return a builder
typedef GetBuilder = Builder Function(BuilderOptions options);
