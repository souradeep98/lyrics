/// This is the main app
library app;

import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lyrics/src/constants.dart';
import 'package:lyrics/src/controllers.dart';
import 'package:lyrics/src/globals.dart';
import 'package:lyrics/src/helpers.dart';
import 'package:lyrics/src/utils.dart';
import 'package:lyrics/src/widgets.dart';

class Lyrics extends StatefulWidget {
  const Lyrics({super.key});

  @override
  State<Lyrics> createState() => _LyricsState();
}

class _LyricsState extends State<Lyrics> with WidgetsBindingObserver {
  final List<Locale> _locales = AppLocales.appLocales.values.toList();
  late final List<LocalizationsDelegate<dynamic>> _localeDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    LocalJsonLocalizations.delegate,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    //appIsOpen = true;
  }

  @override
  void dispose() {
    //appIsOpen = false;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    currentAppState = state;
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SharedPreferenceListener<Locale, void>(
      sharedPreferenceKey: SharedPreferencesHelper.keys.appLocale,
      valueIfNull: Platform.localeName.toLocale(),
      valueGetter: (_) {
        return SharedPreferencesHelper.getDeviceLocale();
      },
      builder: (context, locale, _) {
        //logExceptRelease("StartLocale: $locale", name: "Test",);

        return DynamicColorBuilder(
          builder: (lightColorScheme, darkColorScheme) {
            return SharedPreferenceListener<AppThemePresets, void>(
              sharedPreferenceKey: SharedPreferencesHelper.keys.appThemePreset,
              valueIfNull: AppThemePresets.device,
              valueGetter: (_) {
                return SharedPreferencesHelper.getAppThemePreset();
              },
              builder: (context, value, _) {
                final ThemeData themeData = AppThemes.getThemeFromPreset(
                  preset: value,
                  colorScheme: lightColorScheme ?? darkColorScheme,
                );
                return TranslationsListener(
                  child: MaterialApp(
                    // ignore: avoid_redundant_argument_values
                    showPerformanceOverlay: kProfileMode,
                    localizationsDelegates: _localeDelegates,
                    supportedLocales: _locales,
                    locale: locale,
                    navigatorKey: GKeys.navigatorKey,
                    scaffoldMessengerKey: GKeys.scaffoldMessengerKey,
                    debugShowCheckedModeBanner: false,
                    title: 'Lyrics',
                    theme: themeData,
                    //home: const Splash(),
                    initialRoute: Routes.splash,
                    routes: Routes.routes,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
