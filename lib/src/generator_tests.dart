// ignore_for_file: avoid_field_initializers_in_const_classes, recursive_getters

import 'package:build/build.dart';
import 'package:generator_test/src/domain/domain.dart';
import 'package:generator_test/src/util/util.dart';
import 'package:source_gen/source_gen.dart';

/// Retrieves the file content from the [GeneratorPath.input]/[fileName].dart file.
///
/// [addPart] adds `part '[fileName].g.dart';' to the file after imports
String inputContent(
  String fileName, {
  bool addPart = false,
}) {
  final path = '${GeneratorPath.input}/$fileName.dart';

  String? part;

  if (addPart) {
    part = "part '$fileName.g.dart';";
  }

  final content = getFileContent(path, part);

  return content;
}

/// Retrieves the file content from the [GeneratorPath.output]/[fileName].dart file.
///
/// Automatically adds
/// - `part of '[fileName].dart';`
/// - `// GENERATED CODE - DO NOT MODIFY BY HAND`
/// - Generator's name (`T`) comment
String outputContent<T extends Generator>(String fileName) {
  return outputContentFromTypes(fileName, ['$T']);
}

/// Run test with code generated from [inputContent]
///
/// When [compareWithOutput] is `true`, the generated code is compared
/// with [outputContent]
///
/// When [compareWithOutput] is `false`, the test will pass if there
/// are no errors in the generated code.
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
  List<String> fileNames,
  Builder builder, {
  bool compareWithOutput = false,
}) async {
  final codeGens = GeneratorPrep.fromBuilder(
    fileNames,
    builder,
    compareWithOutput: compareWithOutput,
  );

  await codeGens.test();
}
