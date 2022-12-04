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

class Lyrics extends StatelessWidget {
  // ignore: use_super_parameters
  const Lyrics({Key? key}) : super(key: key);

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
          ),
          home: const Splash(),
        );
      },
    );
  }
}
