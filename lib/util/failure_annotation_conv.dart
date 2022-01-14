import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:generator_test/src/failure_annotations.dart';
import 'package:generator_test/src/source_gen_test/expectation_element.dart';
import 'package:source_gen/source_gen.dart';

/// {@template should_throw_annotation}
/// a helper class to convert [ShouldThrow] from an annotation
/// {@endtemplate}
class ShouldThrowAnnotation {
  /// gets the [ShouldThrow] annotation from an [Element]
  static Iterable<FailureElement> failuresForElement(Element element) sync* {
    final throws = fromElement(element);

    for (final failure in throws) {
      yield FailureElement(element: element, shouldThrow: failure);
    }
  }

  /// get the annotations from the [element]
  static Iterable<ShouldThrow> fromElement(Element element) sync* {
    final annotations =
        const TypeChecker.fromRuntime(ShouldThrow).annotationsOf(element);

    for (final annotation in annotations) {
      yield ShouldThrowAnnotation.fromObject(annotation, element.displayName);
    }
  }

  /// gets the should throw from the [object]
  static ShouldThrow fromObject(DartObject? object, String name) {
    final annotation = ConstantReader(object);
    final message = annotation.read('message').stringValue;
    final todo = annotation.read('todo').literalValue as String?;
    final checkForElementObj = annotation.read('checkForElement').objectValue;
    final checkForElement =
        CheckElementAnnotation.fromReader(ConstantReader(checkForElementObj));

    final testDetailsObj = annotation.read('testDetails').objectValue;
    final testDetails =
        TestDetailsAnnotation.fromReader(ConstantReader(testDetailsObj));

    final expectedLogs = annotation
        .read('expectedLogs')
        .listValue
        .map((obj) => obj.toStringValue()!);

    return ShouldThrow(
      message,
      todo: todo,
      checkForElement: checkForElement,
      testDetails: testDetails ?? TestDetails(name: 'Testing $name'),
      expectedLogs: expectedLogs,
    );
  }

  /// checks all the [metadata] for the [ShouldThrow] annotation
  static ShouldThrow? fromElements(List<ElementAnnotation> metadata) {
    for (final annotation in metadata) {
      if (annotation.element?.displayName == '$ShouldThrow') {
        return ShouldThrowAnnotation.fromObject(
          annotation.computeConstantValue(),
          annotation.element!.displayName,
        );
      }
    }
  }
}

/// {@template check_element_annotation}
/// helper class to get [CheckElement] from a [ConstantReader]
/// {@endtemplate}
class CheckElementAnnotation {
  /// {@macro check_element_annotation}
  static CheckElement fromReader(ConstantReader reader) {
    final isAttached = reader.read('isAttached').literalValue as bool?;
    final name = reader.read('name').literalValue as String?;

    if (isAttached == true) {
      return const CheckElement.isAttached();
    }

    return CheckElement(name);
  }
}

/// {@template test_details_annotation}
/// helper class to get [TestDetails] from a [ConstantReader]
/// {@endtemplate}
class TestDetailsAnnotation {
  /// gets the test details from the [reader]
  static TestDetails? fromReader(ConstantReader reader) {
    final name = reader.read('name').literalValue as String?;
    final group = reader.read('group').literalValue as String?;

    if (name == null) {
      return null;
    }

    return TestDetails(
      name: name,
      group: group,
    );
  }
}
