// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:collection';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:isolate_generator_annotation/isolate_generator_annotation.dart';
import 'package:source_gen/source_gen.dart';

import './helpers.dart';
import './isolate_entry_point.dart';
import './isolate_wraper_class.dart';
import './shared_isolate/shared_isolate_entry_point.dart';
import './shared_isolate/shared_isolate_helper.dart';
import './shared_isolate/shared_isolate_wraper_class.dart';

class IsolateGenerator extends GeneratorForAnnotation<GenerateIsolate> {
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

    final isSharedIsolate = annotation.read("_isSharedIsolate").boolValue;

    if (isSharedIsolate) {
      final sharedIsolate = annotation.read("sharedIsolate").objectValue;

      final Set<DartType> sharedInstanse = HashSet();

      for (var field in element.fields)
        for (ElementAnnotation meta in field.metadata)
          if (meta.element?.displayName == "FromIsolate")
            sharedInstanse.add(field.declaration.type);

      final String key = sharedIsolate.getField("isolateId")!.toStringValue()!;
      final SharedIsolateElement sharedIsolateElement =
          SharedIsolateElement.generate(
        classElement: element,
        sharedIsolate: sharedIsolate,
        annotation: annotation,
        sharedInstanse: sharedInstanse,
      );

      final int count = sharedIsolate.getField("classCount")!.toIntValue()!;

      sharedIsolateMap.update(
        key,
        (value) => value..add(sharedIsolateElement),
        ifAbsent: () => [sharedIsolateElement],
      );

      if (sharedIsolateMap[key]!.length == count) {
        final classBuffer = StringBuffer();

        writeSharedIsolateWarperClasses(
          classBuffer,
          sharedIsolateMap[key]!,
          key.toLowerCase(),
        );

        writeSharedIsolateEntryPoint(
          classBuffer,
          sharedIsolateMap[key]!,
          key,
        );

        return classBuffer.toString();
      }

      return "";
    }

    final bool isSameType = annotation.read("isSameType").boolValue;

    final ClassElement classElement = element;

    final classBuffer = StringBuffer();

    final String isolateFuncName = "_${classElement.name}Isolate".toLowerCase();

    writeIsolateWarperClass(
      classBuffer,
      classElement,
      isolateFuncName,
      isSameType,
    );

    writeIsolateEntryPoint(classBuffer, classElement, isolateFuncName);

    return classBuffer.toString();
  }
}
