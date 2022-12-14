import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lyrics/src/constants.dart';
import 'package:lyrics/src/globals.dart';
import 'package:lyrics/src/pages.dart';
import 'package:lyrics/src/utils.dart';

void main() {
  Paint.enableDithering = true;
  SystemChrome.setSystemUIOverlayStyle(kDefaultSystemUiOverlayStyle);
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
        return MaterialApp(
          navigatorKey: GKeys.navigatorKey,
          scaffoldMessengerKey: GKeys.scaffoldMessengerKey,
          debugShowCheckedModeBanner: false,
          title: 'Lyrics',
          theme: ThemeData(
            textTheme: getTextThemeForStyle(GoogleFonts.alegreyaSans()),
            primaryTextTheme: getTextThemeForStyle(GoogleFonts.alegreyaSans()),
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
    );
  }
}
