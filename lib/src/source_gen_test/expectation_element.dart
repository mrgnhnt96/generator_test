import 'package:analyzer/dart/element/element.dart';
import 'package:generator_test/util/failure_annotation_conv.dart';
import 'package:source_gen/source_gen.dart';

import '../failure_annotations.dart';

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

/// {@template failure_test}
/// The test that will be run for the failure
/// {@endtemplate}
class FailureElement {
  /// {@macro failure_test}
  const FailureElement({
    required this.element,
    required this.shouldThrow,
  });

  /// the annotated element to be tested
  final Element element;

  /// the expected failure
  final ShouldThrow shouldThrow;
}
