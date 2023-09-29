library utils;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_essentials/flutter_essentials.dart';
import 'package:lyrics/src/constants.dart';
import 'package:lyrics/src/widgets.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:path/path.dart';

part 'utils/all_white.dart';
part 'utils/marquee_text.dart';
part 'utils/local_json_localization.dart';

TextTheme getTextThemeForStyle(TextStyle style, {Color? color}) {
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
    displaySmall: style.copyWith(
      fontWeight: FontWeight.w700,
      color: color,
    ),
    displayMedium: style.copyWith(
      fontWeight: FontWeight.w800,
      color: color,
    ),
    displayLarge: style.copyWith(
      fontWeight: FontWeight.w900,
      color: color,
    ),
    headlineSmall: style.copyWith(
      fontWeight: FontWeight.w600,
      color: color,
    ),
    headlineMedium: style.copyWith(
      fontWeight: FontWeight.w600,
      color: color,
    ),
    headlineLarge: style.copyWith(
      fontWeight: FontWeight.w700,
      color: color,
    ),
    titleSmall: style.copyWith(
      fontWeight: FontWeight.w500,
      color: color,
    ),
    titleMedium: style.copyWith(
      fontWeight: FontWeight.w400,
      color: color,
    ),
    titleLarge: style.copyWith(
      fontWeight: FontWeight.w600,
      color: color,
    ),
    bodySmall: style.copyWith(
      color: color,
    ),
    bodyMedium: style.copyWith(
      color: color,
    ),
    bodyLarge: style.copyWith(
      color: color,
    ),
    labelSmall: style.copyWith(
      color: color,
    ),
    labelMedium: style.copyWith(
      color: color,
    ),
    labelLarge: style.copyWith(
      fontWeight: FontWeight.w600,
      color: color,
    ),
  );
}

class NullSaverCache {
  final Map<String, dynamic> _miniCache = {};
  T getCachedValue<T>(String key, T? value, T Function() defaultValueGetter) {
    if ((value == null) && (_miniCache[key] == null)) {
      return defaultValueGetter();
    }

    _miniCache[key] = value;
    return value ?? defaultValueGetter();
  }
}
