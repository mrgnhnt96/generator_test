import 'package:generator_test/src/source_gen_test/expectation_element.dart';
import 'package:test/test.dart';
import 'package:generator_test/src/failure_generator.dart';

import '../util/test_annotation.dart';
import '../util/test_generator.dart';

void main() {
  group(
    FailureElement,
    () {
      test(
        '',
        () async {
          const failure = FailureGenerator<TestAnnotation>(
            'test_library',
            TestGenerator(),
            directory: 'test/util',
          );

          await failure.runTests();
        },
      );
    },
  );
}
