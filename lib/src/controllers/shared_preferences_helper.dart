part of controllers;

abstract class SharedPreferencesHelper {
  @pragma("vm:entry-point")
  static SharedPreferences? _prefs;

  @pragma("vm:entry-point")
  static bool get isInitialized => _prefs != null;

  @pragma("vm:entry-point")
  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @pragma("vm:entry-point")
  static bool isFirstTime({AsyncCallback? callbackToWaitBeforeSettingFalse}) {
    final bool result = _prefs?.getBool("first_time") ?? true;
    if (result) {
      if (callbackToWaitBeforeSettingFalse != null) {
        callbackToWaitBeforeSettingFalse().then(
          (_) {
            _prefs?.setBool("first_time", false);
          },
        );
      } else {
        _prefs?.setBool("first_time", false);
      }
    }
    return result;
  }

  @pragma("vm:entry-point")
  static bool isNotificationPermissionDenied() {
    return _prefs?.getBool("notification_permission_denied") ?? false;
  }

  @pragma("vm:entry-point")
  // ignore: avoid_positional_boolean_parameters
  static Future<void> setNotificationPermissionDenied(bool value) async {
    await _prefs?.setBool("notification_permission_denied", value);
  }
}
