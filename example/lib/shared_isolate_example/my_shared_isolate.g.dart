// GENERATED CODE - DO NOT MODIFY BY HAND

part of my_shared_isolate;

// **************************************************************************
// IsolateGenerator
// **************************************************************************

class FirstIsolate {
  final String _val;
  final int? _count;

  FirstIsolate(
    String val,
    int? count,
  )   : _val = val,
        _count = count;
  late final SendPort _sender;
  late final Isolate isolate;
  Future<void> init() async {
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
      isolate = Isolate(isolateControllerPort);
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
        IsolateNameServer.removePortNameMapping("mysharedisolate_3");
        mainExitRecivePort.close();
      });
    }
    final ReceivePort classRecivePort = ReceivePort();
    isolateMainSender.send([
      1,
      classRecivePort.sendPort,
      _val,
      _count,
    ]);
    _sender = await classRecivePort.first;
    classRecivePort.close();
    IsolateNameServer.registerPortWithName(_sender, "mysharedisolate_1");
  }

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

class SecoundIsolate extends Secound {
  final String _path;

  SecoundIsolate(
    String path,
  )   : _path = path,
        super(
          path,
        );
  late final SendPort _sender;
  late final Isolate isolate;
  Future<void> init() async {
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
      isolate = Isolate(isolateControllerPort);
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
        IsolateNameServer.removePortNameMapping("mysharedisolate_3");
        mainExitRecivePort.close();
      });
    }
    final ReceivePort classRecivePort = ReceivePort();
    isolateMainSender.send([
      2,
      classRecivePort.sendPort,
      _path,
    ]);
    _sender = await classRecivePort.first;
    classRecivePort.close();
    IsolateNameServer.registerPortWithName(_sender, "mysharedisolate_2");
  }

  @override
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

class ThridIsolate {
  final int _id;

  ThridIsolate({
    required int id,
  }) : _id = id;
  late final SendPort _sender;
  late final Isolate isolate;
  Future<void> init() async {
    final classPort = IsolateNameServer.lookupPortByName("mysharedisolate_3");
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
      isolate = Isolate(isolateControllerPort);
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
        IsolateNameServer.removePortNameMapping("mysharedisolate_3");
        mainExitRecivePort.close();
      });
    }
    final ReceivePort classRecivePort = ReceivePort();
    isolateMainSender.send([
      3,
      classRecivePort.sendPort,
      _id,
    ]);
    _sender = await classRecivePort.first;
    classRecivePort.close();
    IsolateNameServer.registerPortWithName(_sender, "mysharedisolate_3");
  }

  Future<void> initOtherIsolate() async {
    final receivePort = ReceivePort();
    _sender.send([
      'initOtherIsolate',
      receivePort.sendPort,
    ]);
    final res = await receivePort.first;
    receivePort.close();
    if (res is IsolateGeneratorError) {
      Error.throwWithStackTrace(res.error, res.stackTrace);
    }
    return res;
  }

  Future<void> printValue(
    int n,
  ) async {
    final receivePort = ReceivePort();
    _sender.send([
      'printValue',
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
}

Future<void> _mysharedisolate(final SendPort isolateMainPortSender) async {
  final ReceivePort mainPort = ReceivePort();
  final ReceivePort port1 = ReceivePort();
  late final First instance1;
  void port1Listener(final message) async {
    final String key = message[0];
    final SendPort sendPort = message[1];
    try {
      switch (key) {
        case 'multiply':
          final res = instance1.multiply(
            message[2],
          );
          sendPort.send(res);
          break;
        case 'contact':
          final res = instance1.contact(
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
  late final Secound instance2;
  void port2Listener(final message) async {
    final String key = message[0];
    final SendPort sendPort = message[1];
    try {
      switch (key) {
        case 'createFile':
          await instance2.createFile(
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
  final ReceivePort port3 = ReceivePort();
  late final Thrid instance3;
  void port3Listener(final message) async {
    final String key = message[0];
    final SendPort sendPort = message[1];
    try {
      switch (key) {
        case 'initOtherIsolate':
          await instance3.initOtherIsolate();
          sendPort.send(null);
          break;
        case 'printValue':
          await instance3.printValue(
            message[2],
          );
          sendPort.send(null);
          break;
      }
    } catch (e, s) {
      sendPort.send(IsolateGeneratorError(e, s));
    }
  }

  port3.listen(port3Listener);
  void mainPortListener(final message) async {
    final int id = message[0];
    final SendPort sendPort = message[1];
    switch (id) {
      case 1:
        instance1 = First(
          message[2],
          message[3],
        );
        sendPort.send(port1.sendPort);
        break;
      case 2:
        instance2 = Secound(
          message[2],
        );
        sendPort.send(port2.sendPort);
        break;
      case 3:
        instance3 = Thrid(
          id: message[2],
          first: instance1,
        );
        sendPort.send(port3.sendPort);
        break;
    }
  }

  mainPort.listen(mainPortListener);
  isolateMainPortSender.send(mainPort.sendPort);
}
