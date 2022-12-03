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

  Stream<int> streamRang({required int count}) async* {
    for (var i = 0; i < count; i++) {
      yield i;
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
- you can get reference to the running `Isolate` by `MyClassIsolate.isolate`
- now `sum` method will return `Future<int>` instead of `int` because isolate communications is asynchronous

#### using the generated class

```dart
  final myClass = MyClassIsolate();
  
  // initialize the isolate
  await myClass.init();

  // return a future int from the isolate
  final sum = await myClass.sum(a, b);
  
  // stream from the isolate
  myClass.streamRang(count: 10).listen((event) {
    print(event);
  });
```

### Generator arguments

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

> you need to make sure that all methods in the default class return `Future<T>` and/or `Stream<T>` to get the same behaviors from the generated class

#### sharedIsolate

if you want to run multiple classes in the same isolate while writing the code for each class in a separate file you can use `sharedIsolate` argument

to use it all the classes should be in a library, to see the implementation take a look at [shared_isolate_example](https://github.com/7mada123/isolate_generator/tree/main/example/lib/shared_isolate_example)

> this isn't for communication between isolates but for sharing the same isolate between different class so you don't end up spawning different isolate for each simple class

### Communications between isolates

to communicate between isolates simply use the genrated class with the new one you want to genrate, and that's it

```dart
@GenerateIsolate()
// the new class you want to run inside isolate
class MyNewClass {
  // the generated class that already run inside an isolate
  final genratedClass = MyClassIsolate();

  Future<void> initMyClassIsolateIsolate() async {
    //..your initialization code..//

    await genratedClass.init();
  }

  Future<void> ss() async {
    //..your logic..//

    // invoke a method from this isolate on the other isolate
    await genratedClass.createFile("fileName");
  }
}
```

> Whenever you call `genratedClass.init()` method in the main isolate or any other isolate If there is an already running isolate instance for `genratedClass`, it will be used instead of spawning a new isolate.

in case of communication between different classes that share the same isolate `sharedIsolate` you can pass the instance through the constructor and annotate the class filed with `FromIsolate`
```dart
@GenerateIsolate(sharedIsolate: SharedIsolate(2, 2, "my_shared_isolate"))
class MySecoundClass {
  // since this class will share the same isolate we can just pass the instance from the isolate
  @FromIsolate()
  final MyFirstClass first;

  MySecoundClass(this.first);

  int printValue(int n)  {
    // First is already running in the same isolate so we can use it directly
    return first.calculate(n);
  }
}
```

`MyFirstClass` instance will be passed when initializing the isolate for`MySecoundClass`, however you have to make sure that `MyFirstClass` is initialized before using it in `MySecoundClass`

> when you use `FromIsolate` annotation, even if you make the filed nullable `final MyFirstClass? first` the instance will be passed inside the isolate so you don't have to pass it when initializing the genrated class when using `isSameType`

## Limitation

- Have the same `Isolate` limitation

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

The [example](https://github.com/7mada123/isolate_generator/tree/main/example) directory has a sample application that uses this package.