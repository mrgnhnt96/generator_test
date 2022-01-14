import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:source_gen/source_gen.dart';

import 'test_annotation.dart';

const testChecker = TypeChecker.fromRuntime(TestAnnotation);

class TestGenerator extends Generator {
  const TestGenerator({
    this.requireTestClassPrefix = true,
    this.alwaysThrowVagueError = false,
  });

  final bool requireTestClassPrefix;
  final bool alwaysThrowVagueError;

  @override
  FutureOr<String?> generate(
    LibraryReader library,
    BuildStep buildStep,
  ) {
    final elements = library.annotatedWith(testChecker);

    final genCode = <String>[];

    for (final element in elements) {
      final result = generateForElement(element.element);
      genCode.addAll(result);
    }

    return genCode.join('\n');
  }

  Iterable<String> generateForElement(Element element) sync* {
    if (alwaysThrowVagueError) {
      throw InvalidGenerationSourceError('Uh...');
    }

    if (element.name!.contains('Bad')) {
      log.info('This member might be not good.');
    }

    if (element is ClassElement) {
      final unsupportedFunc = element.methods
          .firstWhereOrNull((me) => me.name.contains('unsupported'));

      if (unsupportedFunc != null) {
        throw InvalidGenerationSourceError(
          'Cannot generate for classes with members that include '
          '`unsupported` in their name.',
          element: unsupportedFunc,
        );
      }
    } else {
      throw InvalidGenerationSourceError(
        'Only supports annotated classes.',
        todo: 'Remove `TestAnnotation` from the associated element.',
        element: element,
      );
    }

    if (requireTestClassPrefix && !element.name.startsWith('TestClass')) {
      throw InvalidGenerationSourceError(
        'All classes must start with `TestClass`.',
        todo: 'Rename the type or remove the `TestAnnotation` from class.',
        element: element,
      );
    }

    yield 'const ${element.name}NameLength = ${element.name.length};';
    yield 'const ${element.name}NameLowerCase = ${element.name.toLowerCase()};';
  }

  @override
  String toString() =>
      'TestGenerator (requireTestClassPrefix:$requireTestClassPrefix)';
}
