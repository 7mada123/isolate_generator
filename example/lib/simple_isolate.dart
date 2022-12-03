import 'dart:ui';

import 'package:isolate_generator_annotation/isolate_generator_annotation.dart';

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
}
