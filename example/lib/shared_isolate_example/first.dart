part of my_shared_isolate;

@GenerateIsolate(
  isSameType: true,
  sharedIsolate: SharedIsolate(1, _classCount, _isolateId),
)
class First {
  late final String val;
  late final int? count;

  final SecoundIsolate secoundIsolate = SecoundIsolate();

  Future<void> init(String val, {int? count}) async {
    this.val = val;
    this.count = count;
  }

  Future<int> multiply(int newVal) async {
    return newVal * (count ?? 1);
  }

  Future<String> contact(String newString, {bool atEnd = false}) async {
    if (atEnd) return newString + val;

    return val + newString;
  }
}
