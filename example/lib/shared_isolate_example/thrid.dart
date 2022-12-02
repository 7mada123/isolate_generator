part of my_shared_isolate;

// isolates communications example
@GenerateIsolate(sharedIsolate: SharedIsolate(3, _classCount, _isolateId))
class Thrid {
  final myClassIsolate = MyClassIsolate();

  final first = First();

  Future<void> init() async {
    await myClassIsolate.init();

    return first.init("val");
  }

  Future<void> printValue(int n) async {
    final fib = await myClassIsolate.fib(n);

    final res = await first.multiply(fib);

    print(res);
  }
}
