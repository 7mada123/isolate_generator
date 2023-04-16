// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_isolate.dart';

// **************************************************************************
// IsolateGenerator
// **************************************************************************

class MyClassIsolate {
  MyClassIsolate();
  late final SendPort _sender;
  late final Isolate isolate;
  Future<void> init() async {
    final runningSendPort =
        IsolateNameServer.lookupPortByName("_myclassisolate");
    if (runningSendPort != null) {
      _sender = runningSendPort;
      isolate = Isolate(
          IsolateNameServer.lookupPortByName("_myclassisolate_controlport")!);
      return;
    }
    final ReceivePort receivePort = ReceivePort();
    final ReceivePort exitRecivePort = ReceivePort();
    isolate = await Isolate.spawn<List<dynamic>>(
      _myclassisolate,
      [
        receivePort.sendPort,
      ],
      errorsAreFatal: false,
    );
    _sender = await receivePort.first;
    isolate.addOnExitListener(exitRecivePort.sendPort);
    exitRecivePort.listen((message) {
      IsolateNameServer.removePortNameMapping("_myclassisolate");
      IsolateNameServer.removePortNameMapping("_myclassisolate_controlport");
      exitRecivePort.close();
    });
    IsolateNameServer.registerPortWithName(_sender, "_myclassisolate");
    IsolateNameServer.registerPortWithName(
        isolate.controlPort, "_myclassisolate_controlport");
    receivePort.close();
  }

  Future<int> fib(
    int n,
  ) async {
    final receivePort = ReceivePort();
    _sender.send([
      'fib',
      receivePort.sendPort,
      n,
    ]);
    final res = await receivePort.first;
    receivePort.close();
    if (res is IsolateGeneratorError) {
      Error.throwWithStackTrace(res.error, res.stackTrace);
    }
    return res;
  }

  Stream<int> fibStream(
    int n,
  ) {
    final receivePort = ReceivePort();
    _sender.send([
      'fibStream',
      receivePort.sendPort,
      n,
    ]);
    final StreamController<int> controller = StreamController();
    receivePort.listen(
      (event) {
        if (event is IsolateGeneratorStreamCompleted) {
          controller.close();
          receivePort.close();
          return;
        }
        if (event is IsolateGeneratorError) {
          controller.addError(event.error, event.stackTrace);
          controller.close();
          receivePort.close();
          return;
        }
        controller.add(event);
      },
    );
    return controller.stream;
  }

  Stream<void> getStream() {
    final receivePort = ReceivePort();
    _sender.send([
      'getStream',
      receivePort.sendPort,
    ]);
    final StreamController<void> controller = StreamController();
    receivePort.listen(
      (event) {
        if (event is IsolateGeneratorStreamCompleted) {
          controller.close();
          receivePort.close();
          return;
        }
        if (event is IsolateGeneratorError) {
          controller.addError(event.error, event.stackTrace);
          controller.close();
          receivePort.close();
          return;
        }
        controller.add(null);
      },
    );
    return controller.stream;
  }

  Future<int> getPreviousNumber() async {
    final receivePort = ReceivePort();
    _sender.send([
      'getPreviousNumber',
      receivePort.sendPort,
    ]);
    final res = await receivePort.first;
    receivePort.close();
    if (res is IsolateGeneratorError) {
      Error.throwWithStackTrace(res.error, res.stackTrace);
    }
    return res;
  }

  Future<int> geNextNumber() async {
    final receivePort = ReceivePort();
    _sender.send([
      'geNextNumber',
      receivePort.sendPort,
    ]);
    final res = await receivePort.first;
    receivePort.close();
    if (res is IsolateGeneratorError) {
      Error.throwWithStackTrace(res.error, res.stackTrace);
    }
    return res;
  }
}

Future<void> _myclassisolate(final List<dynamic> message) async {
  final ReceivePort port = ReceivePort();
  final MyClass instance = MyClass();
  void mainPortListener(final message) async {
    final String key = message[0];
    final SendPort sendPort = message[1];
    try {
      switch (key) {
        case 'fib':
          final res = instance.fib(
            message[2],
          );
          sendPort.send(res);
          break;
        case 'fibStream':
          instance
              .fibStream(
            message[2],
          )
              .listen((event) {
            sendPort.send(event);
          }, onError: (e, s) {
            sendPort.send(IsolateGeneratorError(e, s));
          }, onDone: () {
            sendPort.send(const IsolateGeneratorStreamCompleted());
          });
          break;
        case 'getStream':
          instance.getStream().listen((event) {
            sendPort.send(null);
          }, onError: (e, s) {
            sendPort.send(IsolateGeneratorError(e, s));
          }, onDone: () {
            sendPort.send(const IsolateGeneratorStreamCompleted());
          });
          break;
        case 'getPreviousNumber':
          final res = instance.getPreviousNumber();
          sendPort.send(res);
          break;
        case 'geNextNumber':
          final res = instance.geNextNumber();
          sendPort.send(res);
          break;
      }
    } catch (e, s) {
      sendPort.send(IsolateGeneratorError(e, s));
    }
  }

  port.listen(mainPortListener);
  message[0].send(port.sendPort);
}
