part of controllers;

typedef SharedPreferencesListenerCallback<T> = void Function(T value);

class SharedPreferenceKeys {
  const SharedPreferenceKeys();

  String get firstTime => "first_time";

  String get notificationPermissionDenied => "notification_permission_denied";

  String get detectMuicActivities => "detect_music_activities";

  String get translationLanguage => "translation_language";
}

abstract class SharedPreferencesHelper {
  @pragma("vm:entry-point")
  static SharedPreferences? _prefs;

  @pragma("vm:entry-point")
  static bool get isInitialized => _prefs != null;

  @pragma("vm:entry-point")
  static bool get isNotInitialized => _prefs == null;

  @pragma("vm:entry-point")
  static const SharedPreferenceKeys keys = SharedPreferenceKeys();

  @pragma("vm:entry-point")
  static final Map<String?, List<SharedPreferencesListenerCallback>>
      _listeners = {};

  @pragma("vm:entry-point")
  static void addListener(
    SharedPreferencesListenerCallback callback, {
    String? key,
  }) {
    _listeners[key] = [
      if (_listeners.containsKey(key)) ..._listeners[key]!,
      callback,
    ];
  }

  @pragma("vm:entry-point")
  static void removeListener(
    SharedPreferencesListenerCallback callback, {
    String? key,
  }) {
    if (key == null) {
      _listeners[key]!.remove(callback);
      return;
    }
    if (_listeners.containsKey(key)) {
      _listeners[key]!.remove(callback);
    }
  }

  @pragma("vm:entry-point")
  static void notifyListenersForKey(String? key) {
    final value = (key == null) ? null : getValue(key);

    final List<SharedPreferencesListenerCallback>? listeners = _listeners[key];

    if (listeners != null) {
      for (final SharedPreferencesListenerCallback listener in listeners) {
        listener(value);
      }
    }

    if (key != null) {
      notifyListenersForKey(null);
    }
  }

  @pragma("vm:entry-point")
  static T? getValue<T>(String key) {
    if (isNotInitialized) {
      throw "SharedPreferenceHelper is not yet initialized";
    }
    return _prefs!.get(key) as T?;
  }

  @pragma("vm:entry-point")
  static Future<void> setValue<T extends Object>(String key, T value) async {
    if (isNotInitialized) {
      throw "SharedPreferenceHelper is not yet initialized";
    }
    switch (T) {
      case bool:
        await _prefs!.setBool(key, value as bool);
        break;
      case int:
        await _prefs!.setInt(key, value as int);
        break;
      case double:
        await _prefs!.setDouble(key, value as double);
        break;
      case String:
        await _prefs!.setString(key, value as String);
        break;
      case List<String>:
        await _prefs!.setStringList(key, value as List<String>);
        break;
      default:
        throw "Unsupported value type!";
    }
    notifyListenersForKey(key);
  }

  @pragma("vm:entry-point")
  static Future<void> removeValue(String key) async {
    if (isNotInitialized) {
      throw "SharedPreferenceHelper is not yet initialized";
    }
    await _prefs!.remove(key);
    notifyListenersForKey(key);
  }

  @pragma("vm:entry-point")
  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @pragma("vm:entry-point")
  static bool isFirstTime({AsyncCallback? callbackToWaitBeforeSettingFalse}) {
    final String key = keys.firstTime;
    final bool result = _prefs?.getBool(key) ?? true;
    if (result) {
      if (callbackToWaitBeforeSettingFalse != null) {
        callbackToWaitBeforeSettingFalse().then(
          (_) {
            _prefs?.setBool(key, false).then((_) {
              notifyListenersForKey(key);
            });
          },
        );
      } else {
        _prefs?.setBool(key, false).then((_) {
          notifyListenersForKey(key);
        });
      }
    }
    return result;
  }

  @pragma("vm:entry-point")
  static bool isNotificationPermissionDenied() {
    return _prefs?.getBool(keys.notificationPermissionDenied) ?? false;
  }

  @pragma("vm:entry-point")
  // ignore: avoid_positional_boolean_parameters
  static Future<void> setNotificationPermissionDenied(bool value) async {
    final String key = keys.notificationPermissionDenied;
    await _prefs?.setBool(key, value);
    notifyListenersForKey(key);
  }

  @pragma("vm:entry-point")
  // ignore: avoid_positional_boolean_parameters
  static Future<void> setDetectMusicActivities(bool value) async {
    final String key = keys.detectMuicActivities;
    await _prefs?.setBool(keys.detectMuicActivities, value);
    notifyListenersForKey(key);
  }

  @pragma("vm:entry-point")
  // ignore: avoid_positional_boolean_parameters
  static bool getDetectMusicActivities() {
    return _prefs?.getBool(keys.detectMuicActivities) ?? false;
  }
}
