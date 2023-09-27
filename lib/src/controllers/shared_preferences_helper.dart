part of '../controllers.dart';

typedef SharedPreferencesListenerCallback<T> = void Function(T value);

class _SharedPreferenceKeys {
  const _SharedPreferenceKeys();

  String get firstTime => "first_time";

  String get notificationPermissionDenied => "notification_permission_denied";

  String get detectMuicActivities => "detect_music_activities";

  String get appLocale => "app_locale";

  String get lyricsTranslationLanguage => "lyrics_translation_language";

  String get appThemePreset => "app_theme_preset";
}

abstract final class SharedPreferencesHelper {
  @pragma("vm:entry-point")
  static SharedPreferences? _prefs;

  @pragma("vm:entry-point")
  static bool get isInitialized => _prefs != null;

  @pragma("vm:entry-point")
  static bool get isNotInitialized => _prefs == null;

  @pragma("vm:entry-point")
  static const _SharedPreferenceKeys keys = _SharedPreferenceKeys();

  @pragma("vm:entry-point")
  static final Map<String?, List<SharedPreferencesListenerCallback>>
      _listeners = {};

  @pragma("vm:entry-point")
  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

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
    final List<SharedPreferencesListenerCallback>? listeners = _listeners[key];

    final value = (key == null) ? null : getValue(key);

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
    switch (T) {
      case const (bool):
        return _prefs!.getBool(key) as T?;
      case const (int):
        return _prefs!.getInt(key) as T?;
      case const  (double):
        return _prefs!.getDouble(key) as T?;
      case const  (String):
        return _prefs!.getString(key) as T?;
      case const (List<String>):
        return _prefs!.getStringList(key) as T?;
      default:
        return _prefs!.get(key) as T?;
    }
  }

  @pragma("vm:entry-point")
  static Future<void> setValue<T>(String key, T value) async {
    if (isNotInitialized) {
      throw "SharedPreferenceHelper is not yet initialized";
    }

    final Type resolvedType =
        (T.toString() == "dynamic") ? value.runtimeType : T;

    const List<Type> supportedTypes = [bool, int, double, String, List<String>];

    if (!supportedTypes.contains(resolvedType)) {
      throw "Unsupported value type: $resolvedType";
    }

    final T? oldValue = getValue(key);

    if (oldValue == value) {
      return;
    }

    switch (resolvedType) {
      case const (bool):
        await _prefs!.setBool(key, value as bool);
      case const (int):
        await _prefs!.setInt(key, value as int);
      case const (double):
        await _prefs!.setDouble(key, value as double);
      case const (String):
        await _prefs!.setString(key, value as String);
      case const (List<String>):
        await _prefs!.setStringList(key, value as List<String>);
      default:
        throw "Unsupported value type: $resolvedType";
    }
    notifyListenersForKey(key);
  }

  @pragma("vm:entry-point")
  static Future<void> removeValue(String key) async {
    if (isNotInitialized) {
      throw "SharedPreferenceHelper is not yet initialized";
    }
    if (_prefs!.containsKey(key)) {
      await _prefs!.remove(key);
      notifyListenersForKey(key);
    }
  }

  //! third party helpers
  @pragma("vm:entry-point")
  static bool isFirstTime({Future? futureToWaitForBeforeSettingFalse}) {
    final String key = keys.firstTime;
    final bool result = _prefs?.getBool(key) ?? true;
    if (result) {
      if (futureToWaitForBeforeSettingFalse != null) {
        futureToWaitForBeforeSettingFalse.then(
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
    await setValue<bool>(keys.notificationPermissionDenied, value);
  }

  @pragma("vm:entry-point")
  // ignore: avoid_positional_boolean_parameters
  static Future<void> setDetectMusicActivities(bool value) async {
    await setValue<bool>(keys.detectMuicActivities, value);
  }

  @pragma("vm:entry-point")
  // ignore: avoid_positional_boolean_parameters
  static bool getDetectMusicActivities() {
    return _prefs?.getBool(keys.detectMuicActivities) ?? false;
  }

  @pragma("vm:entry-point")
  static Locale? getDeviceLocale() {
    final String? savedStr = _prefs?.getString(keys.appLocale);
    if (savedStr == null) {
      return null;
    }
    return savedStr.toLocale();
  }

  @pragma("vm:entry-point")
  static String? getDeviceLocaleName() {
    final String? savedStr = _prefs?.getString(keys.appLocale);
    return savedStr;
  }

  @pragma("vm:entry-point")
  static Future<void> setDeviceLocale(Locale? locale) async {
    final String key = keys.appLocale;
    if (locale == null) {
      await removeValue(key);
    } else {
      await setValue<String>(key, locale.toString());
    }
  }

  @pragma("vm:entry-point")
  static AppThemePresets? getAppThemePreset() {
    final String? result = _prefs?.getString(keys.appThemePreset);
    if (result == null) {
      return null;
    }

    return AppThemePresets.fromString(result)!;
  }

  @pragma("vm:entry-point")
  static Future<void> setAppThemePreset(AppThemePresets preset) async {
    await setValue<String>(keys.appThemePreset, preset.toString());
  }

  @pragma("vm:entry-point")
  static String? getLyricsTranslationLanguage() {
    return _prefs?.getString(keys.lyricsTranslationLanguage);
  }

  @pragma("vm:entry-point")
  static Future<void> setLyricsTranslationLanguage(String? languageCode) async {
    final String key = keys.lyricsTranslationLanguage;
    if (languageCode == null) {
      await removeValue(key);
    } else {
      await setValue<String>(key, languageCode);
    }
  }
}
