part of '../structures.dart';

typedef UpdateProgressListener = void Function(
  TaskProgressInformation progressInformation,
);

enum UpdateStatus {
  noUpdatesAvailable,
  checking,
  updateAvailable,
  preparing,
  downloading,
  installing,
  installAvailable;

  String get prettyString {
    switch (this) {
      case noUpdatesAvailable:
        return "No updates available";
      case updateAvailable:
        return "Update";
      case preparing:
        return "Prepairing";
      case downloading:
        return "Downloading";
      case installing:
        return "Installing";
      case installAvailable:
        return "Install";
      case checking:
        return "Checking for update";
    }
  }
}

abstract class UpdateChecker extends LogHelper with _TaskProgressNotifier {
  bool get supportsUpdate;

  bool _isInitialized = false;

  bool get isNotInitialized => !_isInitialized;
  late Version _currentVersion;
  late PackageInfo _packageInfo;
  UpdateInfo? _updateInfo;

  PackageInfo get packageInfo => _packageInfo;
  Version get currentVersion => _currentVersion;

  @mustCallSuper
  FutureOr<void> initialize() async {
    _packageInfo = await PackageInfo.fromPlatform();
    _currentVersion = getAppVersionFromPackageInfo(_packageInfo);
    if (supportsUpdate) {
      await determineUpdateStatus();
    }
    _isInitialized = true;
  }

  @mustCallSuper
  FutureOr<void> dispose() async {
    _isInitialized = false;
  }

  Future<bool> isUpdateAvailable({
    bool recheck = false,
  }) async {
    if (!supportsUpdate) {
      throw "Update is not supported";
    }
    await getLatestUpdateInfo(recheck: recheck);
    return _currentVersion < _updateInfo!.version;
  }

  @protected
  FutureOr<UpdateInfo> getLatestUpdateInfoInternal();

  Future<UpdateInfo> getLatestUpdateInfo({
    bool recheck = false,
  }) async {
    if (recheck) {
      _setStatus = UpdateStatus.checking;
      logER("Checking for latest version");
      _updateInfo = await getLatestUpdateInfoInternal();
      return _updateInfo!;
    }
    if (_updateInfo == null) {
      _setStatus = UpdateStatus.checking;
      logER("Checking for latest version");
      _updateInfo = await getLatestUpdateInfoInternal();
    }

    return _updateInfo!;
  }

  Stream<UpdateInfo>? getLatestUpdateInfoStream();

  @protected
  Future<UpdateDownloadTask> downloadLatestReleaseInternal(File toDownloadAt);

  Future<void> installLatestRelease() async {
    if (!supportsUpdate) {
      throw "Update is not supported";
    }
    if (installationIsInProgress) {
      return;
    }
    _setStatus = UpdateStatus.preparing;

    final File file = await _getUpdateFile();

    if (!(await file.exists())) {
      _setStatus = UpdateStatus.downloading;
      logER("Downloading update");
      _setDownloadTask = await downloadLatestReleaseInternal(file);
      await _downloadTask;
      logER("Download complete");
    }

    if (await file.exists()) {
      _setStatus = UpdateStatus.installing;
      logER("Opening installer file");

      /*if (!(await Permission.manageExternalStorage.isGranted)) {
        
      }*/

      await Permission.manageExternalStorage.request();

      await Permission.requestInstallPackages.request();

      final OpenResult openfileResult = await OpenFile.open(
        file.path,
        type: "application/vnd.android.package-archive",
      );
      logER(
        "Open File result: ${openfileResult.type.name} - ${openfileResult.message}",
      );
    } else {
      _setStatus = UpdateStatus.updateAvailable;
      logER(
        "Could not install update because installer file was not found. It was not created by the downloadLatestReleaseInternal() function",
      );
      return;
    }

    await determineUpdateStatus();
  }

  Future<void> determineUpdateStatus() async {
    final bool isAvailable = await isUpdateAvailable(recheck: true);

    if (isAvailable) {
      final File file = await _getUpdateFile();
      if (await file.exists()) {
        _setStatus = UpdateStatus.installAvailable;
      } else {
        _setStatus = UpdateStatus.updateAvailable;
      }
    } else {
      _setStatus = UpdateStatus.noUpdatesAvailable;
    }
    logER(_currentStatus);
  }

