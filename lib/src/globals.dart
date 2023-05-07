import 'package:flutter/material.dart';
import 'package:flutter_essentials/flutter_essentials.dart';
import 'package:hive_flutter/hive_flutter.dart';
//import 'package:logger/logger.dart';
import 'package:lyrics/src/helpers.dart';

//final Logger logger = Logger();

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
  return const [
    AppLifecycleState.resumed,
    AppLifecycleState.inactive,
  ].contains(_currentAppState);
}

@pragma("vm:entry-point")
// ignore: avoid_positional_boolean_parameters
set currentAppState(AppLifecycleState value) {
  logExceptRelease(
    value,
    name: "AppLifecycleState",
  );
  _currentAppState = value;
  onAppLifeCycleStateChange(isForeground: appIsOpen);
}

Future<void>? _initializeHiveFuture;

Future<void> initializeHive() async {
  return _initializeHiveFuture ??= _initializeHive();
}

Future<void> _initializeHive() async {
  await Hive.initFlutter();
}
