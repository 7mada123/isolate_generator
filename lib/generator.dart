// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:isolate_generator_annotation/isolate_generator_annotation.dart';
import 'package:source_gen/source_gen.dart';

import './helpers.dart';
import './isolate_entry_point.dart';
import './isolate_wraper_class.dart';

class IsolateGenerator extends GeneratorForAnnotation<IsolateAnnotation> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        redError(
          'expected ClassElement, found ${element.runtimeType}\n${StackTrace.current}',
        ),
        element: element,
        todo: "only classes can be notated with `generateIsolate`",
      );
    }

    final ClassElement classElement = element;

    final classBuffer = StringBuffer();

    final String isolateFuncName = "_${classElement.name}Isolate".toLowerCase();

    writeIsolateWarperClass(classBuffer, classElement, isolateFuncName);

    writeIsolateEntryPoint(classBuffer, classElement, isolateFuncName);

    return classBuffer.toString();
  }
}
