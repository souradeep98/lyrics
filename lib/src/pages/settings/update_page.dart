part of '../../pages.dart';

class UpdatePage extends StatefulWidget {
  final String title;

  const UpdatePage({
    super.key,
    required this.title,
  });

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppCustomAppBar(
        title: Text(
          widget.title.translate(),
        ),
      ),
      body: ListView(
        children: [
          const _AppInfo(),
          if (Updater.supportsUpdate) const _UpdateInfo(),
        ],
      ),
    );
  }
}

class _AppInfo extends StatelessWidget {
  // ignore: unused_element
  const _AppInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final PackageInfo packageInfo = Updater.packageInfo;
    final Version version = Updater.currentVersion;
    return ListTile(
      title: Text(packageInfo.appName),
      subtitle: Text("Version: $version"),
    );
  }
}

class _UpdateInfo extends StatefulWidget {
  // ignore: unused_element
  const _UpdateInfo({super.key});

  @override
  State<_UpdateInfo> createState() => __UpdateInfoState();
}

class __UpdateInfoState extends State<_UpdateInfo> with LogHelperMixin {
  late bool _isStream;
  late final DataObservable<UpdateInfo> _controller;
  String get _getxTag => "UpdateInformation";

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() {
    final Stream<UpdateInfo>? stream = Updater.getLatestUpdateInfoStream();
    _isStream = stream != null;

    if (_isStream) {
      _controller = StreamDataObservable<UpdateInfo>(
        stream: stream!,
        initialDataGenerator: () async {
          return Updater.getLatestUpdateInfo();
        },
      ).put<StreamDataObservable<UpdateInfo>>(tag: _getxTag);
    } else {
      _controller = SingleGenerateObservable<UpdateInfo>(
        dataGenerator: (_) {
          return Updater.getLatestUpdateInfo();
        },
      ).put<SingleGenerateObservable<UpdateInfo>>(tag: _getxTag);
    }

    //logER("Controller is initialized");
  }

  FeedbackCallback? _multifunctionGetter(UpdateStatus status) {
    switch (status) {
      case UpdateStatus.noUpdatesAvailable:
        return _onCheckForUpdate;
      case UpdateStatus.updateAvailable:
        return _onUpdate;
      case UpdateStatus.preparing:
        return null;
      case UpdateStatus.downloading:
        return _onUpdateCancel;
      case UpdateStatus.installing:
        return null;
      case UpdateStatus.installAvailable:
        return _onUpdate;
      case UpdateStatus.checking:
        return null;
    }
  }

  Future<bool?> _onUpdate() async {
    await Updater.installLatestRelease();
    return null;
  }

  Future<bool?> _onUpdateCancel() async {
    await Updater.cancelDownload();
    return null;
  }

  Future<bool?> _onCheckForUpdate() async {
    //await (_controller as SingleGenerateObservable<UpdateInfo>).generate();
    await Updater.determineUpdateStatus();
    return null;
  }

  String _getStatusText(UpdateStatus status, Version? version) {
    switch (status) {
      case UpdateStatus.noUpdatesAvailable:
        return "No updates available".translate();
      case UpdateStatus.checking:
        return "Checking for update".translate();
      case UpdateStatus.updateAvailable:
        return "${"Update Available".translate()}: $version";
      case UpdateStatus.preparing:
        return "${"Update Available".translate()}: $version";
      case UpdateStatus.downloading:
        return "${"Update Available".translate()}: $version";
      case UpdateStatus.installing:
        return "${"Update Available".translate()}: $version";
      case UpdateStatus.installAvailable:
        return "${"Update Available".translate()}: $version";
    }
  }

