// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:isolate_generator/shared_isolate/shared_isolate_helper.dart';
import 'package:source_gen/source_gen.dart';

import '../helpers.dart';

void writeSharedIsolateWarperClasses(
  final StringBuffer classBuffer,
  final List<SharedIsolateElement> elements,
  final String isolateKey,
) {
  final StringBuffer removeAll = StringBuffer();

  for (SharedIsolateElement element in elements) {
    removeAll.writeln(
      'IsolateNameServer.removePortNameMapping("${isolateKey}_${element.id}");',
    );
  }

  for (SharedIsolateElement element in elements) {
    classBuffer.writeln(
      'class ${element.classElement.name}Isolate${element.isSameType ? " extends ${element.classElement.name}" : ""}{',
    );

    classBuffer.writeln('late final SendPort _sender;');
    classBuffer.writeln('late final Isolate isolate;');

    // init isloate
    if (element.isSameType) classBuffer.writeln('@override');

    final initMethodIndex = element.classElement.methods.indexWhere(
      (element) => element.name == "init",
    );

    if (initMethodIndex == -1 && element.isSameType)
      throw InvalidGenerationSourceError(
        redError('init method not found\n${StackTrace.current}'),
        todo:
            "provide `init` function to initialize the isolate even if the main class don't need initialization",
      );

    final String initArg = initMethodIndex == -1
        ? ""
        : functionParameters(element.classElement.methods[initMethodIndex]);

    final String isolateControlPortNameServer = "${isolateKey}_controlport",
        classPortNameServer = "${isolateKey}_${element.id}",
        isolateMainSenderNameServer = "${isolateKey}_main_sender";

    String initArgList = '';

    if (initMethodIndex != -1)
      for (var par in element.classElement.methods[initMethodIndex].parameters)
        initArgList += '${par.name},';

    classBuffer.writeln('Future<void> init($initArg) async {');

    // checking if the isolate is alrady running

    // if this class is already initilized
    classBuffer.writeln(
      'final classPort = IsolateNameServer.lookupPortByName("$classPortNameServer");',
    );

    classBuffer.writeln("if (classPort != null) {");
    classBuffer.writeln('_sender = classPort;');
    classBuffer.writeln(
      'isolate = Isolate(IsolateNameServer.lookupPortByName("$isolateControlPortNameServer")!);',
    );
    classBuffer.writeln("return;");
    classBuffer.writeln("}");
    //////////////////////////////////////
    // check if isolate is already initilized otherwise initlized it
    classBuffer.writeln(
      'final isolateControllerPort = IsolateNameServer.lookupPortByName("$isolateControlPortNameServer");',
    );
    classBuffer.writeln(
      'late final SendPort isolateMainSender;',
    );
    classBuffer.writeln('if (isolateControllerPort != null) {');
    classBuffer.writeln(
      'isolate = Isolate(IsolateNameServer.lookupPortByName("$isolateControlPortNameServer")!);',
    );
    classBuffer.writeln(
      'isolateMainSender = IsolateNameServer.lookupPortByName("$isolateMainSenderNameServer")!;',
    );
    classBuffer.writeln("} else {");
    classBuffer.writeln(
      'final ReceivePort mainSenderReceivePort = ReceivePort();',
    );
    classBuffer.writeln(
      'isolate = await Isolate.spawn<SendPort>(_$isolateKey,mainSenderReceivePort.sendPort);',
    );
    classBuffer.writeln(
      'isolateMainSender = await mainSenderReceivePort.first;',
    );
    classBuffer.writeln('mainSenderReceivePort.close();');
    classBuffer.writeln(
      'IsolateNameServer.registerPortWithName(isolateMainSender, "$isolateMainSenderNameServer");',
    );
    classBuffer.writeln(
      'IsolateNameServer.registerPortWithName(isolate.controlPort, "$isolateControlPortNameServer");',
    );

    classBuffer.writeln(
      "final ReceivePort mainExitRecivePort = ReceivePort();",
    );

    classBuffer.writeln(
      "isolate.addOnExitListener(mainExitRecivePort.sendPort);",
    );

    classBuffer.writeln("mainExitRecivePort.listen((message) {");
    classBuffer.writeln(
      'IsolateNameServer.removePortNameMapping("$isolateMainSenderNameServer");',
    );
    classBuffer.writeln(
      'IsolateNameServer.removePortNameMapping("$isolateControlPortNameServer");',
    );
    classBuffer.write(removeAll);
    classBuffer.writeln(" mainExitRecivePort.close();");
    classBuffer.writeln("});");

    classBuffer.writeln("}");
    //////////////////////////////////////
    // class initlize in isolate
    classBuffer.writeln(
      "final ReceivePort classRecivePort = ReceivePort();",
    );

    classBuffer.writeln(
      "isolateMainSender.send([${element.id},classRecivePort.sendPort,$initArgList]);",
    );

    if (initMethodIndex != -1) {
      classBuffer.writeln("final res = await classRecivePort.first;");

      classBuffer.writeln('if (res is IsolateGeneratorError) {');
      classBuffer.writeln(
        'Error.throwWithStackTrace(res.error, res.stackTrace);',
      );
      classBuffer.writeln('}');
      classBuffer.writeln(' _sender = res;');
    } else {
      classBuffer.writeln("_sender = await classRecivePort.first;");
    }

    classBuffer.writeln("classRecivePort.close();");

    classBuffer.writeln(
      'IsolateNameServer.registerPortWithName(_sender, "$classPortNameServer");',
    );

    classBuffer.writeln('}');
    //init isolate ////////////////

    // class elements warping
    for (var method in element.classElement.methods) {
      if (method.name == 'init' || method.name.startsWith('_')) continue;

      String argToPass = "'${method.name}',receivePort.sendPort,";

      for (var par in method.parameters) {
        argToPass += "${par.name},";
      }

      final arg = functionParameters(method);

      if (element.isSameType) classBuffer.writeln('@override');

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
          if (element.isSameType)
            throw InvalidGenerationSourceError(
              redError(
                  'Function should return Future<T>\n${StackTrace.current}'),
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
}
