// ignore: depend_on_referenced_packages
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:isolate_generator_annotation/isolate_generator_annotation.dart';
import 'package:source_gen/source_gen.dart';

class IsolateGenerator extends GeneratorForAnnotation<IsolateAnnotation> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw Exception('expected ClassElement, found ${element.runtimeType}');
    }

    final ClassElement classElement = element;

    final classBuffer = StringBuffer();

    _writeIsolateWarperClass(classBuffer, classElement);

    _writeIsolateEntryPoint(classBuffer, classElement);

    return classBuffer.toString();
  }

  void _writeIsolateEntryPoint(
    final StringBuffer classBuffer,
    final ClassElement classElement,
  ) {
    classBuffer.writeln(
      'Future<void> _isolateEntry(final List<dynamic> message) async {',
    );
    classBuffer.writeln('final ReceivePort port = ReceivePort();');
    // TODO
    // logic before sending the port
    classBuffer.writeln(
      'final ${classElement.name} instance = ${classElement.name}();',
    );

    final initMethod = classElement.methods.firstWhere(
      (element) => element.name == "init",
    );

    String initArg = "";
    int messageIndex = 1;

    for (var par in initMethod.parameters) {
      initArg +=
          "${par.isNamed ? '${par.name}: ' : ''}message[${messageIndex++}],";
    }

    classBuffer.writeln('await instance.init($initArg);');

    // ///////////////////
    classBuffer.writeln('message[0].send(port.sendPort);');

    // handeling functions inside the isolate
    classBuffer.writeln('port.listen((final message) async {');

    classBuffer.writeln('final String key = message[0];');
    classBuffer.writeln('final SendPort sendPort = message[1];');

    classBuffer.writeln('switch (key) {');

    for (var method in classElement.methods) {
      if (method.name == 'init' || method.name.startsWith('_')) continue;

      String arg = "";
      int messageIndex = 2;
      final bool isFuncVoid = method.returnType.toString().contains('void');

      for (var par in method.parameters) {
        arg += par.isNamed
            ? "${par.name}:message[${messageIndex++}],"
            : "message[${messageIndex++}],";
      }

      classBuffer.writeln("case '${method.name}':");
      classBuffer.writeln(
        '${isFuncVoid ? '' : 'final res = '}${method.isAsynchronous ? "await " : ""}instance.${method.name}($arg);',
      );

      if (isFuncVoid) {
        classBuffer.writeln('sendPort.send(null);');
      } else {
        classBuffer.writeln('sendPort.send(res);');
      }

      classBuffer.writeln('break;');
    }

    classBuffer.writeln('}');
    classBuffer.writeln('}');
    classBuffer.writeln(');');

    classBuffer.writeln('}');
  }

  void _writeIsolateWarperClass(
    final StringBuffer classBuffer,
    final ClassElement classElement,
  ) {
    classBuffer.writeln(
        'class ${classElement.name}Isolate extends ${classElement.name}{');

    classBuffer.writeln('late final SendPort sender;');

    // init isloate
    classBuffer.writeln('@override');
    // TODO input || message

    final initMethod = classElement.methods.firstWhere(
      (element) => element.name == "init",
    );

    final String initArg = functionParameters(initMethod);

    classBuffer.writeln('Future<void> init($initArg) async {');

    classBuffer.writeln('final ReceivePort receivePort = ReceivePort();');
    classBuffer.writeln('await Isolate.spawn<List<dynamic>>(');
    classBuffer.writeln('_isolateEntry,');
    // TODO send list
    classBuffer.writeln('[receivePort.sendPort,]');
    classBuffer.writeln(');');
    classBuffer.writeln('sender = await receivePort.first;');
    classBuffer.writeln('receivePort.close();');

    classBuffer.writeln('}');
    //init isolate ////////////////

    // class elements warping
    for (var method in classElement.methods) {
      if (!method.returnType.isDartAsyncFuture) {
        throw Exception("${method.name} is not a Future");
      }

      if (method.name == 'init' || method.name.startsWith('_')) continue;

      String argToPass = "'${method.name}',receivePort.sendPort,";

      for (var par in method.parameters) {
        argToPass += "${par.name},";
      }

      final arg = functionParameters(method);

      classBuffer.writeln('@override');
      classBuffer.writeln(
        '${method.returnType} ${method.name}($arg) async {',
      );

      classBuffer.writeln('final receivePort = ReceivePort();');

      classBuffer.writeln('sender.send(');

      classBuffer.writeln('[$argToPass]');

      classBuffer.writeln(');');

      classBuffer.writeln('final res = await receivePort.first;');

      classBuffer.writeln('receivePort.close();');

      classBuffer.writeln('return res;');

      classBuffer.writeln('}');
    }

    classBuffer.writeln('}');
  }

  String functionParameters(final MethodElement methodElement) {
    String arg = "";
    bool hasNamed = false;

    for (var par in methodElement.parameters) {
      if (par.isNamed && !hasNamed) {
        hasNamed = true;
        arg += "{";
      }

      arg +=
          "${(hasNamed && par.isRequired) ? 'required ' : ''}${par.type} ${par.name}${par.hasDefaultValue ? ' = ${par.defaultValueCode}' : ''},";
    }

    if (hasNamed) arg += "}";

    return arg;
  }
}
