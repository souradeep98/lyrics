part of structures;

class UnsupportedUpdateChecker extends UpdateChecker {
  //const UnsupportedUpdateChecker();

  @override
  bool get _isInitialized => true;

  @override
  FutureOr<UpdateInfo> getLatestUpdateInfoInternal() {
    throw "Unsupported operation";
  }

  @override
  bool get supportsUpdate => false;

  @override
  UpdateDownloadTask downloadLatestReleaseInternal(File toDownloadAt) {
    throw "Unsupported operation";
  }

  @override
  Stream<UpdateInfo>? getLatestUpdateInfoStream() {
    throw "Unsupported operation";
  }
}

class MockUpdateChecker extends UpdateChecker {
  //const UnsupportedUpdateChecker();

  @override
  bool get _isInitialized => true;

  @override
  Future<UpdateInfo> getLatestUpdateInfoInternal() async {
    final Version currentVersion = await getAppVersion();
    return Future<UpdateInfo>.delayed(
      const Duration(seconds: 1),
      () {
        return _getMockUpdateInfo(currentVersion);
      },
    );
  }

  UpdateInfo _getMockUpdateInfo(Version currentVersion) {
    return UpdateInfo(
      changeLogs: ["Nice change", "Another change", "Bug fix and improvements"],
      version: Version(
        1,
        0,
        3,
        build: "3",
      ),
      //version: currentVersion,
      date: DateTime.now(),
    );
  }

  @override
  bool get supportsUpdate => true;

  @override
  UpdateDownloadTask downloadLatestReleaseInternal(File toDownloadAt) {
    return UpdateDownloadTask(
      _downloadReallyWorks(),
      events: _eventController?.stream,
    );
  }

  Future<void> _downloadReallyWorks() async {
    final Completer<void> completer = Completer<void>();
    _eventController = StreamController<TaskProgress<int>>();
    int i = 0;
    Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        if (i <= 100) {
          _eventController?.add(
            TaskProgress<int>(total: 100, completed: ++i),
          );
        } else {
          completer.complete();
          _eventController?.close();
          _eventController = null;
          timer.cancel();
        }
      },
    );
    return completer.future;
  }

  StreamController<TaskProgress<int>>? _eventController;

  @override
  Stream<UpdateInfo>? getLatestUpdateInfoStream() {
    return null;
  }
}
