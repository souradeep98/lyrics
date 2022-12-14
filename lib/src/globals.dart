import 'package:flutter/material.dart';
import 'package:flutter_essentials/flutter_essentials.dart';
import 'package:logger/logger.dart';
import 'package:lyrics/src/helpers.dart';

final Logger logger = Logger();

abstract class GKeys {
  @pragma("vm:entry-point")
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @pragma("vm:entry-point")
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
}

@pragma("vm:entry-point")
AppLifecycleState _currentAppState = AppLifecycleState.detached;

@pragma("vm:entry-point")
bool get appIsOpen {
  return [
    AppLifecycleState.resumed,
    AppLifecycleState.inactive,
  ].contains(_currentAppState);
}

@pragma("vm:entry-point")
// ignore: avoid_positional_boolean_parameters
set currentAppState(AppLifecycleState value) {
  logExceptRelease("AppLifecycleState: $value");
  _currentAppState = value;
  onAppLifeCycleStateChange(isForeground: appIsOpen);
}
