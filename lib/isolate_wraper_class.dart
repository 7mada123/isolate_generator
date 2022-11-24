// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

import './helpers.dart';

void writeIsolateWarperClass(
  final StringBuffer classBuffer,
  final ClassElement classElement,
  final String isolateFuncName,
) {
  classBuffer.writeln(
    'class ${classElement.name}Isolate extends ${classElement.name}{',
  );

  classBuffer.writeln('late final SendPort _sender;');
  classBuffer.writeln('late final Isolate isolate;');

  // init isloate
  classBuffer.writeln('@override');

  final initMethod = classElement.methods.firstWhere(
    (element) => element.name == "init",
    orElse: () => throw InvalidGenerationSourceError(
      redError('init method not found\n${StackTrace.current}'),
      todo:
          "provide `init` function to initialize the isolate even if the main class don't need initialization",
    ),
  );

  final String initArg = functionParameters(initMethod);

  final String isolateControlPortNameServer = "${isolateFuncName}_controlport";

  String initArgList = '';

  for (var par in initMethod.parameters) initArgList += '${par.name},';

  classBuffer.writeln('Future<void> init($initArg) async {');

  // checking if the isolate is alrady running
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

  classBuffer.writeln(
    'final ReceivePort receivePort = ReceivePort(), exitRecivePort = ReceivePort();',
  );
  classBuffer.writeln('isolate = await Isolate.spawn<List<dynamic>>(');
  classBuffer.writeln('$isolateFuncName,');
  classBuffer.writeln('[receivePort.sendPort,$initArgList]');
  classBuffer.writeln(');');

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

  classBuffer.writeln('_sender = await receivePort.first;');
  classBuffer.writeln(
    'IsolateNameServer.registerPortWithName(_sender, "$isolateFuncName");',
  );
  classBuffer.writeln(
      'IsolateNameServer.registerPortWithName(isolate.controlPort, "$isolateControlPortNameServer");');
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

    classBuffer.writeln('@override');
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

      classBuffer.writeln('controller.addError(event.error);');

      classBuffer.writeln('controller.close();');

      classBuffer.writeln('receivePort.close();');

      classBuffer.writeln('return;');

      classBuffer.writeln('}');

      classBuffer.writeln('controller.add(event);');

      classBuffer.writeln('},');

      classBuffer.writeln(');');

      classBuffer.writeln('return controller.stream;');
    } else {
      classBuffer.writeln(
        '${method.returnType} ${method.name}($arg) async {',
      );

      classBuffer.writeln('final receivePort = ReceivePort();');

      classBuffer.writeln('_sender.send(');

      classBuffer.writeln('[$argToPass]');

      classBuffer.writeln(');');

      classBuffer.writeln('final res = await receivePort.first;');

      classBuffer.writeln('receivePort.close();');

      classBuffer.writeln('if (res is IsolateGeneratorError) {');

      classBuffer.writeln('throw res.error;');

      classBuffer.writeln('}');

      classBuffer.writeln('return res;');
    }
    classBuffer.writeln('}');
  }

  classBuffer.writeln('}');
}
