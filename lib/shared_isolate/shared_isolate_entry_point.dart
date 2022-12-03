// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:collection';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

import './shared_isolate_element.dart';
import '../helpers.dart';

void writeSharedIsolateEntryPoint(
  final StringBuffer classBuffer,
  final List<SharedIsolateElement> elements,
  final String isolateKey,
) {
  classBuffer.writeln(
    'Future<void> _${isolateKey.toLowerCase()}(final SendPort isolateMainPortSender) async {',
  );

  classBuffer.writeln('final ReceivePort mainPort = ReceivePort();');

  Map<DartType, String> innerInstances = HashMap();

  for (SharedIsolateElement element in elements) {
    final int id = element.id;
    final ClassElement classElement = element.classElement;

    classBuffer.writeln('final ReceivePort port$id = ReceivePort();');

    if (element.sharedInstance.isNotEmpty) {
      // String constr;

      for (ConstructorElement constructor
          in element.classElement.constructors) {
        for (ParameterElement par in constructor.parameters) {
          for (DartType sharedInstance in element.sharedInstance) {
            if (par.type == sharedInstance) {
              String typeStr = par.type.toString();

              if (typeStr[typeStr.length - 1] == "?")
                typeStr = typeStr.substring(0, typeStr.length - 1);

              final int index = elements.indexWhere(
                (element) => element.classElement.name == typeStr,
              );

              if (index == -1) {
                throw InvalidGenerationSourceError(
                  redError('''class not found
                class ${par.type} has been declared as a dependency for class ${element.classElement.name}
                but class ${par.type} not found
                ${StackTrace.current}
                '''),
                  todo: "add ${par.type} class to the shared isolate",
                );
              }

              innerInstances[par.type] = "instance${elements[index].id}";
            }
          }
        }
      }
    }

    classBuffer.writeln(
      'late final ${classElement.name} instance$id;',
    );

    // ///////////////////

    // handeling functions inside the isolate
    classBuffer.writeln('void port${id}Listener(final message) async {');

    classBuffer.writeln('final String key = message[0];');
    classBuffer.writeln('final SendPort sendPort = message[1];');

    classBuffer.writeln('try {');

    classBuffer.writeln('switch (key) {');

    for (var method in classElement.methods) {
      if (method.name == 'init' || method.name.startsWith('_')) continue;

      final bool isFuncVoid = method.returnType.toString().contains('void');
      final String arg = functionParametersValue(method, 2);

      classBuffer.writeln("case '${method.name}':");
      if (method.returnType.isDartAsyncStream) {
        classBuffer.writeln("instance$id.${method.name}($arg).listen((event){");
        classBuffer.writeln('sendPort.send(event);');
        classBuffer.writeln("}, onError: (e,s) {");
        classBuffer.writeln('sendPort.send(IsolateGeneratorError(e,s));');
        classBuffer.writeln('}, onDone: () {');
        classBuffer
            .writeln('sendPort.send(const IsolateGeneratorStreamCompleted());');
        classBuffer.writeln(' });');
      } else {
        classBuffer.writeln(
          '${isFuncVoid ? '' : 'final res = '}${method.isAsynchronous ? "await " : ""}instance$id.${method.name}($arg);',
        );

        if (isFuncVoid) {
          classBuffer.writeln('sendPort.send(null);');
        } else {
          classBuffer.writeln('sendPort.send(res);');
        }
      }

      classBuffer.writeln('break;');
    }

    classBuffer.writeln('}');

    classBuffer.writeln('} catch (e,s) {');

    classBuffer.writeln('sendPort.send(IsolateGeneratorError(e,s));');

    classBuffer.writeln('}');
    classBuffer.writeln('}');
    /////////////////////////////////////////
    classBuffer.writeln('port$id.listen(port${id}Listener);');
  }

  classBuffer.writeln('void mainPortListener(final message) async {');
  classBuffer.writeln("final int id = message[0];");
  classBuffer.writeln("final SendPort sendPort = message[1];");
  classBuffer.writeln("switch (id) {");
  for (SharedIsolateElement element in elements) {
    classBuffer.writeln("case ${element.id}:");
    /////////

    final String constructorsArg = element.classElement.constructors.isNotEmpty
        ? constructorParametersValue(
            element.classElement.constructors.first,
            2,
            replace: innerInstances,
          )
        : "";

    classBuffer.writeln(
      "instance${element.id} = ${element.classElement.name}($constructorsArg);",
    );
    classBuffer.writeln("sendPort.send(port${element.id}.sendPort);");

    /////////
    classBuffer.writeln("break;");
  }
  classBuffer.writeln("}");
  classBuffer.writeln("}");

  classBuffer.writeln('mainPort.listen(mainPortListener);');

  classBuffer.writeln("isolateMainPortSender.send(mainPort.sendPort);");

  classBuffer.writeln('}');
}
