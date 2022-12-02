part of my_shared_isolate;

@GenerateIsolate(
  sharedIsolate: SharedIsolate(2, _classCount, _isolateId),
)
class Secound {
  late final String path;

  void init({required String path}) {
    this.path = path;
  }

  void createFile(String fileName) {
    File(_filePath(fileName)).createSync();
  }

  String _filePath(String fileName) {
    return "$path/$fileName";
  }
}
