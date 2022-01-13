import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

/// {@template check_element}
/// checks for an element with the name from where the exception
/// {@endtemplate}
class CheckElement {
  /// {@macro check_element}
  const CheckElement([String? name])
      : this._(
          isAttached: false,
          name: name,
        );

  const CheckElement._({
    required this.isAttached,
    required this.name,
  });

  /// checks that an element is attached to the error
  const CheckElement.isAttached()
      : this._(
          isAttached: true,
          name: null,
        );

  /// checks that an element is attached to the error
  final bool? isAttached;

  /// checks that an element with the [name] is attached to the error
  final String? name;

  /// checks that an element with the [name] is attached to the error
  Matcher? matcher(String elementName) {
    if (isAttached != null) {
      return isAttached! ? isNotNull : isNull;
    }

    return const TypeMatcher<Element>().having(
      (e) => e.name,
      'name',
      name ?? elementName,
    );
  }
}

///{@template test_details}
/// The details for the test to be run
/// {@endtemplate}
class TestDetails {
  ///{@macro test_details}
  const TestDetails({
    required this.name,
    this.group,
  });

  /// the description of the test
  final String name;

  /// the descriptino of the group
  final String? group;
}

/// {@template should_throw}
/// The error that should be thrown on failure.
/// {@endtemplate}
class ShouldThrow {
  /// {@macro should_throw}
  const ShouldThrow(
    this.message, {
    this.todo = '',
    this.testDetails,
    this.checkForElement = const CheckElement(),
  });

  /// checks for the element attached to the error
  final CheckElement checkForElement;

  /// the message that should be thrown
  final String message;

  /// the todo message that should be attached to the error
  final String? todo;

  /// the details of the test
  final TestDetails? testDetails;

  /// checks that the error is thrown
  Matcher does(String elementName) {
    var matcher = const TypeMatcher<InvalidGenerationSourceError>().having(
      (e) => e.message,
      'message',
      message,
    );

    matcher = matcher.having(
      (e) => e.element,
      'element',
      checkForElement.matcher(elementName),
    );

    if (todo != null) {
      matcher = matcher.having(
        (e) => e.todo,
        'todo',
        todo,
      );
    }

    return throwsA(matcher);
  }
}
