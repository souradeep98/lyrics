import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lyrics/src/app.dart';
import 'package:lyrics/src/constants.dart';

Future<void> main() async {
  Paint.enableDithering = true;
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(kDefaultSystemUiOverlayStyle);
  await EasyLocalization.ensureInitialized();
  runApp(const Lyrics());
}
