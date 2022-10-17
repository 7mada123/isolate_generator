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

    _writeIsolateEntryPoint(classBuffer, classElement);

    _writeIsolateWarperClass(classBuffer, classElement);

    return classBuffer.toString();
  }

  void _writeIsolateEntryPoint(
    final StringBuffer classBuffer,
    final ClassElement classElement,
  ) {
    classBuffer.writeln(
      'Future<void> _isolateEntry(final SendPort sendPort) async {',
    );
    classBuffer.writeln('final ReceivePort port = ReceivePort();');
    // TODO
    // logic before sending the port
    classBuffer.writeln(
      'final ${classElement.name} instance = ${classElement.name}();',
    );

    classBuffer.writeln('await instance.init();');

    // ///////////////////
    classBuffer.writeln('sendPort.send(port.sendPort);');

    // handeling functions inside the isolate
    classBuffer.writeln('port.listen((final message) async {');

    classBuffer.writeln('final String key = message[0];');
    classBuffer.writeln('final SendPort sendPort = message[1];');

    classBuffer.writeln('switch (key) {');

    for (var method in classElement.methods) {
      if (method.name == 'init') continue;

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
    classBuffer.writeln('class ${classElement.name}Isolate {');

    classBuffer.writeln('late final SendPort sender;');

    // init isloate
    classBuffer.writeln('Future<void> init() async {');

    classBuffer.writeln('final ReceivePort receivePort = ReceivePort();');
    classBuffer.writeln('await Isolate.spawn<SendPort>(');
    classBuffer.writeln('_isolateEntry,');
    classBuffer.writeln('receivePort.sendPort,');
    classBuffer.writeln(');');
    classBuffer.writeln('sender = await receivePort.first;');
    classBuffer.writeln('receivePort.close();');

    classBuffer.writeln('}');
    //init isolate ////////////////

    // class elements warping
    for (var method in classElement.methods) {
      if (method.name == 'init') continue;

      String arg = "", argToPass = "'${method.name}',receivePort.sendPort,";

      bool hasRequired = false;

      for (var par in method.parameters) {
        if (par.isNamed && par.isRequired && !hasRequired) {
          hasRequired = true;
          arg += '{';
        }

        arg += par.isNamed
            ? "${par.isRequired ? 'required ' : ''}${par.type} ${par.name},"
            : "${par.type} ${par.name},";

        argToPass += "${par.name},";
      }

      if (hasRequired) arg += '}';

      classBuffer.writeln(
        '${method.returnType.isDartAsyncFuture ? method.returnType : "Future<${method.returnType}>"} ${method.name}($arg) async {',
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
}
