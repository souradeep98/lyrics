part of structures;

class UnsupportedUpdateChecker extends UpdateChecker {
  //const UnsupportedUpdateChecker();

  @override
  bool get isInitialized => true;

  @override
  FutureOr<Version> getLatestVersion() {
    throw "Unsupported operation";
  }

  @override
  bool get supportsUpdate => false;

  @override
  DownloadTask downloadLatestReleaseInternal(File toDownloadAt) {
    throw "Unsupported operation";
  }

  @override
  Stream<Version>? getLatestVersionStream() {
    throw "Unsupported operation";
  }
}
