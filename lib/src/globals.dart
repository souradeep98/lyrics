import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:lyrics/src/structures.dart';

final Logger logger = Logger();

abstract class GKeys {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
}

bool appIsOpen = false;

final LyricsAppDatabase lyricsAppDatabase = OfflineDatabase();
