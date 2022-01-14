import 'dart:async';

import 'package:generator_test/src/failure_annotations.dart';
import 'package:generator_test/src/source_gen_test/build_log_tracking.dart';
import 'package:generator_test/src/source_gen_test/expectation_element.dart';
import 'package:generator_test/src/source_gen_test/generate_for_element.dart';
import 'package:generator_test/src/source_gen_test/matchers.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

/// If [defaultConfiguration] is not provided or `null`, "default" and the keys
/// from [additionalGenerators] (if provided) are used.
///
/// Tests registered by this function assume [initializeBuildLogTracking] has
/// been called.
///
/// If [expectedAnnotatedTests] is provided, it should contain the names of the
/// members in [libraryReader] that are annotated for testing. If the same
/// element is annotated for multiple tests, it should appear in the list
/// the same number of times.
void testAnnotatedElements<T>(
  LibraryReader libraryReader,
  Generator generator, {
  Map<String, GeneratorForAnnotation<T>>? additionalGenerators,
  Iterable<String>? expectedAnnotatedTests,
  Iterable<String>? defaultConfiguration,
}) {
  for (final entry in getAnnotatedClasses<T>(
    libraryReader,
    generator,
    expectedAnnotatedTests: expectedAnnotatedTests,
  )) {
    entry._registerTest();
  }
}

/// An implementation member only exposed to make it easier to test
/// [testAnnotatedElements] without registering any tests.
@visibleForTesting
List<AnnotatedTest> getAnnotatedClasses<T>(
  LibraryReader libraryReader,
  Generator generator, {
  Iterable<String>? expectedAnnotatedTests,
}) {
  final annotatedElements = genAnnotatedElements(libraryReader);

  if (expectedAnnotatedTests != null) {
    final expectedList = expectedAnnotatedTests.toList();

    final missing = <String>[];

    final elementNames = annotatedElements.map((e) => e.element.displayName);

    for (final name in elementNames) {
      if (!expectedList.remove(name)) {
        missing.add(name);
      }
    }

    if (expectedList.isNotEmpty) {
      throw ArgumentError.value(
        expectedList.map((e) => "'$e'").join(', '),
        'expectedAnnotatedTests',
        'There are unexpected items',
      );
    }
    if (missing.isNotEmpty) {
      throw ArgumentError.value(
        missing.map((e) => "'$e'").join(', '),
        'expectedAnnotatedTests',
        'There are items missing',
      );
    }
  }

  final result = <AnnotatedTest<T>>[];

  for (final entry in annotatedElements) {
    result.add(
      AnnotatedTest<T>(
        libraryReader: libraryReader,
        generator: generator,
        elementName: entry.element.displayName,
        shouldThrow: entry.shouldThrow,
      ),
    );
  }

  return result;
}

class AnnotatedTest<T> {
  AnnotatedTest({
    required LibraryReader libraryReader,
    required this.generator,
    required String elementName,
    required this.shouldThrow,
  })  : _libraryReader = libraryReader,
        _elementName = elementName;

  void _registerTest() {
    test(_testName, _shouldThrowTest);
  }

  Future<String> _generate() =>
      generateForElement<T>(generator, _libraryReader, _elementName);

  Future<void> _shouldThrowTest() async {
    final matcher = shouldThrow.does(_elementName);

    await expectLater(
      _generate,
      throwsInvalidGenerationSourceError(
        shouldThrow.message,
        todoMatcher: shouldThrow.todo,
        elementMatcher: matcher,
      ),
    );

    expect(
      buildLogItems,
      shouldThrow.expectedLogs,
      reason: 'The expected log items do not match.',
    );
    clearBuildLog();
  }

  final Generator generator;
  final LibraryReader _libraryReader;
  final ShouldThrow shouldThrow;
  final String _elementName;

  String get _testName {
    return _elementName;
  }
}
