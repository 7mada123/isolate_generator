[Open full example in github](https://github.com/7mada123/isolate_generator/tree/main/example)

```dart
import 'dart:ui';

import 'package:isolate_generator_annotation/isolate_generator_annotation.dart';

part 'image_isolate.g.dart';

@GenerateIsolate()
class MyClass {
  int sum(int a, int b) {
    return a + b;
  }

  Stream<int> streamRang({required int count}) async* {
    for (var i = 0; i < count; i++) {
      yield i;
    }
  }
}
```