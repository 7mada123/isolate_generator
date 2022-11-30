A flutter package for Isolate code generation.

## Features

- Warping your classes inside of `Isolate` and provide a new class with the same functionality that run in `Isolate`.
- Use all allowed dart types including streams
- Safe cross isolates with instance reference

## Getting started

Add this package and [build_runner](https://pub.dev/packages/build_runner) to your `dev_dependencies`

```
flutter pub add --dev build_runner
flutter pub add --dev isolate_generator
```

you also need to add [isolate_generator_annotation](https://pub.dev/packages/isolate_generator_annotation) to your `dependencies`

```
flutter pub add isolate_generator_annotation
```

## Usage

simply add `GenerateIsolate` annotation to the classes you want to run inside of `Isolate`

```dart
import 'dart:ui';

import 'package:isolate_generator_annotation/isolate_generator_annotation.dart';

part 'image_isolate.g.dart';

@GenerateIsolate()
class MyClass {
  int sum(int a, int b) {
    return a + b;
  }

  Stream<int> streamRang(int count, {Set<int>? include}) async* {
    for (var i = 0; i < count; i++) {
      if (include?.contains(i) ?? true) yield i;
    }
  }
}
```

run the code generator
```
flutter pub run build_runner build
```
and now you have generated `MyClassIsolate`

the usage is the same as the default class with minor difference

- you have `init` method which is used to initialize the `Isolate`
- you can get reference to the running `Isolate` by `MyClassIsolate,isolate`
- now `sum` method will return `Future<int>` instead of `int` because isolate communications is asynchronous

### using the generated class

```dart
  final myClass = MyClassIsolate();
  
  // initialize the isolate
  await myClass.init();

  // return a future int from the isolate
  final sum = await myClass.sum(a, b);
  
  // stream from the isolate
  myClass.streamRang(10).listen((event) {
    print(event);
  });
```

### initializing class with custom argument

in case you have want to initialize your class with custom argument, let's say path for example

you would need to do it with `init` method in the default class


```dart
@GenerateIsolate()
class MyClass {
  late final String path;

  void init({required String path}) {
    this.path = path;
  }

  int sum(int a, int b) {
    return a + b;
  }
}
```

and then your `init` method will be mapped to the generated class

```dart
  final myClass = MyClassIsolate();
  
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;

  // initialize the isolate and the default class with the provided path
  await myClass.init(path: tempPath);
```

> class constructor isn't supported, only initialize your classes through `init` method even if you are not going to used to get the same behaviors from the default class

### Generate arguments

#### isSameType

you can make the generated class identifiable as the default class
```dart
    // true
    MyClass() == MyClassIsolate();
```
this is useful in some cases, for example if you are targeting web with other platforms

to get this behavior change `isSameType` to true

```dart
@GenerateIsolate(isSameType: true)
class MyClass {
  ...
}
```

this will tell the generated class to extend the default class and override it's methods

> you need to make sure that all methods in the default class return `Future<T>` and/or `Stream`, and also you have to provide `init` method


#### sharedIsolate

if you want to run multiple classes in the same isolate while writing the code for each class in a separate file you can use `sharedIsolate` argument

to use it all the classes should be in a library, to see the implementation please take a look at the [example]()

> this isn't for communication between isolates but to share the same isolate between different class so you don't end up spawning different isolate for each class

## Limitation

- Have the same `Isolate` limitation

- class constructor isn't supported

- the generator will only care about public functions/methods however you can use private functions and local variables internally without any issues

if you want to access local variable instance for example

```dart
class MyClass{
    int val = 0;
}
```

in the above example you can't access `val` from the generated class but you can use it internally, and if you want to access it make a function that return it

```dart
class MyClass{
    int val = 0;

    int getVal(){
        return val;
    }
}
```

now you can get `val` in the generated class

```dart
final int myClass = MyClassIsolate();

await myClass.init();

final int val = await myClass.getVal();
```


### Example app

The [example]() directory has a sample application that uses this plugin.