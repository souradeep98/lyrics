part of controllers;

abstract class SharedPreferencesHelper {
  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static bool isNotificationPermissionDenied() {
    return _prefs?.getBool("notification_permission_denied") ?? false;
  }

  // ignore: avoid_positional_boolean_parameters
  static Future<void> setNotificationPermissionDenied(bool value) async {
    await _prefs?.setBool("notification_permission_denied", value);
  }
}
