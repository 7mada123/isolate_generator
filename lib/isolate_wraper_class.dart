// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

import './helpers.dart';

void writeIsolateWarperClass(
  final StringBuffer classBuffer,
  final ClassElement classElement,
  final String isolateFuncName,
  final bool isSameType,
) {
  classBuffer.writeln(
    'class ${classElement.name}Isolate${isSameType ? " extends ${classElement.name}" : ""}{',
  );

  classBuffer.writeln('late final SendPort _sender;');
  classBuffer.writeln('late final Isolate isolate;');

  // init isloate
  if (isSameType) classBuffer.writeln('@override');

  final initMethodIndex = classElement.methods.indexWhere(
    (element) => element.name == "init",
  );

  if (initMethodIndex == -1 && isSameType)
    throw InvalidGenerationSourceError(
      redError('init method not found\n${StackTrace.current}'),
      todo:
          "provide `init` function to initialize the isolate even if the main class don't need initialization",
    );

  final String initArg = initMethodIndex == -1
      ? ""
      : functionParameters(classElement.methods[initMethodIndex]);

  final String isolateControlPortNameServer = "${isolateFuncName}_controlport";

  String initArgList = '';

  if (initMethodIndex != -1)
    for (var par in classElement.methods[initMethodIndex].parameters)
      initArgList += '${par.name},';

  classBuffer.writeln('Future<void> init($initArg) async {');

  classBuffer.writeln(
    'final runningSendPort = IsolateNameServer.lookupPortByName("$isolateFuncName");',
  );

  classBuffer.writeln(' if (runningSendPort != null) {');
  classBuffer.writeln('_sender = runningSendPort;');
  classBuffer.writeln(
      'isolate = Isolate(IsolateNameServer.lookupPortByName("$isolateControlPortNameServer")!);');
  classBuffer.writeln('return;');
  classBuffer.writeln('}');

  /////////////

  classBuffer.writeln('final ReceivePort receivePort = ReceivePort();');

  classBuffer.writeln('final ReceivePort exitRecivePort = ReceivePort();');

  classBuffer.writeln('isolate = await Isolate.spawn<List<dynamic>>(');
  classBuffer.writeln('$isolateFuncName,');
  classBuffer.writeln('[receivePort.sendPort,$initArgList]');
  classBuffer.writeln(');');
  //////
  if (initMethodIndex != -1) {
    classBuffer.writeln('final res = await receivePort.first;');
    classBuffer.writeln('if (res is IsolateGeneratorError) {');
    classBuffer.writeln(
      'Error.throwWithStackTrace(res.error, res.stackTrace);',
    );
    classBuffer.writeln('}');
    classBuffer.writeln(' _sender = res;');
  } else {
    classBuffer.writeln('_sender = await receivePort.first;');
  }
  //////

  classBuffer.writeln('isolate.addOnExitListener(exitRecivePort.sendPort);');

  classBuffer.writeln('exitRecivePort.listen((message) {');
  classBuffer.writeln(
    'IsolateNameServer.removePortNameMapping("$isolateFuncName");',
  );
  classBuffer.writeln(
    'IsolateNameServer.removePortNameMapping("$isolateControlPortNameServer");',
  );
  classBuffer.writeln('exitRecivePort.close();');
  classBuffer.writeln('});');

  classBuffer.writeln(
    'IsolateNameServer.registerPortWithName(_sender, "$isolateFuncName");',
  );

  classBuffer.writeln(
    'IsolateNameServer.registerPortWithName(isolate.controlPort, "$isolateControlPortNameServer");',
  );

  classBuffer.writeln('receivePort.close();');

  classBuffer.writeln('}');
  //init isolate ////////////////

  // class elements warping
  for (var method in classElement.methods) {
    if (method.name == 'init' || method.name.startsWith('_')) continue;

    String argToPass = "'${method.name}',receivePort.sendPort,";

    for (var par in method.parameters) {
      argToPass += "${par.name},";
    }

    final arg = functionParameters(method);

    if (isSameType) classBuffer.writeln('@override');

    if (method.returnType.isDartAsyncStream) {
      classBuffer.writeln('${method.returnType} ${method.name}($arg) {');

      classBuffer.writeln('final receivePort = ReceivePort();');

      classBuffer.writeln('_sender.send(');

      classBuffer.writeln('[$argToPass]');

      classBuffer.writeln(');');

      classBuffer.writeln(
        'final StreamController<${method.returnType.toString().genricType()}> controller = StreamController();',
      );

      classBuffer.writeln('receivePort.listen(');

      classBuffer.writeln('(event) {');

      classBuffer.writeln('if (event is IsolateGeneratorStreamCompleted) {');

      classBuffer.writeln('controller.close();');

      classBuffer.writeln('receivePort.close();');

      classBuffer.writeln('return;');

      classBuffer.writeln('}');

      classBuffer.writeln('if (event is IsolateGeneratorError) {');

      classBuffer.writeln(
        'controller.addError(event.error, event.stackTrace);',
      );

      classBuffer.writeln('controller.close();');

      classBuffer.writeln('receivePort.close();');

      classBuffer.writeln('return;');

      classBuffer.writeln('}');

      classBuffer.writeln('controller.add(event);');

      classBuffer.writeln('},');

      classBuffer.writeln(');');

      classBuffer.writeln('return controller.stream;');
    } else {
      String returnType = method.returnType.toString();

      if (!method.returnType.isDartAsyncFuture) {
        if (isSameType)
          throw InvalidGenerationSourceError(
            redError('Function should return Future<T>\n${StackTrace.current}'),
            todo:
                "Make sure to make the function return a future becasue comuncation with isolates should be asynchronous",
          );

        returnType = "Future<$returnType>";
      }

      classBuffer.writeln(
        '$returnType ${method.name}($arg) async {',
      );

      classBuffer.writeln('final receivePort = ReceivePort();');

      classBuffer.writeln('_sender.send(');

      classBuffer.writeln('[$argToPass]');

      classBuffer.writeln(');');

      classBuffer.writeln('final res = await receivePort.first;');

      classBuffer.writeln('receivePort.close();');

      classBuffer.writeln('if (res is IsolateGeneratorError) {');

      classBuffer.writeln(
        'Error.throwWithStackTrace(res.error, res.stackTrace);',
      );

      classBuffer.writeln('}');

      classBuffer.writeln('return res;');
    }
    classBuffer.writeln('}');
  }

  classBuffer.writeln('}');
}
