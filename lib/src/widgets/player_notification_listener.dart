part of '../widgets.dart';

typedef PlayerNotificationListenerBuilder = Widget Function(
  BuildContext context,
  List<ResolvedPlayerData> detectedPlayers,
  Widget? child,
);

class PlayerNotificationListener extends StatefulWidget {
  final PlayerNotificationListenerBuilder builder;
  final Widget? child;

  const PlayerNotificationListener({
    super.key,
    required this.builder,
    this.child,
  });

  @override
  State<PlayerNotificationListener> createState() =>
      _PlayerNotificationListenerState();
}

class _PlayerNotificationListenerState
    extends State<PlayerNotificationListener> {
  @override
  void initState() {
    super.initState();
    MediaInfoListenableHelper.addListener(_listener);
  }

  @override
  void dispose() {
    MediaInfoListenableHelper.removeListener(_listener);
    super.dispose();
  }

  void _listener() {
    setState(
      () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      MediaInfoListenableHelper.sessions.values.toList(),
      widget.child,
    );
  }
}
