part of controllers;

abstract class Updater {
  static UpdateChecker? _updateChecker;

  static bool get isInitialized => _updateChecker != null;

  static bool get isNotInitialized => _updateChecker == null;

  static Future<void> initialize(UpdateChecker updateChecker) async {
    _updateChecker = updateChecker;
    await _updateChecker!.initialize();
  }

  static bool get supportsUpdate => _updateChecker!.supportsUpdate;

  static PackageInfo get packageInfo => _updateChecker!.packageInfo;

  static Version get currentVersion => _updateChecker!.currentVersion;

  static Future<bool> isUpdateAvailable({bool recheck = false}) =>
      _updateChecker!.isUpdateAvailable(recheck: recheck);

  static Future<UpdateInfo> getLatestUpdateInfo({bool recheck = false}) async =>
      _updateChecker!.getLatestUpdateInfo(recheck: recheck);

  static Stream<UpdateInfo>? getLatestUpdateInfoStream() {
    try {
      return _updateChecker!.getLatestUpdateInfoStream();
    } catch (_) {
      return null;
    }
  }

  static Future<void> installLatestRelease() =>
      _updateChecker!.installLatestRelease();

  static void addListener(
    UpdateProgressListener listener, {
    TaskListenerCategory taskListenerCategory = TaskListenerCategory.all,
  }) {
    _updateChecker!.addListener(
      listener,
      taskListenerCategory: taskListenerCategory,
    );
  }

  static void removeListener(
    UpdateProgressListener listener, {
    TaskListenerCategory taskListenerCategory = TaskListenerCategory.all,
  }) {
    _updateChecker!.removeListener(
      listener,
      taskListenerCategory: taskListenerCategory,
    );
  }

  static TaskProgressInformation get currentTaskProgressInformation =>
      _updateChecker!.currentProgressInformation;

  static Future<void> cancelDownload() async {
    await _updateChecker!.downloadTask?.cancel?.call();
  }

  static Future<void> determineUpdateStatus() async {
    await _updateChecker!.determineUpdateStatus();
  }
}
