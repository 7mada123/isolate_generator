import 'package:analyzer/dart/element/element.dart';
import 'shared_isolate_helper.dart';

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

  for (SharedIsolateElement element in elements) {
    final int id = element.id;
    final ClassElement classElement = element.classElement;

    classBuffer.writeln('final ReceivePort port$id = ReceivePort();');

    classBuffer.writeln(
      'final ${classElement.name} instance$id = ${classElement.name}();',
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
    final initMethodIndex = element.classElement.methods.indexWhere(
      (element) => element.name == "init",
    );

    final String initArg = initMethodIndex == -1
        ? ""
        : functionParametersValue(
            element.classElement.methods[initMethodIndex], 2);

    if (initMethodIndex != -1) {
      classBuffer.writeln('try {');
      classBuffer.writeln(
        '${element.classElement.methods[initMethodIndex].returnType.isDartAsyncFuture ? "await " : ""}instance${element.id}.init($initArg);',
      );
      classBuffer.writeln("sendPort.send(port${element.id}.sendPort);");

      classBuffer.writeln('} catch (e,s) {');

      classBuffer.writeln('sendPort.send(IsolateGeneratorError(e,s));');

      classBuffer.writeln('}');
    } else {
      classBuffer.writeln("sendPort.send(port${element.id}.sendPort);");
    }

    /////////
    classBuffer.writeln("break;");
  }
  classBuffer.writeln("}");
  classBuffer.writeln("}");

  classBuffer.writeln('mainPort.listen(mainPortListener);');

  classBuffer.writeln("isolateMainPortSender.send(mainPort.sendPort);");

  classBuffer.writeln('}');
}
