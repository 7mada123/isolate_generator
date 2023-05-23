// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

import './helpers.dart';

void writeIsolateWarperClass(
  final StringBuffer classBuffer,
  final ClassElement classElement,
  final String isolateFuncName,
  final bool isSameType,
  final bool errorsAreFatal,
) {
  classBuffer.writeln(
    'class ${classElement.name}Isolate${isSameType ? " extends ${classElement.name}" : ""}{',
  );

  classBuffer.writeln(constructorFileds(
    classElement.constructors.first,
  ));

  if (isSameType) {
    classBuffer.writeln(
      "${classElement.name}Isolate${constructorParametersSameType(classElement.constructors.first)};",
    );
  } else {
    classBuffer.writeln(
      "${classElement.name}Isolate${constructorParameters(classElement.constructors.first)};",
    );
  }

  classBuffer.writeln('late final SendPort _sender;');
  classBuffer.writeln('late final Isolate isolate;');

  final String isolateControlPortNameServer = "${isolateFuncName}_controlport";

  classBuffer.writeln('Future<void> init() async {');

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
  classBuffer.writeln(
      '[receivePort.sendPort,${constructorParametersValueList(classElement.constructors.first)}],errorsAreFatal: $errorsAreFatal,');
  classBuffer.writeln(');');

  classBuffer.writeln('_sender = await receivePort.first;');

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

  final List<MethodElement> methods = [];

  methods.addAll(classElement.methods);

  for (InterfaceType mixinClass in classElement.mixins)
    methods.addAll(mixinClass.methods);

  for (InterfaceType mixinClass in classElement.interfaces)
    methods.addAll(mixinClass.methods);

  // if (classElement.supertype != null)
  //   methods.addAll(classElement.supertype!.methods);

  // class elements warping
  for (var method in methods) {
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

      classBuffer.writeln(
          'controller.add(${method.returnType.toString() == "Stream<void>" ? "null" : "event"});');

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
