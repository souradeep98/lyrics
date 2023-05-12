part of '../constants.dart';

abstract class Routes {
  static const String splash = "/splash";

  static final Map<String, WidgetBuilder> routes = {
    Routes.splash: (context) => const Splash(),
  };
}
