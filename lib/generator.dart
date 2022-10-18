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

    final String isolateFuncName = "_${classElement.name}Isolate".toLowerCase();

    _writeIsolateWarperClass(classBuffer, classElement, isolateFuncName);

    _writeIsolateEntryPoint(classBuffer, classElement, isolateFuncName);

    return classBuffer.toString();
  }

  void _writeIsolateEntryPoint(
    final StringBuffer classBuffer,
    final ClassElement classElement,
    final String isolateFuncName,
  ) {
    classBuffer.writeln(
      'Future<void> $isolateFuncName(final List<dynamic> message) async {',
    );
    classBuffer.writeln('final ReceivePort port = ReceivePort();');
    // logic before sending the port
    classBuffer.writeln(
      'final ${classElement.name} instance = ${classElement.name}();',
    );

    final initMethod = classElement.methods.firstWhere(
      (element) => element.name == "init",
    );

    final String initArg = functionParametersValue(initMethod, 1);

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

      final bool isFuncVoid = method.returnType.toString().contains('void');
      final String arg = functionParametersValue(method, 2);

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
    final String isolateFuncName,
  ) {
    classBuffer.writeln(
      'class ${classElement.name}Isolate extends ${classElement.name}{',
    );

    classBuffer.writeln('late final SendPort sender;');

    // init isloate
    classBuffer.writeln('@override');

    final initMethod = classElement.methods.firstWhere(
      (element) => element.name == "init",
      orElse: () => throw Exception(
        "init method not found\nStackTrace.current",
      ),
    );

    final String initArg = functionParameters(initMethod);

    String initArgList = '';

    for (var par in initMethod.parameters) initArgList += '${par.name},';

    classBuffer.writeln('Future<void> init($initArg) async {');

    classBuffer.writeln('final ReceivePort receivePort = ReceivePort();');
    classBuffer.writeln('await Isolate.spawn<List<dynamic>>(');
    classBuffer.writeln('$isolateFuncName,');
    classBuffer.writeln('[receivePort.sendPort,$initArgList]');
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

  // copy the function input params, same as the ClassElement method
  String functionParameters(final MethodElement method) {
    String arg = "";
    bool hasNamed = false;

    for (var par in method.parameters) {
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

  // getting the function params values
  String functionParametersValue(final MethodElement method, int messageIndex) {
    String arg = "";

    for (var par in method.parameters) {
      arg += par.isNamed
          ? "${par.name}:message[${messageIndex++}],"
          : "message[${messageIndex++}],";
    }

    return arg;
  }
}
