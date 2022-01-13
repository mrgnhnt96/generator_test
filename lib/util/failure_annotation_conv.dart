import 'package:analyzer/dart/element/element.dart';
import 'package:generator_test/src/failure_annotations.dart';
import 'package:source_gen/source_gen.dart';

/// {@template should_throw_annotation}
/// a helper class to convert [ShouldThrow] from an annotation
/// {@endtemplat}
class ShouldThrowAnnotation extends ShouldThrow {
  /// {@macro should_throw_annotation}
  const ShouldThrowAnnotation({
    required String message,
    required String? todo,
    required TestDetails testDetails,
  }) : super(
          message,
          todo: todo,
          testDetails: testDetails,
        );

  /// gets the should throw from the [element]
  static ShouldThrow fromElement(ElementAnnotation element) {
    final annotation = ConstantReader(element.computeConstantValue());
    final message = annotation.read('message').stringValue;
    final todo = annotation.read('todo').literalValue as String?;
    // final checkForElementObj = annotation.read('checkForElement').objectValue;
    // final checkForElement =
    //     CheckElementAnnotation.fromReader(ConstantReader(checkForElementObj));

    final testDetailsObj = annotation.read('testDetails').objectValue;
    final testDetails =
        TestDetailsAnnotation.fromReader(ConstantReader(testDetailsObj));

    return ShouldThrow(
      message,
      todo: todo,
      testDetails: testDetails ??
          TestDetails(name: 'Testing ${element.element?.displayName}'),
    );
  }

  /// checks all the [metadata] for the [ShouldThrow] annotation
  static ShouldThrow? fromElements(List<ElementAnnotation> metadata) {
    for (final annotation in metadata) {
      if (annotation.element?.displayName == '$ShouldThrow') {
        return ShouldThrowAnnotation.fromElement(annotation);
      }
    }
  }
}

/// {@template check_element_annotation}
/// helper class to get [CheckElement] from a [ConstantReader]
/// {@endtemplate}
class CheckElementAnnotation extends CheckElement {
  /// {@macro check_element_annotation}
  static CheckElement fromReader(ConstantReader reader) {
    final isAttached = reader.read('isAttached').literalValue as bool?;
    final name = reader.read('name').literalValue as String?;

    if (isAttached == true) {
      return const CheckElement.isAttached();
    }

    if (name != null) {
      return CheckElement.name(name);
    }

    return const CheckElement();
  }
}

/// {@template test_details_annotation}
/// helper class to get [TestDetails] from a [ConstantReader]
/// {@endtemplate}
class TestDetailsAnnotation extends TestDetails {
  /// {@macro test_details_annotation}
  TestDetailsAnnotation({
    required String name,
    required String? group,
  }) : super(
          name: name,
          group: group,
        );

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
