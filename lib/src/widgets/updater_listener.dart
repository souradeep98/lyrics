part of '../widgets.dart';

typedef UpdaterListenerBuilder = Widget Function(
  BuildContext context,
  TaskProgressInformation updateProgress,
  Widget? child,
);

class UpdaterListener extends StatefulWidget {
  final UpdaterListenerBuilder builder;
  final Set<TaskListenerCategory> taskListenerCategories;
  final bool Function(
    TaskProgressInformation oldTaskProgress,
    TaskProgressInformation newTaskProgress,
  )? shouldRebuild;
  final Widget? child;

  const UpdaterListener({
    super.key,
    required this.builder,
    required this.taskListenerCategories,
    this.child,
    this.shouldRebuild,
  });

  @override
  State<UpdaterListener> createState() => _UpdaterListenerState();
}

class _UpdaterListenerState extends State<UpdaterListener> {
  late TaskProgressInformation _progressInformation;

  @override
  void initState() {
    super.initState();
    _progressInformation = Updater.currentTaskProgressInformation;
    _addListenersFor(widget.taskListenerCategories);
  }

  @override
  void dispose() {
    _removeListenersFor(widget.taskListenerCategories);
    super.dispose();
  }

  @override
  void didUpdateWidget(UpdaterListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    _removeListenersFor(oldWidget.taskListenerCategories);
    _addListenersFor(widget.taskListenerCategories);
  }

  void _addListenersFor(Iterable<TaskListenerCategory> categories) {
    for (final TaskListenerCategory category in categories) {
      Updater.addListener(
        _listener,
        taskListenerCategory: category,
      );
    }
  }

  void _removeListenersFor(Iterable<TaskListenerCategory> categories) {
    for (final TaskListenerCategory category in categories) {
      Updater.addListener(
        _listener,
        taskListenerCategory: category,
      );
    }
  }

  void _listener(TaskProgressInformation progressInformation) {
    final bool shouldRebuild =
        widget.shouldRebuild?.call(_progressInformation, progressInformation) ??
            true;
    _progressInformation = progressInformation;
    if (mounted && shouldRebuild) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _progressInformation,
      widget.child,
    );
  }
}
