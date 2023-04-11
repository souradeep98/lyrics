import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lyrics/src/app.dart';
import 'package:lyrics/src/constants.dart';
import 'package:lyrics/src/controllers.dart';

Future<void> main() async {
  Paint.enableDithering = true;
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(kDefaultSystemUiOverlayStyle);
  await SharedPreferencesHelper.initialize();
  runApp(const Lyrics());
}
