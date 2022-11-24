// copy the function input params, same as the ClassElement method
import 'package:analyzer/dart/element/element.dart';

String functionParameters(final MethodElement method) {
  String arg = "";
  bool hasNamed = false;

  for (var par in method.parameters) {
    if (par.isNamed && !hasNamed) {
      hasNamed = true;
      arg += "{";
    }

    arg +=
        "${(hasNamed && par.isRequired) ? 'required ' : ''}${par.type} ${par.name}${par.hasDefaultValue ? ' = ${par.defaultValueCode}' : ''},";
  }

  if (hasNamed) arg += "}";

  return arg;
}

// getting the function params values
String functionParametersValue(final MethodElement method, int messageIndex) {
  String arg = "";

  for (var par in method.parameters) {
    arg += par.isNamed
        ? "${par.name}:message[${messageIndex++}],"
        : "message[${messageIndex++}],";
  }

  return arg;
}

String redError(String msg) {
  return '\x1B[31m$msg\x1B[0m';
}

extension GenericTypeExtract on String {
  String genricType() {
    return _genericTypeExtract.stringMatch(this)!;
  }

  static final _genericTypeExtract = RegExp(r'(?<=\<).*(?=\>)');
}
