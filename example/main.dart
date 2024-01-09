import 'package:generator_test/generator_test.dart';

import './fake_generator.dart';

void main() async {
  const generator = SuccessGenerator(
    ['input.dart'],
    ['input.g.dart'],
    fakeGenerator,
    partOfFile: 'input.dart',
  );

  await generator.test();
}
