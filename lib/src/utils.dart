library utils;

import 'package:flutter/material.dart';
import 'package:lyrics/src/widgets.dart';
import 'package:marquee_widget/marquee_widget.dart';

part 'utils/all_white.dart';
part 'utils/marquee_text.dart';
part 'utils/app_bottom_navigation_bar.dart';

TextTheme getTextThemeForStyle(TextStyle style) {
  /*TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? displaySmall,
    this.headlineLarge,
    TextStyle? headlineMedium,
    TextStyle? headlineSmall,
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? titleSmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelLarge,
    this.labelMedium,
    TextStyle? labelSmall,
    TextStyle? headline1,
    TextStyle? headline2,
    TextStyle? headline3,
    TextStyle? headline4,
    TextStyle? headline5,
    TextStyle? headline6,
    TextStyle? subtitle1,
    TextStyle? subtitle2,
    TextStyle? bodyText1,
    TextStyle? bodyText2,
    TextStyle? caption,
    TextStyle? button,
    TextStyle? overline,*/
  /*displayLarge == null && displayMedium == null && displaySmall == null && headlineMedium == null &&
             headlineSmall == null && titleLarge == null && titleMedium == null && titleSmall == null &&
             bodyLarge == null && bodyMedium == null && bodySmall == null && labelLarge == null && labelSmall == null*/
  /*headline1 == null && headline2 == null && headline3 == null && headline4 == null &&
             headline5 == null && headline6 == null && subtitle1 == null && subtitle2 == null &&
             bodyText1 == null && bodyText2 == null && caption == null && button == null && overline == null*/

  return TextTheme(
    headline1: style.copyWith(fontWeight: FontWeight.w900),
    headline2: style.copyWith(fontWeight: FontWeight.w800),
    headline3: style.copyWith(fontWeight: FontWeight.w700),
    headline4: style.copyWith(fontWeight: FontWeight.w600),
    headline5: style.copyWith(fontWeight: FontWeight.w600),
    headline6: style.copyWith(fontWeight: FontWeight.w600),
    subtitle1: style.copyWith(fontWeight: FontWeight.w400),
    subtitle2: style.copyWith(fontWeight: FontWeight.w500),
    bodyText1: style,
    bodyText2: style,
    caption: style,
    button: style.copyWith(fontWeight: FontWeight.w600),
    overline: style,
  );
}
