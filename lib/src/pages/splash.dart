part of pages;

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<bool> get _shouldRequestPermission async {
    return isSupportedNotificationListening &&
        !((await NotificationsListener.hasPermission) ?? false) &&
        !SharedPreferencesHelper.isNotificationPermissionDenied();
  }

  Future<void> _initialize() async {
    if (!mounted) {
      return;
    }

    await SharedPreferencesHelper.initialize();

    if (await _shouldRequestPermission && mounted) {
      await showPermissionRequest(context);
    }

    await Future.wait([
      NotificationListenerHelper.initialize(),
      DatabaseHelper.initialize(OfflineDatabase()),
    ]);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) => Home(
          animation: CurvedAnimation(
            parent: animation,
            curve: const Interval(0.6, 1, curve: Curves.ease),
          ),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: const Interval(0, 0.6, curve: Curves.ease),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 2000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset("assets/lottie/57276-astronaut-and-music.json"),
      ),
    );
  }
}
