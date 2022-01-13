import 'dart:async';
import 'dart:io';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:generator_test/src/failure_annotations.dart';
import 'package:generator_test/util/failure_annotation_conv.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

/// the name of the package to be tested
const testPackageName = '__test__';

/// {@template failure_generator}
/// A Generator that will verify failures during the build process.
/// {@endtemplate}
class FailureGenerator with ReaderMixin {
  /// {@macro failure_generator}
  const FailureGenerator(
    String fileName,
    this.generator, {
    required this.annotation,
    this.directory = 'test/failures',
  }) : _fileName = fileName;

  /// the annotation that will be tested
  final Type annotation;

  /// the checker that will be used as reference
  /// to get the elements from the file
  TypeChecker get checker => TypeChecker.fromRuntime(annotation);

  /// the name of the file to generate for
  String get fileName {
    if (_fileName.endsWith('.dart')) {
      return _fileName;
    }
    return '$_fileName.dart';
  }

  final String _fileName;

  /// the directory where [fileName] is located
  final String directory;

  /// the generator to be used to test failures
  final Generator generator;

  /// the elements of the file annotated with [annotation]
  Future<Iterable<FailureTest>> getTests() async {
    final reader =
        await initializeLibraryReaderForDirectory(directory, fileName);

    final elements = reader.annotatedWith(checker);

    final failures = <FailureTest>[];

    for (final element in elements) {
      final shouldThrow =
          ShouldThrowAnnotation.fromElements(element.element.metadata);

      if (shouldThrow == null) {
        throw 'There is not a ShouldThrow annotation on ${element.element.displayName}';
      }

      final failure = FailureTest(
        element: element,
        shouldThrow: shouldThrow,
        runGenerator: () {
          return generator.generate(
            reader,
            _MockBuildStep(),
          );
        },
      );

      failures.add(failure);
    }

    return failures;
  }

  /// runs tests ordered by group
  Future<void> runTests() async {
    final failures = await getTests();

    final groups = {'default': <FailureTest>[]};

    for (final failure in failures) {
      final group = failure.shouldThrow.testDetails?.group ?? 'default';

      groups.putIfAbsent(group, () => <FailureTest>[]);

      groups[group]!.add(failure);
    }

    for (final key in groups.keys) {
      final tests = groups[key]!;

      final groupName = key == 'default' ? '' : key;

      group(groupName, () {
        for (final failure in tests) {
          final description = failure.shouldThrow.testDetails?.name ??
              failure.element.element.displayName;
          test(description, () async {
            await failure.runTest();
          });
        }
      });
    }
  }
}

/// analyzes the file and returns a LibraryElement
mixin ReaderMixin {
  /// Returns a [LibraryReader] for library specified by [targetLibraryFileName]
  /// using the files in [sourceDirectory].
  Future<LibraryReader> initializeLibraryReaderForDirectory(
    String sourceDirectory,
    String targetLibraryFileName,
  ) async {
    final map = Map.fromEntries(
      Directory(sourceDirectory)
          .listSync()
          .whereType<File>()
          .map((f) => MapEntry(p.basename(f.path), f.readAsStringSync())),
    );

    try {
      return await initializeLibraryReader(map, targetLibraryFileName);
    } on ArgumentError catch (e) // ignore: avoid_catching_errors
    {
      if (e.message == 'Must exist as a key in `contentMap`.') {
        throw ArgumentError.value(
          targetLibraryFileName,
          'targetLibraryFileName',
          'Must exist as a file in `sourceDirectory`.',
        );
      }
      rethrow;
    }
  }

  /// Returns a [LibraryReader] for library specified by [targetLibraryFileName]
  /// using the file contents described by [contentMap].
  ///
  /// [contentMap] contains the Dart file contents to from which to create the
  /// library stored as filename / file content pairs.
  Future<LibraryReader> initializeLibraryReader(
    Map<String, String> contentMap,
    String targetLibraryFileName,
  ) async {
    if (!contentMap.containsKey(targetLibraryFileName)) {
      throw ArgumentError.value(
        targetLibraryFileName,
        'targetLibraryFileName',
        'Must exist as a key in `contentMap`.',
      );
    }

    String assetIdForFile(String fileName) => '$testPackageName|lib/$fileName';

    final targetLibraryAssetId = assetIdForFile(targetLibraryFileName);

    final assetMap = contentMap
        .map((file, content) => MapEntry(assetIdForFile(file), content));

    final library = await resolveSources(
      assetMap,
      (item) async {
        final assetId = AssetId.parse(targetLibraryAssetId);
        return item.libraryFor(assetId);
      },
      resolverFor: targetLibraryAssetId,
    );

    return LibraryReader(library);
  }
}

// ignore: subtype_of_sealed_class
class _MockBuildStep extends BuildStep {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// the method to run the generator
typedef RunGenerator = FutureOr<String?> Function();

/// {@template failure_test}
/// The test that will be run for the failure
/// {@endtemplate}
class FailureTest {
  /// {@macro failure_test}
  const FailureTest({
    required this.element,
    required this.shouldThrow,
    required this.runGenerator,
  });

  /// the annotated element to be tested
  final AnnotatedElement element;

  /// the expected failure
  final ShouldThrow shouldThrow;

  /// the generator that will run the test and return the expected failure
  final RunGenerator runGenerator;

  /// runs the test to verify the failure
  Future<void> runTest() async {
    await expectLater(
      runGenerator,
      shouldThrow.does(element.element.displayName),
    );
  }
}
