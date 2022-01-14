import 'package:generator_test/src/failure_annotations.dart';

import 'test_annotation.dart';

part 'test_part.dart';

@ShouldThrow(
  'Uh...',
  testDetails: TestDetails(group: 'vague'),
  checkForElement: CheckElement.ignore(),
)
@TestAnnotation()
class TestClass1 {}

@ShouldThrow(
  'All classes must start with `TestClass`.',
  todo: 'Rename the type or remove the `TestAnnotation` from class.',
  testDetails: TestDetails(group: 'default'),
  expectedLogs: ['This member might be not good.'],
)
@TestAnnotation()
class BadTestClass {}

@ShouldThrow(
  'Cannot generate for classes with members that include `unsupported` in '
  'their name.',
  checkForElement: CheckElement('unsupportedFunc'),
  testDetails: TestDetails(group: 'default'),
  expectedLogs: ['This member might be not good.'],
)
@TestAnnotation()
class TestClassWithBadMember {
  void unsupportedFunc() {}
}

@ShouldThrow(
  'Only supports annotated classes.',
  todo: 'Remove `TestAnnotation` from the associated element.',
)
@TestAnnotation()
int badTestFunc() => 42;

@ShouldThrow(
  'Only supports annotated classes.',
  todo: 'Remove `TestAnnotation` from the associated element.',
)
@TestAnnotation()
const badTestField = 42;
