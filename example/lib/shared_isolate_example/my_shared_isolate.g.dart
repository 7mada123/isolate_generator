// GENERATED CODE - DO NOT MODIFY BY HAND

part of my_shared_isolate;

// **************************************************************************
// IsolateGenerator
// **************************************************************************

class FirstIsolate extends First {
  late final SendPort _sender;
  late final Isolate isolate;
  @override
  Future<void> init(
    String val, {
    int? count,
  }) async {
    final classPort = IsolateNameServer.lookupPortByName("mysharedisolate_1");
    if (classPort != null) {
      _sender = classPort;
      isolate = Isolate(
          IsolateNameServer.lookupPortByName("mysharedisolate_controlport")!);
      return;
    }
    final isolateControllerPort =
        IsolateNameServer.lookupPortByName("mysharedisolate_controlport");
    late final SendPort isolateMainSender;
    if (isolateControllerPort != null) {
      isolate = Isolate(
          IsolateNameServer.lookupPortByName("mysharedisolate_controlport")!);
      isolateMainSender =
          IsolateNameServer.lookupPortByName("mysharedisolate_main_sender")!;
    } else {
      final ReceivePort mainSenderReceivePort = ReceivePort();
      isolate = await Isolate.spawn<SendPort>(
          _mysharedisolate, mainSenderReceivePort.sendPort);
      isolateMainSender = await mainSenderReceivePort.first;
      mainSenderReceivePort.close();
      IsolateNameServer.registerPortWithName(
          isolateMainSender, "mysharedisolate_main_sender");
      IsolateNameServer.registerPortWithName(
          isolate.controlPort, "mysharedisolate_controlport");
      final ReceivePort mainExitRecivePort = ReceivePort();
      isolate.addOnExitListener(mainExitRecivePort.sendPort);
      mainExitRecivePort.listen((message) {
        IsolateNameServer.removePortNameMapping("mysharedisolate_main_sender");
        IsolateNameServer.removePortNameMapping("mysharedisolate_controlport");
        IsolateNameServer.removePortNameMapping("mysharedisolate_1");
        IsolateNameServer.removePortNameMapping("mysharedisolate_2");
        mainExitRecivePort.close();
      });
    }
    final ReceivePort classRecivePort = ReceivePort();
    isolateMainSender.send([
      1,
      classRecivePort.sendPort,
      val,
      count,
    ]);
    _sender = await classRecivePort.first;
    classRecivePort.close();
    IsolateNameServer.registerPortWithName(_sender, "mysharedisolate_1");
  }

  @override
  Future<int> multiply(
    int newVal,
  ) async {
    final receivePort = ReceivePort();
    _sender.send([
      'multiply',
      receivePort.sendPort,
      newVal,
    ]);
    final res = await receivePort.first;
    receivePort.close();
    if (res is IsolateGeneratorError) {
      Error.throwWithStackTrace(res.error, res.stackTrace);
    }
    return res;
  }

  @override
  Future<String> contact(
    String newString, {
    bool atEnd = false,
  }) async {
    final receivePort = ReceivePort();
    _sender.send([
      'contact',
      receivePort.sendPort,
      newString,
      atEnd,
    ]);
    final res = await receivePort.first;
    receivePort.close();
    if (res is IsolateGeneratorError) {
      Error.throwWithStackTrace(res.error, res.stackTrace);
    }
    return res;
  }
}

class SecoundIsolate {
  late final SendPort _sender;
  late final Isolate isolate;
  Future<void> init({
    required String path,
  }) async {
    final classPort = IsolateNameServer.lookupPortByName("mysharedisolate_2");
    if (classPort != null) {
      _sender = classPort;
      isolate = Isolate(
          IsolateNameServer.lookupPortByName("mysharedisolate_controlport")!);
      return;
    }
    final isolateControllerPort =
        IsolateNameServer.lookupPortByName("mysharedisolate_controlport");
    late final SendPort isolateMainSender;
    if (isolateControllerPort != null) {
      isolate = Isolate(
          IsolateNameServer.lookupPortByName("mysharedisolate_controlport")!);
      isolateMainSender =
          IsolateNameServer.lookupPortByName("mysharedisolate_main_sender")!;
    } else {
      final ReceivePort mainSenderReceivePort = ReceivePort();
      isolate = await Isolate.spawn<SendPort>(
          _mysharedisolate, mainSenderReceivePort.sendPort);
      isolateMainSender = await mainSenderReceivePort.first;
      mainSenderReceivePort.close();
      IsolateNameServer.registerPortWithName(
          isolateMainSender, "mysharedisolate_main_sender");
      IsolateNameServer.registerPortWithName(
          isolate.controlPort, "mysharedisolate_controlport");
      final ReceivePort mainExitRecivePort = ReceivePort();
      isolate.addOnExitListener(mainExitRecivePort.sendPort);
      mainExitRecivePort.listen((message) {
        IsolateNameServer.removePortNameMapping("mysharedisolate_main_sender");
        IsolateNameServer.removePortNameMapping("mysharedisolate_controlport");
        IsolateNameServer.removePortNameMapping("mysharedisolate_1");
        IsolateNameServer.removePortNameMapping("mysharedisolate_2");
        mainExitRecivePort.close();
      });
    }
    final ReceivePort classRecivePort = ReceivePort();
    isolateMainSender.send([
      2,
      classRecivePort.sendPort,
      path,
    ]);
    _sender = await classRecivePort.first;
    classRecivePort.close();
    IsolateNameServer.registerPortWithName(_sender, "mysharedisolate_2");
  }

  Future<void> createFile(
    String fileName,
  ) async {
    final receivePort = ReceivePort();
    _sender.send([
      'createFile',
      receivePort.sendPort,
      fileName,
    ]);
    final res = await receivePort.first;
    receivePort.close();
    if (res is IsolateGeneratorError) {
      Error.throwWithStackTrace(res.error, res.stackTrace);
    }
    return res;
  }
}

Future<void> _mysharedisolate(final SendPort isolateMainPortSender) async {
  final ReceivePort mainPort = ReceivePort();
  final ReceivePort port1 = ReceivePort();
  final First instance1 = First();
  void port1Listener(final message) async {
    final String key = message[0];
    final SendPort sendPort = message[1];
    try {
      switch (key) {
        case 'multiply':
          final res = await instance1.multiply(
            message[2],
          );
          sendPort.send(res);
          break;
        case 'contact':
          final res = await instance1.contact(
            message[2],
            atEnd: message[3],
          );
          sendPort.send(res);
          break;
      }
    } catch (e, s) {
      sendPort.send(IsolateGeneratorError(e, s));
    }
  }

  port1.listen(port1Listener);
  final ReceivePort port2 = ReceivePort();
  final Secound instance2 = Secound();
  void port2Listener(final message) async {
    final String key = message[0];
    final SendPort sendPort = message[1];
    try {
      switch (key) {
        case 'createFile':
          instance2.createFile(
            message[2],
          );
          sendPort.send(null);
          break;
      }
    } catch (e, s) {
      sendPort.send(IsolateGeneratorError(e, s));
    }
  }

  port2.listen(port2Listener);
  void mainPortListener(final message) async {
    final int id = message[0];
    final SendPort sendPort = message[1];
    switch (id) {
      case 1:
        await instance1.init(
          message[2],
          count: message[3],
        );
        sendPort.send(port1.sendPort);
        break;
      case 2:
        instance2.init(
          path: message[2],
        );
        sendPort.send(port2.sendPort);
        break;
    }
  }

  mainPort.listen(mainPortListener);
  isolateMainPortSender.send(mainPort.sendPort);
}
