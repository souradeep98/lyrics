part of controllers;


@pragma("vm:entry-point")
bool get isSupportedNotificationListening => !kIsWeb && Platform.isAndroid;

const bool notificationHuntEnabled = kDebugMode && true;

const List<String> notificationHuntPackageFilter = ["com.spotify.music"];

abstract class NotificationListenerHelper {
  @pragma("vm:entry-point")
  static StreamSubscription<DetectedPlayerData>? _filterSubscription;

  @pragma("vm:entry-point")
  static NotificationStreamFilter? _filter;

  @pragma("vm:entry-point")
  static final Map<String, ResolvedPlayerData> _detectedPlayers = {};

  @pragma("vm:entry-point")
  static final List<VoidCallback> _listeners = [];

  @pragma("vm:entry-point")
  static bool _serviceIsRunning = false;

  @pragma("vm:entry-point")
  static bool _initialized = false;

  @pragma("vm:entry-point")
  static bool get isInitialized => _initialized;

  @pragma("vm:entry-point")
  static Future<void> initialize() async {
    if (!isSupportedNotificationListening) {
      return;
    }
    if (_initialized) {
      return;
    }
    _initialized = true;
    _filter?.dispose();
    _filter = NotificationStreamFilter(millisecondsDelay: 100);
    _filterSubscription?.cancel();
    _filterSubscription = _filter?.stream.listen(_filterListener);
    await NotificationsListener.initialize(
      callbackHandle: _onData,
    );
    await startListening();
  }

  @pragma("vm:entry-point")
  static List<ResolvedPlayerData> getPlayers() {
    return _detectedPlayers.values.toList();
  }

  @pragma("vm:entry-point")
  static void addListener(VoidCallback callback) {
    //logExceptRelease("Listeners: ${_listeners.length}");
    if (!_serviceIsRunning) {
      startListening().then((_) {
        _listeners.add(callback);
      });
    } else {
      _listeners.add(callback);
    }
    //_listeners.add(callback);
  }

  @pragma("vm:entry-point")
  static void removeListener(VoidCallback callback) {
    _listeners.remove(callback);
    /*if (_listeners.isEmpty) {
      stopListening();
    }*/
  }

  @pragma("vm:entry-point")
  static Future<void> setState(ActivityState state, String key) async {
    if (state == ActivityState.playing) {
      await NotificationListenerHelper.play(key);
    } else {
      await NotificationListenerHelper.pause(key);
    }
  }

  @pragma("vm:entry-point")
  static Future<void> play(String packageName) async {
    final NotificationEvent? event = _detectedPlayers[packageName]?.latestEvent;

    if (event == null) {
      return;
    }

    await _detectedPlayers[packageName]?.player.actions.play(event);
  }

  @pragma("vm:entry-point")
  static Future<void> pause(String packageName) async {
    final NotificationEvent? event = _detectedPlayers[packageName]?.latestEvent;

    if (event == null) {
      return;
    }

    await _detectedPlayers[packageName]?.player.actions.pause(event);
  }

  @pragma("vm:entry-point")
  static Future<void> previous(String packageName) async {
    final NotificationEvent? event = _detectedPlayers[packageName]?.latestEvent;

    if (event == null) {
      return;
    }

    await _detectedPlayers[packageName]?.player.actions.previous(event);
  }

  @pragma("vm:entry-point")
  static Future<void> next(String packageName) async {
    final NotificationEvent? event = _detectedPlayers[packageName]?.latestEvent;

    if (event == null) {
      return;
    }

    await _detectedPlayers[packageName]?.player.actions.next(event);
  }

  @pragma("vm:entry-point")
  static Future<void> _onData(NotificationEvent event) async {
    logExceptRelease("onData");
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

    await initializeControllers();

    logExceptRelease("Passing detected player to filter");

    _filter?.onData(detectedPlayerData);
  }

  @pragma("vm:entry-point")
  static Future<void> _filterListener(DetectedPlayerData event) async {
    logExceptRelease("Filter listener called");
    final ResolvedPlayerData resolvedPlayerData = await event.resolve();
    logExceptRelease(
      "Got resolved player, isResolved: ${resolvedPlayerData.resolved}, isAppOpen: $appIsOpen",
    );
    _detectedPlayers[event.player.packageName] = resolvedPlayerData;
    _callListeners();
    if (resolvedPlayerData.resolved && !appIsOpen) {
      await NotificationManagementHelper.showViewLyricsNotificationFor(
        resolvedPlayerData.playerData,
      );
    } else {
      await NotificationManagementHelper.showAddLyricsNotificationFor(
        resolvedPlayerData.playerData,
      );
    }
  }

  @pragma("vm:entry-point")
  static void _callListeners() {
    for (final VoidCallback element in _listeners) {
      element();
    }
  }

  @pragma("vm:entry-point")
  static Future<void> startListening() async {
    logExceptRelease("Called startListening");
    if (!isSupportedNotificationListening) {
      return;
    }

    _serviceIsRunning = (await NotificationsListener.isRunning) ?? false;

    logExceptRelease("serviceIsRunning: $_serviceIsRunning");

    if (!_serviceIsRunning) {
      logExceptRelease("Starting Listener Service");

      await NotificationsListener.startService(
        //foreground: false,
        title: "Listening to music activities",
        //subTitle: "Detecting music activities on your device",
        description: "We will detect music activities on your device",
      );

      _serviceIsRunning = (await NotificationsListener.isRunning) ?? false;
    }
  }

  @pragma("vm:entry-point")
  static Future<void> stopListening() async {
    logExceptRelease("Called stopListening");
    if (!isSupportedNotificationListening) {
      return;
    }

    _serviceIsRunning = (await NotificationsListener.isRunning) ?? false;

    logExceptRelease("serviceIsRunning: $_serviceIsRunning");

    if (!_serviceIsRunning) {
      return;
    }

    logExceptRelease("Stopping Listener Service");

    await NotificationsListener.stopService();
    _serviceIsRunning = (await NotificationsListener.isRunning) ?? false;
  }

  @pragma("vm:entry-point")
  static Future<void> dispose() async {
    if (!isSupportedNotificationListening) {
      return;
    }
    if (!_initialized) {
      return;
    }
    _initialized = false;
    _filterSubscription?.cancel();
    _listeners.clear();
    await stopListening();
    _filter?.dispose();
  }
}
