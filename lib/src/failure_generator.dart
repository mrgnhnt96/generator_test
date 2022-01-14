import 'dart:async';
import 'dart:io';

import 'package:analyzer/src/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:generator_test/src/content.dart';
import 'package:generator_test/src/source_gen_test/expectation_element.dart';
import 'package:generator_test/util/failure_annotation_conv.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

/// {@template failure_generator}
/// A Generator that will verify failures during the build process.
/// {@endtemplate}
class FailureGenerator<T> with ReaderMixin<T> {
  /// {@macro failure_generator}
  const FailureGenerator(
    String fileName,
    this.generator, {
    this.directory = 'test/failures',
  }) : _fileName = fileName;

  /// the checker that will be used as reference
  /// to get the elements from the file
  TypeChecker get checker => TypeChecker.fromRuntime(T);

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
  Future<Iterable<FailureElement>> getTests() async {
    final file = File(p.join(directory, fileName));

    if (!file.existsSync()) {
      throw StateError('File ${file.path} does not exist');
    }

    final content = await file.readAsString();

    final reader =
        await initializeLibraryReaderForDirectory(directory, fileName);

    final libraries = await splitLibrary(reader, content);

    final failures = libraries.map(this.genAnnotatedElements).expand((e) => e);

    return failures;
  }

  /// runs tests ordered by group
  Future<void> runTests() async {
    final failures = await getTests();

    if (failures.isEmpty) {
      throw 'Could not find any tests for $T';
    }

    final groups = {'default': <FailureElement>[]};

    for (final failure in failures) {
      final group = failure.shouldThrow.testDetails?.group ?? 'default';

      groups.putIfAbsent(group, () => <FailureElement>[]);

      groups[group]!.add(failure);
    }

    group('$T', () {
      for (final key in groups.keys) {
        final tests = groups[key]!;

        final groupName = key == 'default' ? '' : key;

        group(groupName, () {
          for (final failure in tests) {
            final description = failure.shouldThrow.testDetails?.name ??
                failure.element.displayName;
            test(description, () async {
              // await failure.runTest();
            });
          }
        });
      }
    });
  }
}

/// analyzes the file and returns a LibraryElement
mixin ReaderMixin<T> {
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

  String assetIdForFile(String fileName) => '__test__|lib/$fileName';

  Future<Iterable<LibraryReader>> splitLibrary(
      LibraryReader reader, String content) async {
    final elements = reader.allElements.whereType<ElementImpl>();

    final libraries = <LibraryReader>[];

    for (var i = 0; i < elements.length; i++) {
      final element = elements.elementAt(i);
      final fileName = 'split_library_$i.dart';

      final offset = element.codeOffset;

      if (offset == null) {
        continue;
      }

      final splitContent =
          content.substring(offset, (element.codeLength ?? 0) + offset);

      final map = {fileName: splitContent};

      final reader = await initializeLibraryReader(map, fileName);

      libraries.add(reader);
    }

    return libraries;
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

  Iterable<FailureElement> genAnnotatedElements(
    LibraryReader libraryReader,
  ) {
    final allElements = libraryReader.allElements.toList(growable: false)
      ..sort((a, b) => a.name!.compareTo(b.name!));

    return allElements.expand((element) {
      final initialValues = ShouldThrowAnnotation.fromElement(element);

      return initialValues.map((te) {
        return FailureElement(shouldThrow: te, element: element);
      });
    });
  }
}

// ignore: subtype_of_sealed_class
class _MockBuildStep extends BuildStep {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// the method to run the generator
typedef RunGenerator = FutureOr<String?> Function();