  Future<File> _getUpdateFile() async {
    final String tempDir = (await getTemporaryDirectory()).path;
    await getLatestUpdateInfo();
    final String filePath = path.join(
      tempDir,
      "installers",
      _getSupposedFileName(),
    );
    final File file = File(filePath);
    return file;
  }

  String _getSupposedFileName() {
    switch (Platform.operatingSystem) {
      case "android":
        return "${_updateInfo!.version}.apk";
      case "ios":
      case "fuchsia":
      case "linux":
      case "macos":
      case "windows":
    }
    return "";
  }
}

enum TaskListenerCategory {
  all,
  status,
  downloadProgressRatio;
}

mixin _TaskProgressNotifier on LogHelper {
  @protected
  final Map<TaskListenerCategory, List<UpdateProgressListener>> _listeners = {};

  void addListener(
    UpdateProgressListener listener, {
    TaskListenerCategory taskListenerCategory = TaskListenerCategory.all,
  }) {
    _listeners[taskListenerCategory] ??= [];
    _listeners[taskListenerCategory]!.add(listener);

    if (const [
          TaskListenerCategory.all,
          TaskListenerCategory.downloadProgressRatio,
        ].contains(taskListenerCategory) &&
        (_downloadTaskStreamSubscription == null) &&
        (_downloadTask != null)) {
      _downloadTaskStreamSubscription =
          _downloadTask!.events?.listen(_streamSubscriptionListener);

      /*logER(
        "addListener(): Download task progress stream is Not NULL: ${_downloadTask!.events != null}",
      );*/
    }
  }

  void removeListener(
    UpdateProgressListener listener, {
    TaskListenerCategory taskListenerCategory = TaskListenerCategory.all,
  }) {
    _listeners[taskListenerCategory]?.remove(listener);

    if (const [
          TaskListenerCategory.all,
          TaskListenerCategory.downloadProgressRatio,
        ].contains(taskListenerCategory) &&
        (_downloadTaskStreamSubscription != null) &&
        [
          ..._listeners[TaskListenerCategory.all] ?? [],
          ..._listeners[TaskListenerCategory.downloadProgressRatio] ?? [],
        ].isEmpty) {
      _downloadTaskStreamSubscription?.cancel();
    }
  }

  @protected
  void _notifyListeners(TaskListenerCategory taskListenerCategory) {
    final TaskProgressInformation progressInformation =
        currentProgressInformation;

    if (taskListenerCategory == TaskListenerCategory.all) {
      for (final MapEntry<TaskListenerCategory,
              List<UpdateProgressListener>> listenerCategory
          in _listeners.entries) {
        for (final UpdateProgressListener listener in listenerCategory.value) {
          listener(progressInformation);
        }
      }
      return;
    }

    final List<UpdateProgressListener>? categoryListeners =
        _listeners[taskListenerCategory];
    if (categoryListeners?.isNotEmpty ?? false) {
      for (final UpdateProgressListener listener in categoryListeners!) {
        listener(progressInformation);
      }
    }

    final List<UpdateProgressListener>? allListeners =
        _listeners[TaskListenerCategory.all];

    if (allListeners?.isNotEmpty ?? false) {
      for (final UpdateProgressListener listener in allListeners!) {
        listener(progressInformation);
      }
    }
  }

  @protected
  UpdateDownloadTask? _downloadTask;

  @protected
  TaskProgress<int>? _currentProgress;

  @protected
  StreamSubscription<TaskProgress<int>>? _downloadTaskStreamSubscription;

  @protected
  UpdateStatus _currentStatus = UpdateStatus.noUpdatesAvailable;

  UpdateStatus get currentStatus => _currentStatus;

  UpdateDownloadTask? get downloadTask => _downloadTask;

  TaskProgress<int>? get currentProgress => _currentProgress;

  bool get installationIsInProgress => const [
        UpdateStatus.downloading,
        UpdateStatus.preparing,
        UpdateStatus.installing,
      ].contains(_currentStatus);

  @protected
  set _setDownloadTask(UpdateDownloadTask task) {
    //logER("Setting Download task");
    _downloadTask = task;

    _downloadTask!.whenComplete(() {
      logER(
        "Download task is completed. Cleaning up and unsubscribing stream.",
      );
      _downloadTask = null;
      _currentProgress = null;
      _downloadTaskStreamSubscription?.cancel();
      _downloadTaskStreamSubscription = null;
      _notifyListeners(TaskListenerCategory.downloadProgressRatio);
    });

    List<UpdateProgressListener>? listeners;

    if (_downloadTaskStreamSubscription == null) {
      //logER("Download progress stream is null");
      listeners = [
        ..._listeners[TaskListenerCategory.all] ?? [],
        ..._listeners[TaskListenerCategory.downloadProgressRatio] ?? [],
      ];

      if (listeners.isNotEmpty) {
        //logER("Listeners is not empty, subscribing to stream");
        _downloadTaskStreamSubscription =
            _downloadTask!.events?.listen(_streamSubscriptionListener);
        /*logER(
          "Download task progress stream is Not NULL: ${_downloadTask!.events != null}",
        );*/
      }
    }

    if ((listeners ??
            [
              ..._listeners[TaskListenerCategory.all] ?? [],
              ..._listeners[TaskListenerCategory.downloadProgressRatio] ?? [],
            ])
        .isNotEmpty) {
      _notifyListeners(TaskListenerCategory.downloadProgressRatio);
    }
  }

  @protected
  set _setStatus(UpdateStatus value) {
    if (_currentStatus == value) {
      return;
    }
    _currentStatus = value;
    _notifyListeners(TaskListenerCategory.status);
  }

  void _streamSubscriptionListener(TaskProgress<int> event) {
    //logER("Download Progress stream event: $event");
    _currentProgress = event;
    _notifyListeners(TaskListenerCategory.downloadProgressRatio);
  }

  TaskProgressInformation get currentProgressInformation {
    return TaskProgressInformation(
      downloadTaskProgress: _currentProgress,
      status: _currentStatus,
    );
  }
}

