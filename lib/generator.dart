// ignore: depend_on_referenced_packages
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:isolate_generator_annotation/isolate_generator_annotation.dart';
import 'package:source_gen/source_gen.dart';

class IsolateGenerator extends GeneratorForAnnotation<IsolateAnnotation> {
  @override
  String generateForAnnotatedElement(
      Element e, ConstantReader annotation, BuildStep buildStep) {
    if (e is! ClassElement) {
      throw Exception('expected ClassElement, found ${e.runtimeType}');
    }

    final ClassElement element = e;

    final className = '${element.name}Isolate';

    final classBuffer = StringBuffer();

    classBuffer
        .writeln('Future<void> _isolateEntry(final SendPort sendPort) async {');
    classBuffer.writeln('}');

    classBuffer.writeln('class $className {');

    classBuffer.writeln('final ${element.name} instance = ${element.name}();');

    classBuffer.writeln('late final SendPort sender;');

    // init isloate
    classBuffer.writeln('Future<void> init() async {');

    classBuffer.writeln('final ReceivePort receivePort = ReceivePort();');
    classBuffer.writeln('await Isolate.spawn<SendPort>(');
    // TODO isolate entry point functions
    classBuffer.writeln('_isolateEntry,');
    classBuffer.writeln('receivePort.sendPort,');
    classBuffer.writeln(');');
    classBuffer.writeln('sender = await receivePort.first;');
    classBuffer.writeln('receivePort.close();');

    classBuffer.writeln('}');
    //init isolate ////////////////

    classBuffer.writeln('}');

    return classBuffer.toString();
  }
}
