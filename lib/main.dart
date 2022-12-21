import 'package:dynamic_color/dynamic_color.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lyrics/src/constants.dart';
import 'package:lyrics/src/globals.dart';
import 'package:lyrics/src/pages.dart';
import 'package:lyrics/src/utils.dart';

Future<void> main() async {
  Paint.enableDithering = true;
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(kDefaultSystemUiOverlayStyle);
  await EasyLocalization.ensureInitialized();
  runApp(const Lyrics());
}

class Lyrics extends StatefulWidget {
  const Lyrics({super.key});

  @override
  State<Lyrics> createState() => _LyricsState();
}

class _LyricsState extends State<Lyrics> with WidgetsBindingObserver {
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
    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        return EasyLocalization(
          supportedLocales: const [Locale('en', 'US'), Locale('de', 'DE')],
          path: 'assets/translations',
          fallbackLocale: const Locale('en', 'US'),
          useFallbackTranslations: true,
          child: Builder(
            builder: (context) {
              return MaterialApp(
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                navigatorKey: GKeys.navigatorKey,
                scaffoldMessengerKey: GKeys.scaffoldMessengerKey,
                debugShowCheckedModeBanner: false,
                title: 'Lyrics',
                theme: ThemeData(
                  textTheme: getTextThemeForStyle(GoogleFonts.alegreyaSans()),
                  primaryTextTheme:
                      getTextThemeForStyle(GoogleFonts.alegreyaSans()),
                  colorScheme: lightColorScheme ?? darkColorScheme,
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<OutlinedBorder?>(
                        const StadiumBorder(),
                      ),
                    ),
                  ),
                ),
                home: const Splash(),
              );
            },
          ),
        );
      },
    );
  }
}
