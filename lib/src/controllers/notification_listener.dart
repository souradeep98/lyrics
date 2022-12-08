part of controllers;

bool get isSupportedNotificationListening => !kIsWeb && Platform.isAndroid;

const bool notificationHuntEnabled = kDebugMode && true;

const List<String> notificationHuntPackageFilter = ["com.spotify.music"];

abstract class NotificationListenerHelper {
  static StreamSubscription<dynamic>? _eventSubscription;
  static StreamSubscription<DetectedPlayerData>? _filterSubscription;

  static NotificationStreamFilter? _filter;

  static final Map<String, ResolvedPlayerData> _detectedPlayers = {};

  static final List<VoidCallback> _listeners = [];

  static bool serviceIsRunning = false;

  //static bool initialized = false;

  static Future<void> initialize() async {
    if (!isSupportedNotificationListening) {
      return;
    }
    _filter?.dispose();
    _filter = NotificationStreamFilter(millisecondsDelay: 100);
    _filterSubscription?.cancel();
    _filterSubscription = _filter?.stream.listen(_filterListener);
    await NotificationsListener.initialize();
  }

  static List<ResolvedPlayerData> getPlayers() {
    return _detectedPlayers.values.toList();
  }

  static void addListener(VoidCallback callback) {
    //logExceptRelease("Listeners: ${_listeners.length}");
    if (_listeners.isEmpty) {
      startListening().then((_) {
        _listeners.add(callback);
      });
    } else {
      _listeners.add(callback);
    }
    //_listeners.add(callback);
  }

  static void removeListener(VoidCallback callback) {
    _listeners.remove(callback);
    if (_listeners.isEmpty) {
      stopListening();
    }
  }

  static Future<void> setState(ActivityState state, String key) async {
    if (state == ActivityState.playing) {
      await NotificationListenerHelper.play(key);
    } else {
      await NotificationListenerHelper.pause(key);
    }
  }

  static Future<void> play(String packageName) async {
    final NotificationEvent? event = _detectedPlayers[packageName]?.latestEvent;

    if (event == null) {
      return;
    }

    await _detectedPlayers[packageName]?.player.actions.play(event);
  }

  static Future<void> pause(String packageName) async {
    final NotificationEvent? event = _detectedPlayers[packageName]?.latestEvent;

    if (event == null) {
      return;
    }

    await _detectedPlayers[packageName]?.player.actions.pause(event);
  }

  static Future<void> previous(String packageName) async {
    final NotificationEvent? event = _detectedPlayers[packageName]?.latestEvent;

    if (event == null) {
      return;
    }

    await _detectedPlayers[packageName]?.player.actions.previous(event);
  }

  static Future<void> next(String packageName) async {
    final NotificationEvent? event = _detectedPlayers[packageName]?.latestEvent;

    if (event == null) {
      return;
    }

    await _detectedPlayers[packageName]?.player.actions.next(event);
  }

  static void _onData(NotificationEvent event) {
    //logExceptRelease("onData");
    if (notificationHuntEnabled &&
        (notificationHuntPackageFilter.isEmpty ||
            notificationHuntPackageFilter.contains(event.packageName))) {
      final Map? raw = event.raw;
      final List largeIcon = (raw?.remove("largeIcon") as List?) ?? [];
      raw?.addAll({
        "largeIcon": largeIcon.length,
      });
      logExceptRelease(event.raw);
    }

    final RecognisedPlayer? player = RecognisedPlayers.getPlayer(event);

    if (player == null) {
      return;
    }

    final DetectedPlayerData detectedPlayerData = DetectedPlayerData(
      player: player,
      latestEvent: event,
    );

    _filter?.onData(detectedPlayerData);
  }

  static Future<void> _filterListener(DetectedPlayerData event) async {
    final ResolvedPlayerData resolvedPlayerData = await event.resolve();
    _detectedPlayers[event.player.packageName] = resolvedPlayerData;
    _callListeners();
    if (resolvedPlayerData.resolved && !appIsOpen) {
      // TODO: an song is detected
    }
  }

  static void _callListeners() {
    for (final VoidCallback element in _listeners) {
      element();
    }
  }

  static Future<void> startListening() async {
    logExceptRelease("Called startListening");
    if (!isSupportedNotificationListening) {
      return;
    }

    serviceIsRunning = (await NotificationsListener.isRunning) ?? false;

    logExceptRelease("serviceIsRunning: $serviceIsRunning");

    if (!serviceIsRunning) {
      logExceptRelease("Starting Listener Service");

      await NotificationsListener.startService(
        foreground: false,
        title: "Lyrics - Notification Listener Running",
        description:
            "Lyrics - Notification Listener is running. This will allow Lyrics app to listen to notifications of supported music apps of the device and detect what are they playing.",
      );
    }

    _eventSubscription?.cancel();

    _eventSubscription = NotificationsListener.receivePort
        ?.cast<NotificationEvent>()
        .listen(_onData);
  }

  static Future<void> stopListening() async {
    logExceptRelease("Called stopListening");
    if (!isSupportedNotificationListening) {
      return;
    }

    serviceIsRunning = (await NotificationsListener.isRunning) ?? false;

    logExceptRelease("serviceIsRunning: $serviceIsRunning");

    if (!serviceIsRunning) {
      return;
    }

    logExceptRelease("Stopping Listener Service");

    await NotificationsListener.stopService();
    serviceIsRunning = false;
  }

  static Future<void> dispose() async {
    if (!isSupportedNotificationListening) {
      return;
    }
    _eventSubscription?.cancel();
    _filterSubscription?.cancel();
    _listeners.clear();
    await stopListening();
    _filter?.dispose();
  }
}
