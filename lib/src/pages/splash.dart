part of '../pages.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeRevealAnimation;

  late final Future _chores;
  late final Future _animationFuture;
  late final Completer _animationCompleter;

  @override
  void initState() {
    super.initState();
    _animationCompleter = Completer();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _fadeRevealAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationFuture = _animationCompleter.future;
    _chores = _initialize();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        _animationController.forward().then((value) {
          _animationCompleter.complete();
        });
      },
    );
    _navigateToNextWhenTime();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    if (!mounted) {
      return;
    }

    await initializeControllers(
      callerRouteName: Routes.splash,
    );
  }

  Future<void> _navigateToNextWhenTime() async {
    await Future.wait<void>([
      _animationFuture,
      _chores,
    ]);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) => const Home(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: const Interval(0.6, 1, curve: Curves.ease),
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
        child: FadeTransition(
          opacity: _fadeRevealAnimation,
          child: Lottie.asset("assets/lottie/57276-astronaut-and-music.json"),
        ),
      ),
    );
  }
}
