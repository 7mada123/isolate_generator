import 'dart:collection';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

final Map<String, List<SharedIsolateElement>> sharedIsolateMap = HashMap();

class SharedIsolateElement {
  final ClassElement classElement;
  final int id;
  final bool isSameType;
  final Set<DartType> sharedInstance;

  const SharedIsolateElement(
    this.classElement,
    this.id,
    this.isSameType,
    this.sharedInstance,
  );

  factory SharedIsolateElement.generate({
    required final ClassElement classElement,
    required final DartObject sharedIsolate,
    required final ConstantReader annotation,
    required final Set<DartType> sharedInstanse,
  }) {
    return SharedIsolateElement(
      classElement,
      sharedIsolate.getField("classId")!.toIntValue()!,
      annotation.read("isSameType").boolValue,
      sharedInstanse,
    );
  }
}
