import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import './generator.dart';

Builder generateIsolate(BuilderOptions options) =>
    SharedPartBuilder([IsolateGenerator()], 'isolate_generator');
