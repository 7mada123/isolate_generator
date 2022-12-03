library my_shared_isolate;

import 'dart:io';
import 'dart:ui';

import 'package:example/simple_isolate.dart';
import 'package:isolate_generator_annotation/isolate_generator_annotation.dart';

part './first.dart';
part './secound.dart';
part './thrid_with_isolates_communications.dart';
part 'my_shared_isolate.g.dart';

// the number of classes that share the same isolate
// it's recommended to store it in a variable and pass to the classes you want to generate code for
const int _classCount = 3;

// the shared isolate id
const String _isolateId = "mySharedIsolate";
