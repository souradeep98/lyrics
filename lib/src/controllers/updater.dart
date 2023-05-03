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

  static Future<bool> isUpdateAvailable() =>
      _updateChecker!.isUpdateAvailable();

  static Future<Version> getLatestVersion() async =>
      await _updateChecker!.getLatestVersion();

  static Stream<Version>? getLatestVersionStream() =>
      _updateChecker!.getLatestVersionStream();

  static Future<DownloadTask> downloadLatestRelease() =>
      _updateChecker!.downloadLatestRelease();

  static Future<void> installLatestRelease() =>
      _updateChecker!.installLatestRelease();
}
