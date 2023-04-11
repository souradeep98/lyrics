part of constants;

enum AppThemePresets {
  bright,
  dark,
  deviceBrightness,
  device;

  static AppThemePresets? fromString(String str) {
    switch (str) {
      case "AppThemePresets.bright":
        return bright;
      case "AppThemePresets.dark":
        return dark;
      case "AppThemePresets.device":
        return device;
      case "AppThemePresets.deviceBrightness":
        return deviceBrightness;
      default:
        return null;
    }
  }

  String get prettyName {
    switch (this) {
      case bright:
        return "Bright";
      case dark:
        return "Dark";
      case device:
        return "Device Theme";
      case deviceBrightness:
        return "Device Brightness";
    }
  }
}

abstract class AppThemes {
  static const bool _useMaterial3 = true;

  static final TextStyle _baseTextStyle = GoogleFonts.alegreyaSans();

  static final TextTheme _textTheme = getTextThemeForStyle(_baseTextStyle);

  static final ElevatedButtonThemeData _elevatedButtonThemeData =
      ElevatedButtonThemeData(
    style: ButtonStyle(
      shape: MaterialStateProperty.all<OutlinedBorder?>(
        const StadiumBorder(),
      ),
    ),
  );

  static final ThemeData _deviceThemeBase = ThemeData(
    textTheme: _textTheme,
    primaryTextTheme: _textTheme,
    elevatedButtonTheme: _elevatedButtonThemeData,
    useMaterial3: _useMaterial3,
  );

  static final ThemeData _lightTheme = ThemeData.light(
    useMaterial3: _useMaterial3,
  ).copyWith(
    textTheme: _textTheme,
    primaryTextTheme: _textTheme,
    elevatedButtonTheme: _elevatedButtonThemeData,
  );

  static final ThemeData _darkTheme = ThemeData.dark(
    useMaterial3: _useMaterial3,
  ).copyWith(
    textTheme: _textTheme,
    primaryTextTheme: _textTheme,
    elevatedButtonTheme: _elevatedButtonThemeData,
  );

  static ThemeData getDeviceTheme(ColorScheme? colorScheme) {
    return _deviceThemeBase.copyWith(
      colorScheme: colorScheme,
      brightness: colorScheme?.brightness,
    );
  }

  static ThemeData getThemeFromPreset({
    required AppThemePresets preset,
    required ColorScheme? colorScheme,
  }) {
    switch (preset) {
      case AppThemePresets.bright:
        return _lightTheme;
      case AppThemePresets.dark:
        return _darkTheme;
      case AppThemePresets.device:
        return getDeviceTheme(colorScheme);
      case AppThemePresets.deviceBrightness:
        return getThemeFromBrightness(colorScheme!.brightness);
    }
  }

  static ThemeData getThemeFromBrightness(Brightness brightness) {
    switch (brightness) {
      case Brightness.dark:
        return _darkTheme;
      case Brightness.light:
        return _lightTheme;
    }
  }
}

const SystemUiOverlayStyle kDefaultSystemUiOverlayStyle = SystemUiOverlayStyle(
  systemNavigationBarColor: Colors.transparent,
  systemNavigationBarDividerColor: Colors.transparent,
  systemNavigationBarIconBrightness: Brightness.light,
  systemNavigationBarContrastEnforced: false,
  statusBarColor: Colors.transparent,
  statusBarBrightness: Brightness.light,
  statusBarIconBrightness: Brightness.dark,
  systemStatusBarContrastEnforced: false,
);

const SystemUiOverlayStyle kWhiteSystemUiOverlayStyle = SystemUiOverlayStyle(
  systemNavigationBarColor: Colors.transparent,
  systemNavigationBarDividerColor: Colors.transparent,
  systemNavigationBarIconBrightness: Brightness.light,
  systemNavigationBarContrastEnforced: true,
  statusBarColor: Colors.transparent,
  statusBarBrightness: Brightness.light,
  statusBarIconBrightness: Brightness.light,
  systemStatusBarContrastEnforced: false,
);
