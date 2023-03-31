library app;

import 'package:dynamic_color/dynamic_color.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lyrics/src/constants.dart';
import 'package:lyrics/src/globals.dart';
import 'package:lyrics/src/utils.dart';

class Lyrics extends StatefulWidget {
  const Lyrics({super.key});

  @override
  State<Lyrics> createState() => _LyricsState();
}

class _LyricsState extends State<Lyrics> with WidgetsBindingObserver {
  final TextTheme _textTheme = getTextThemeForStyle(GoogleFonts.alegreyaSans());
  final ElevatedButtonThemeData _elevatedButtonThemeData =
      ElevatedButtonThemeData(
    style: ButtonStyle(
      shape: MaterialStateProperty.all<OutlinedBorder?>(
        const StadiumBorder(),
      ),
    ),
  );
  final List<Locale> _locales = Locales.appLocales.values.toList();

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
  Widget build(BuildContext context) {
    return EasyLocalization(
      supportedLocales: _locales,
      path: appTranslationPath,
      fallbackLocale: Locales.defaultLocale,
      useFallbackTranslations: true,
      child: Builder(
        builder: (context) {
          return DynamicColorBuilder(
            builder: (lightColorScheme, darkColorScheme) {
              final ThemeData themeData = ThemeData(
                textTheme: _textTheme,
                primaryTextTheme: _textTheme,
                colorScheme: lightColorScheme ?? darkColorScheme,
                elevatedButtonTheme: _elevatedButtonThemeData,
                useMaterial3: true,
              );
              return MaterialApp(
                // ignore: avoid_redundant_argument_values
                showPerformanceOverlay: kProfileMode,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                navigatorKey: GKeys.navigatorKey,
                scaffoldMessengerKey: GKeys.scaffoldMessengerKey,
                debugShowCheckedModeBanner: false,
                title: 'Lyrics',
                theme: themeData,
                //home: const Splash(),
                initialRoute: Routes.splash,
                routes: Routes.routes,
              );
            },
          );
        },
      ),
    );
  }
}