  Widget _mainBuilder(DataObservable<UpdateInfo> controller) {
    final UpdateInfo? updateInfo = controller.data;
    final String? dateReleased = updateInfo?.date.toLocal().format();
    return UpdaterListener(
      taskListenerCategories: const {
        TaskListenerCategory.status,
      },
      /*shouldRebuild: (oldTaskProgress, newTaskProgress) {
        return ((oldTaskProgress.status == UpdateStatus.noUpdatesAvailable) &&
                (newTaskProgress.status != UpdateStatus.noUpdatesAvailable)) ||
            ((newTaskProgress.status == UpdateStatus.noUpdatesAvailable) &&
                (oldTaskProgress.status != UpdateStatus.noUpdatesAvailable));
      },*/
      builder: (context, updateProgress, progressBar) {
        final bool updateAvailable = !const [
          UpdateStatus.noUpdatesAvailable,
          UpdateStatus.checking,
        ].contains(updateProgress.status);

        final String statusText = _getStatusText(
          updateProgress.status,
          updateInfo?.version,
        );

        final String buttonText =
            updateProgress.status.prettyString.translate();
        return AnimatedShowHide(
          showDuration: const Duration(milliseconds: 550),
          hideDuration: const Duration(milliseconds: 350),
          isShown: updateInfo != null,
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    statusText,
                  ),
                  subtitle: AnimatedShowHide(
                    showDuration: const Duration(milliseconds: 550),
                    hideDuration: const Duration(milliseconds: 350),
                    isShown: updateAvailable,
                    //transitionBuilder: _verticalRevealTransitionBuilder,
                    child: Text(
                      ((dateReleased != null) && updateAvailable)
                          ? "${"Released on".translate()}: $dateReleased"
                          : "",
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedShowHide(
                        isShown: updateAvailable,
                        showDuration: const Duration(milliseconds: 450),
                        hideDuration: const Duration(milliseconds: 350),
                        child: updateAvailable
                            ? ElevatedButton(
                                onPressed: _multifunctionGetter(
                                  updateProgress.status,
                                ),
                                child: Text(
                                  buttonText,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            : empty,
                        transitionBuilder: _horizontalRevealTransitionBuilder,
                      ),
                      if (!_isStream)
                        AnimatedShowHide(
                          showDuration: const Duration(milliseconds: 550),
                          hideDuration: const Duration(milliseconds: 350),
                          isShown: !updateProgress.installationIsInProgress,
                          child: LoadingIconButton(
                            onPressed: _onCheckForUpdate,
                            icon: const Icon(Icons.refresh_rounded),
                          ),
                          transitionBuilder: _horizontalRevealTransitionBuilder,
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: progressBar,
                ),
                AnimatedShowHide(
                  showDuration: const Duration(milliseconds: 350),
                  hideDuration: const Duration(milliseconds: 250),
                  isShown: updateAvailable,
                  transitionBuilder: _verticalRevealTransitionBuilder,
                  showCurve: Curves.easeOut,
                  hideCurve: Curves.easeOut,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(
                        indent: 16,
                        endIndent: 16,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          top: 12,
                          bottom: 4,
                        ),
                        child: Text(
                          "${"Change log".translate()}:",
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Flexible(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(
                            left: 8,
                            right: 8,
                            bottom: 8,
                          ),
                          shrinkWrap: true,
                          itemBuilder: (context, index) => _ChangeLogItem(
                            change: updateInfo?.changeLogs[index] ?? "",
                          ),
                          itemCount: updateInfo?.changeLogs.length ?? 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: UpdaterListener(
        taskListenerCategories: const {
          TaskListenerCategory.downloadProgressRatio,
          TaskListenerCategory.status,
        },
        /*shouldRebuild: (oldTaskProgress, newTaskProgress) {
          return (oldTaskProgress.completionRatio !=
                  newTaskProgress.completionRatio) ||
              (oldTaskProgress.installationIsInProgress !=
                  newTaskProgress.installationIsInProgress);
        },*/
        builder: (context, updateProgress, _) {
          final bool downloadProgressIsNotNull =
              (updateProgress.downloadTaskProgress != null) && (updateProgress.downloadTaskProgress!.total > 0);

          final String downloadProgressText = downloadProgressIsNotNull
              ? [
                  updateProgress.downloadTaskProgress!.completed
                      .toFileSizePrettyString(),
                  updateProgress.downloadTaskProgress!.total
                      .toFileSizePrettyString(),
                ].join("/")
              : "";
          //logER("Download Progress: ${updateProgress.downloadTaskProgress}");
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedShowHide(
                showDuration: const Duration(milliseconds: 350),
                hideDuration: const Duration(milliseconds: 250),
                isShown: updateProgress.installationIsInProgress,
                child: LinearProgressIndicator(
                  value: updateProgress.completionRatio,
                ),
                transitionBuilder: _verticalRevealTransitionBuilder,
              ),
              AnimatedShowHide(
                isShown: downloadProgressIsNotNull,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(downloadProgressText),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _controllerWrapperBuilder() {
    if (_isStream) {
      return StreamDataObserver<StreamDataObservable<UpdateInfo>>(
        observable: _controller as StreamDataObservable<UpdateInfo>,
        dataIsEmpty: (_) => false,
        builder: _mainBuilder,
      );
    } else {
      return DataGenerateObserver<SingleGenerateObservable<UpdateInfo>>(
        observable: _controller as SingleGenerateObservable<UpdateInfo>,
        dataIsEmpty: (_) => false,
        builder: _mainBuilder,
      );
    }
  }

  Widget _verticalRevealTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Widget child,
  ) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: const Interval(0, 0.5),
        ),
        child: child,
      ),
    );
  }

  Widget _horizontalRevealTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Widget child,
  ) {
    return SizeTransition(
      axis: Axis.horizontal,
      sizeFactor: animation,
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: const Interval(0, 0.5),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _controllerWrapperBuilder();
  }
}

class _ChangeLogItem extends StatelessWidget {
  final String change;

  const _ChangeLogItem({
    // ignore: unused_element
    super.key,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.circle,
            size: 6,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(change),
          ),
        ],
      ),
    );
  }
}
