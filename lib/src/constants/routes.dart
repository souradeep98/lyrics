part of constants;

abstract class Routes {
  static const String splash = "/splash";

  static final Map<String, WidgetBuilder> routes = {
    Routes.splash: (context) => const Splash(),
  };
}
