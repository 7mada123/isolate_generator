part of my_shared_isolate;

@GenerateIsolate(
  sharedIsolate: SharedIsolate(1, _classCount, _isolateId),
)
class First {
  final String val;
  final int? count;

  First(this.val, this.count);

  int multiply(int newVal) {
    return newVal * (count ?? 1);
  }

  String contact(String newString, {bool atEnd = false}) {
    if (atEnd) return newString + val;

    return val + newString;
  }
}
