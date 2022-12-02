import 'package:isolate_generator_annotation/isolate_generator_annotation.dart';

import 'dart:ui';

part 'simple_isolate.g.dart';

@GenerateIsolate()
class MyClass {
  int fib(int n) {
    if (n <= 1) return n;
    return fib(n - 1) + fib(n - 2);
  }

  Stream<int> fibStream(int n) async* {
    for (var i = 1; i <= n; i++) {
      yield fib(i);
    }
  }

  static int cur = 0;

  static int _iniss() {
    int sum = 0;

    for (var i = 0; i < 10000000000; i++) {
      sum += i;
    }

    return sum;
  }

  void pp() {
    print(cur++);
    print(_iniss());
  }
}
