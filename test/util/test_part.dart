part of 'test_library.dart';

@ShouldThrow(
  'Uh...',
  testDetails: TestDetails(group: 'vague'),
  checkForElement: CheckElement.ignore(),
)
@TestAnnotation()
class TestClass2 {}
