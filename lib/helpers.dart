// copy the function input params, same as the ClassElement method
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

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

String constructorParameters(
  final ConstructorElement constructor, {
  Set<DartType>? skip,
}) {
  String arg = "", storeing = "";
  bool hasNamed = false;

  List<String> sharedInstances = [];

  for (var par in constructor.parameters) {
    if (skip?.contains(par.type) ?? false) continue;

    if (par.isNamed && !hasNamed) {
      hasNamed = true;
      arg += "{";
    }

    arg +=
        "${(hasNamed && par.isRequired) ? 'required ' : ''}${par.type} ${par.name}${par.hasDefaultValue ? ' = ${par.defaultValueCode}' : ''},";
    storeing += "_${par.name} = ${par.name},";
  }

  if (sharedInstances.isNotEmpty) {
    if (!hasNamed) {
      arg += "{";
      hasNamed = true;
    }

    arg += sharedInstances.join("");
  }

  if (hasNamed) arg += "}";

  if (arg.isNotEmpty) {
    return "($arg):${storeing.substring(0, storeing.length - 1)}";
  }

  return "($arg)";
}

String constructorParametersSameType(
  final ConstructorElement constructor, {
  Set<DartType>? skip,
}) {
  String arg = "", superArg = "", storeing = "";
  bool hasNamed = false;

  List<String> sharedInstances = [];

  for (var par in constructor.parameters) {
    if (skip?.contains(par.type) ?? false) {
      String type = par.type.toString();

      if (type[type.length - 1] == "?") {
        sharedInstances.add("${par.type} ${par.name}_isolate,");
      } else {
        sharedInstances.add("${par.type}? ${par.name}_isolate,");
      }

      superArg += par.isNamed
          ? "${par.name}: ${par.name}_isolate!,"
          : "${par.name}_isolate!,";

      continue;
    }

    superArg += par.isNamed ? "${par.name}: ${par.name}," : "${par.name},";

    if (par.isNamed && !hasNamed) {
      hasNamed = true;
      arg += "{";
    }

    arg +=
        "${(hasNamed && par.isRequired) ? 'required ' : ''}${par.type} ${par.name}${par.hasDefaultValue ? ' = ${par.defaultValueCode}' : ''},";

    storeing += "_${par.name} = ${par.name},";
  }

  if (sharedInstances.isNotEmpty) {
    if (!hasNamed) {
      arg += "{";
      hasNamed = true;
    }

    arg += sharedInstances.join("");
  }

  if (hasNamed) arg += "}";

  if (arg.isNotEmpty) return "($arg): $storeing super($superArg)";

  return "()";
}

String constructorFileds(
  final ConstructorElement constructor, {
  Set<DartType>? skip,
}) {
  String fileds = "";
  for (var par in constructor.parameters) {
    if (skip?.contains(par.type) ?? false) continue;

    fileds += "final ${par.type} _${par.name};\n";
  }

  return fileds;
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

// getting the constructor params values
String constructorParametersValue(
  final ConstructorElement constructor,
  int messageIndex, {
  Map<DartType, String>? replace,
}) {
  String arg = "";

  for (var par in constructor.parameters) {
    if (replace?.containsKey(par.type) ?? false) {
      arg += par.isNamed
          ? "${par.name}: ${replace![par.type]},"
          : "${replace![par.type]},";

      continue;
    }
    arg += par.isNamed
        ? "${par.name}:message[${messageIndex++}],"
        : "message[${messageIndex++}],";
  }

  return arg;
}

String constructorParametersValueList(
  final ConstructorElement constructor, {
  Set<DartType>? skip,
}) {
  String arg = "";

  for (var par in constructor.parameters) {
    if (skip?.contains(par.type) ?? false) continue;

    arg += "_${par.name},";
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
