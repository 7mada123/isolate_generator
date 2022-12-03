part of my_shared_isolate;

// isolates communications example
@GenerateIsolate(sharedIsolate: SharedIsolate(3, _classCount, _isolateId))
class Thrid {
  final myClassIsolate = MyClassIsolate();

  // since this class will share the same isolate we can just pass the instance from the isolate
  @FromIsolate()
  final First first;

  final int id;

  // pass the
  Thrid({required this.id, required this.first});

  Future<void> initOtherIsolate() async {
    // initializing the other isolate
    await myClassIsolate.init();
  }

  Future<void> printValue(int n) async {
    // calling the other isolate from this isolate
    final fib = await myClassIsolate.fib(n);

    // First is already running in the same isolate so we can use it directly
    final res = first.multiply(fib);

    print(res);
  }
}