class TaskProgressInformation {
  final TaskProgress<int>? downloadTaskProgress;
  final UpdateStatus status;

  const TaskProgressInformation({
    required this.downloadTaskProgress,
    required this.status,
  });

  double? get completionRatio => downloadTaskProgress?.completionRatio;

  bool get installationIsInProgress => const [
        UpdateStatus.downloading,
        UpdateStatus.preparing,
        UpdateStatus.installing,
      ].contains(status);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TaskProgressInformation &&
        other.downloadTaskProgress == downloadTaskProgress &&
        other.status == status;
  }

  @override
  int get hashCode => downloadTaskProgress.hashCode ^ status.hashCode;

  @override
  String toString() =>
      'TaskProgressInformation(downloadTaskProgress: $downloadTaskProgress, status: $status)';
}

class UpdateInfo {
  final Version version;
  final DateTime date;
  final List<String> changeLogs;

  const UpdateInfo({
    required this.version,
    required this.date,
    required this.changeLogs,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UpdateInfo &&
        other.version == version &&
        other.date == date &&
        listEquals(other.changeLogs, changeLogs);
  }

  @override
  int get hashCode => version.hashCode ^ date.hashCode ^ changeLogs.hashCode;

  @override
  String toString() => 'UpdateInfo(version: $version, changeLogs: $changeLogs)';

  Map<String, dynamic> toMap() {
    return {
      'version': version.toString(),
      'date': date.toIso8601String(),
      'changeLogs': changeLogs,
    };
  }

  factory UpdateInfo.fromMap(Map<String, dynamic> map) {
    return UpdateInfo(
      version: Version.parse(map['version'] as String),
      date: DateTime.parse(map['date'] as String),
      changeLogs: List<String>.from(map['changeLogs'] as List),
    );
  }

  String toJson() => json.encode(toMap());

  factory UpdateInfo.fromJson(String source) =>
      UpdateInfo.fromMap(json.decode(source) as Map<String, dynamic>);
}

class TaskProgress<T extends num> {
  final T total;
  final T completed;

  TaskProgress({
    required T total,
    required T completed,
  })  : total = total.clamp(0, total) as T,
        completed = completed.clamp(0, total) as T;

  double get completionRatio => completed / total;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TaskProgress<T> &&
        other.total == total &&
        other.completed == completed;
  }

  @override
  int get hashCode => total.hashCode ^ completed.hashCode;

  @override
  String toString() => 'TaskProgress(total: $total, completed: $completed)';
}

class UpdateDownloadTask extends DelegatingFuture<void> {
  UpdateDownloadTask(
    super.task, {
    this.pause,
    this.resume,
    this.cancel,
    this.events,
  });

  final AsyncVoidCallback? pause;
  final AsyncVoidCallback? resume;
  final AsyncVoidCallback? cancel;
  final Stream<TaskProgress<int>>? events;
}
