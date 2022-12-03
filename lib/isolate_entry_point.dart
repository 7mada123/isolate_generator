import 'package:analyzer/dart/element/element.dart';

import 'helpers.dart';

void writeIsolateEntryPoint(
  final StringBuffer classBuffer,
  final ClassElement classElement,
  final String isolateFuncName,
) {
  classBuffer.writeln(
    'Future<void> $isolateFuncName(final List<dynamic> message) async {',
  );
  classBuffer.writeln('final ReceivePort port = ReceivePort();');
  // logic before sending the port

  final String constructorsArg = classElement.constructors.isNotEmpty
      ? constructorParametersValue(
          classElement.constructors.first,
          1,
        )
      : "";

  classBuffer.writeln(
    'final ${classElement.name} instance = ${classElement.name}($constructorsArg);',
  );

  classBuffer.writeln('message[0].send(port.sendPort);');

  // handeling functions inside the isolate
  classBuffer.writeln('void mainPortListener(final message) async {');

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
      classBuffer.writeln("instance.${method.name}($arg).listen((event){");
      classBuffer.writeln('sendPort.send(event);');
      classBuffer.writeln("}, onError: (e,s) {");
      classBuffer.writeln('sendPort.send(IsolateGeneratorError(e,s));');
      classBuffer.writeln('}, onDone: () {');
      classBuffer
          .writeln('sendPort.send(const IsolateGeneratorStreamCompleted());');
      classBuffer.writeln(' });');
    } else {
      classBuffer.writeln(
        '${isFuncVoid ? '' : 'final res = '}${method.isAsynchronous ? "await " : ""}instance.${method.name}($arg);',
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
  classBuffer.writeln('port.listen(mainPortListener);');

  classBuffer.writeln('}');
}
