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

  String initArgList = '';

  for (var par in initMethod.parameters) initArgList += '${par.name},';

  classBuffer.writeln('Future<void> init($initArg) async {');

  classBuffer.writeln('final ReceivePort receivePort = ReceivePort();');
  classBuffer.writeln('await Isolate.spawn<List<dynamic>>(');
  classBuffer.writeln('$isolateFuncName,');
  classBuffer.writeln('[receivePort.sendPort,$initArgList]');
  classBuffer.writeln(');');
  classBuffer.writeln('_sender = await receivePort.first;');
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
