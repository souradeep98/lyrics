part of structures;

abstract class UpdateChecker {
  bool get supportsUpdate;

  bool isInitialized = false;

  bool get isNotInitialized => !isInitialized;

  FutureOr<void> initialize() async {
    isInitialized = true;
  }

  FutureOr<void> dispose() async {
    isInitialized = false;
  }

  Future<bool> isUpdateAvailable() async {
    if (!supportsUpdate) {
      throw "Update is not supported";
    }
    final Version latestVersion = await getLatestVersion();
    final Version currentVersion = await getAppVersion();
    return currentVersion < latestVersion;
  }

  FutureOr<Version> getLatestVersion();

  Stream<Version>? getLatestVersionStream();

  @protected
  DownloadTask downloadLatestReleaseInternal(File toDownloadAt);

  Future<DownloadTask> downloadLatestRelease() async {
    final File file = await _getUpdateFile();
    return downloadLatestReleaseInternal(file);
  }

  Future<void> installLatestRelease() async {
    if (!supportsUpdate) {
      throw "Update is not supported";
    }
    final File file = await _getUpdateFile();

    if (await file.exists()) {
      await OpenFile.open(file.path);
    } else {
      await downloadLatestReleaseInternal(file);
      if (await file.exists()) {
        await OpenFile.open(file.path);
      } else {
        throw "Error! No update file was found!";
      }
    }
  }

  Future<File> _getUpdateFile() async {
    final String tempDir = (await getTemporaryDirectory()).path;
    final String filePath = path.join(tempDir, "releases", "app.apk");
    final File file = File(filePath);
    return file;
  }
}

class TaskProgress<T extends num> {
  final T total;
  final T completed;

  const TaskProgress({
    required this.total,
    required this.completed,
  });

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

class DownloadTask implements Future<TaskProgress<int>> {
  final AsyncVoidCallback? onPause;
  final AsyncVoidCallback? onResume;
  final AsyncVoidCallback? onCancel;
  final Stream<TaskProgress<int>>? events;

  const DownloadTask({
    this.onPause,
    this.onResume,
    this.onCancel,
    this.events,
  });

  Future<void> pause() async {
    await onPause?.call();
  }

  Future<void> resume() async {
    await onResume?.call();
  }

  Future<void> cancel() async {
    await onCancel?.call();
  }

  @override
  Stream<TaskProgress<int>> asStream() {
    return Stream<TaskProgress<int>>.fromFuture(this);
  }

  @override
  Future<TaskProgress<int>> catchError(
    Function onError, {
    bool Function(Object error)? test,
  }) async {
    try {
      return await this;
    } catch (e, s) {
      if (test?.call(e) ?? false) {
        if (onError is! FutureOr<TaskProgress<int>> Function(
          Object? error,
          StackTrace? stackTrace,
        )) {
          throw "onError Function must return the type TaskProgress<int> and must accept [Object? error] and pStackTrace? stackTrace] as it's arguments";
        }
        return onError(e, s);
      }
      rethrow;
    }
  }

  @override
  Future<R> then<R>(
    FutureOr<R> Function(TaskProgress<int> value) onValue, {
    Function? onError,
  }) async {
    try {
      final TaskProgress<int> value = await this;
      return onValue(value);
    } catch (e, s) {
      if (onError != null) {
        if (onError is! FutureOr<R> Function(
          Object? error,
          StackTrace? stackTrace,
        )) {
          throw "onError Function must return the type $R and must accept [Object? error] and pStackTrace? stackTrace] as it's arguments";
        }
        return onError(e, s);
      }
      rethrow;
    }
  }

  @override
  Future<TaskProgress<int>> timeout(
    Duration timeLimit, {
    FutureOr<TaskProgress<int>> Function()? onTimeout,
  }) async {
    final result = await Future.any(
      <Future>[
        this,
        Future<TimeoutException>.delayed(
          timeLimit,
          () => TimeoutException(null),
        ),
      ],
    );

    if (result is TimeoutException) {
      if (onTimeout != null) {
        return onTimeout();
      } else {
        throw TimeoutException("Download Task timeout!");
      }
    }
    return result as TaskProgress<int>;
  }

  @override
  Future<TaskProgress<int>> whenComplete(
    FutureOr<void> Function() action,
  ) async {
    final TaskProgress<int> result = await this;
    await action();
    return result;
  }
}
