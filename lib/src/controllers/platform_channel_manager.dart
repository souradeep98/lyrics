part of '../controllers.dart';

abstract final class PlatformChannelManager {
  @pragma("vm:entry-point")
  static bool get isSupportedNotificationListening =>
      !kIsWeb && Platform.isAndroid;

  @pragma("vm:entry-point")
  static const String _methodChannelName = "com.lyrics.app:method_channel";

  @pragma("vm:entry-point")
  static const MethodChannel _methodChannel = MethodChannel(_methodChannelName);

  @pragma("vm:entry-point")
  static Future<void> startAllServicesAndListeners() async {
    await _methodChannel.invokeMethod<void>("startAllServicesAndListeners");
  }

  @pragma("vm:entry-point")
  static Future<void> stopAllServicesAndListeners() async {
    await _methodChannel.invokeMethod<void>("stopAllServicesAndListeners");
  }

  @pragma("vm:entry-point")
  static const _NotificationPlatformMethods notification =
      _NotificationPlatformMethods(methodChannel: _methodChannel);

  @pragma("vm:entry-point")
  static const _WakeLockPlatformMethods wakelock =
      _WakeLockPlatformMethods(methodChannel: _methodChannel);

  @pragma("vm:entry-point")
  static final _MediaSessionPlatformMethods mediaSessions =
      _MediaSessionPlatformMethods(methodChannel: _methodChannel);
}

abstract class _MethodGroup {
  final String groupName;

  const _MethodGroup({
    required this.groupName,
  });

  String getFullMethodName(String methodName) => "$groupName.$methodName";
}

class _NotificationPlatformMethods extends _MethodGroup {
  final MethodChannel methodChannel;
  const _NotificationPlatformMethods({required this.methodChannel})
      : super(groupName: "notification");

  Future<void> startListenerService() async {
    await methodChannel.invokeMethod<void>(
      getFullMethodName("start_notification_service"),
    );
  }

  Future<void> stopListenerService() async {
    await methodChannel.invokeMethod<void>(
      getFullMethodName("stop_notification_service"),
    );
  }

  Future<bool> isServiceRunning() async {
    return methodChannel
        .invokeMethod<bool>(
          getFullMethodName("is_service_running"),
        )
        .then((value) => value!);
  }

  Future<bool> isNotificationAccessPermissionGiven() async {
    return methodChannel
        .invokeMethod<bool>(
          getFullMethodName("is_notification_access_permission_given"),
        )
        .then((value) => value!);
  }

  Future<void> openNotificationAccessPermissionSettings() async {
    await methodChannel.invokeMethod<void>(
      getFullMethodName("open_notification_access_permission_settings"),
    );
  }

  Future<dynamic> getOngoingNotifications() async {
    await methodChannel.invokeMethod<dynamic>(
      getFullMethodName("get_ongoing_notifications"),
    );
  }
}

class _WakeLockPlatformMethods extends _MethodGroup {
  final MethodChannel methodChannel;

  const _WakeLockPlatformMethods({required this.methodChannel})
      : super(groupName: "wakelock");

  Future<void> acquireWakelock() async {
    await methodChannel.invokeMethod<void>(
      getFullMethodName("acquire_wakelock"),
    );
  }

  Future<void> releaseWakelock() async {
    await methodChannel.invokeMethod<void>(
      getFullMethodName("release_wakelock"),
    );
  }

  Future<bool> isAcquiredWakelock() async {
    return methodChannel
        .invokeMethod<bool>(
          getFullMethodName("is_acquired_wakelock"),
        )
        .then((value) => value!);
  }
}

class _MediaSessionPlatformMethods extends _MethodGroup {
  final MethodChannel methodChannel;

  final _MediaSessionControlPlatformMethods controls;

  @pragma("vm:entry-point")
  static const String _mediaSessionsEventChannelName =
      "com.lyrics.app:event_channel-media_sessions";

  @pragma("vm:entry-point")
  static const EventChannel _mediaSessionsEventChannel =
      EventChannel(_mediaSessionsEventChannelName);

  _MediaSessionPlatformMethods({required this.methodChannel})
      : controls =
            _MediaSessionControlPlatformMethods(methodChannel: methodChannel),
        super(groupName: "media_session");

  Future<void> initialize({
    FutureOr<void> Function()? dartSideInitializerCallback,
  }) async {
    final CallbackHandle? handle = dartSideInitializerCallback == null
        ? null
        : PluginUtilities.getCallbackHandle(dartSideInitializerCallback);
    final int? rawHandle = handle?.toRawHandle();

    await methodChannel.invokeMethod<void>(
      getFullMethodName("initialize"),
      rawHandle,
    );
  }

  Future<dynamic> getSessions() async {
    final List<dynamic> result = await methodChannel
        .invokeListMethod(
          getFullMethodName("get_sessions"),
        )
        .then((value) => value!);

    //TODO: implement MediaInfo

    return result;
  }

  Future<void> refresh() async {
    await methodChannel.invokeMethod<void>(
      getFullMethodName("refresh"),
    );
  }

  Stream<dynamic> getMediaSessionsStream() {
    //TODO: implement MediaInfo
    return _mediaSessionsEventChannel.receiveBroadcastStream();
  }
}

class _MediaSessionControlPlatformMethods extends _MethodGroup {
  final MethodChannel methodChannel;

  const _MediaSessionControlPlatformMethods({required this.methodChannel})
      : super(groupName: "media_session.controls");

  Future<void> play(String packageName) async {
    await methodChannel.invokeMethod<void>(
      getFullMethodName("play"),
      packageName,
    );
  }

  Future<void> pause(String packageName) async {
    await methodChannel.invokeMethod<void>(
      getFullMethodName("pause"),
      packageName,
    );
  }

  Future<void> skipToNext(String packageName) async {
    await methodChannel.invokeMethod<void>(
      getFullMethodName("skipToNext"),
      packageName,
    );
  }

  Future<void> skipToPrevious(String packageName) async {
    await methodChannel.invokeMethod<void>(
      getFullMethodName("skipToPrevious"),
      packageName,
    );
  }

  Future<void> fastForward(String packageName) async {
    await methodChannel.invokeMethod<void>(
      getFullMethodName("fastForward"),
      packageName,
    );
  }

  Future<void> rewind(String packageName) async {
    await methodChannel.invokeMethod<void>(
      getFullMethodName("rewind"),
      packageName,
    );
  }

  Future<void> prepare(String packageName) async {
    await methodChannel.invokeMethod<void>(
      getFullMethodName("prepare"),
      packageName,
    );
  }

  Future<void> stop(String packageName) async {
    await methodChannel.invokeMethod<void>(
      getFullMethodName("stop"),
      packageName,
    );
  }

  Future<void> seekTo(String packageName, Duration duration) async {
    await methodChannel.invokeMethod<void>(
      getFullMethodName("seekTo"),
      {
        "packageName": packageName,
        "duration": duration.inMilliseconds,
      },
    );
  }

  Future<void> setPlaybackSpeed(String packageName, double speed) async {
    if (speed == 0) {
      throw "Setting playback speed to 0 is not allowed";
    }
    await methodChannel.invokeMethod<void>(
      getFullMethodName("setPlaybackSpeed"),
      {
        "packageName": packageName,
        "speed": speed,
      },
    );
  }
}
