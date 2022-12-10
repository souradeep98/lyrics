import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

abstract class GKeys {
  @pragma("vm:entry-point")
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  
  @pragma("vm:entry-point")
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
}

bool appIsOpen = false;
