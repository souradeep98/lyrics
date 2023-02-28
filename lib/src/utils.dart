library utils;

import 'package:flutter/material.dart';
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
    displaySmall: style.copyWith(fontWeight: FontWeight.w700),
    displayMedium: style.copyWith(fontWeight: FontWeight.w800),
    displayLarge: style.copyWith(fontWeight: FontWeight.w900),
    
    headlineSmall: style.copyWith(fontWeight: FontWeight.w600),
    headlineMedium: style.copyWith(fontWeight: FontWeight.w600),
    headlineLarge: style.copyWith(fontWeight: FontWeight.w700),

    titleSmall: style.copyWith(fontWeight: FontWeight.w500),
    titleMedium: style.copyWith(fontWeight: FontWeight.w400),
    titleLarge: style.copyWith(fontWeight: FontWeight.w600),
    
    bodySmall: style,
    bodyMedium: style,
    bodyLarge: style,

    labelSmall: style,
    labelMedium: style,
    labelLarge: style.copyWith(fontWeight: FontWeight.w600),
  );
}
