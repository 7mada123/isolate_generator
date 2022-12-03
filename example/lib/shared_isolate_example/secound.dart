part of my_shared_isolate;

@GenerateIsolate(
  isSameType: true,
  sharedIsolate: SharedIsolate(2, _classCount, _isolateId),
)
class Secound {
  final String path;

  Secound(this.path);

  Future<void> createFile(String fileName) async {
    File(_filePath(fileName)).createSync();
  }

  String _filePath(String fileName) {
    return "$path/$fileName";
  }
}
