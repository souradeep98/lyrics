part of '../widgets.dart';

class AppEmptyWidget extends StatelessWidget {
  const AppEmptyWidget({
    // ignore: unused_element
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const Widget musicNote = Icon(
      Icons.music_note,
      size: 26,
    );
    return ColoredBox(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Align(
                    alignment: const Alignment(0.35, 0.3),
                    child: Transform.scale(
                      scale: 0.52,
                      child: Transform.rotate(
                        angle: pi / 12,
                        child: musicNote,
                      ),
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0.22, 0.71),
                    child: Transform.scale(
                      scale: 0.65,
                      child: Transform.rotate(
                        angle: 12,
                        child: musicNote,
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: musicNote,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Text(
                "${'No lyrics for any songs were added'.translate()}...",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppLoadingIndicator extends StatefulWidget {
  final bool animate;
  final Color? backgroundColor;

  const AppLoadingIndicator({
    // ignore: unused_element
    super.key,
    // ignore: unused_element
    this.animate = true,
    this.backgroundColor,
  });

  @override
  State<AppLoadingIndicator> createState() => _AppLoadingIndicatorState();
}

class _AppLoadingIndicatorState extends State<AppLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _firstChildAnimation;
  late final Animation<double> _secondChildAnimation;
  late final Animation<double> _thirdChildAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
      reverseDuration: const Duration(milliseconds: 125),
      value: widget.animate ? null : 1,
    );

    _firstChildAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.5,
        0.8,
        curve: Curves.easeIn,
      ),
      reverseCurve: Curves.easeIn,
    );
    _secondChildAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.3,
        0.6,
        curve: Curves.easeIn,
      ),
      reverseCurve: Curves.easeIn,
    );
    _thirdChildAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.2,
        0.5,
        curve: Curves.easeIn,
      ),
      reverseCurve: Curves.easeIn,
    );

    if (widget.animate) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _play();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AppLoadingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && (!oldWidget.animate)) {
      _play();
    }
  }

  Future<void> _play() async {
    while (widget.animate) {
      await _animationController.forward();
      await _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    const Widget musicNote = Icon(
      Icons.music_note,
      size: 26,
    );
    return ColoredBox(
      color: widget.backgroundColor ?? Colors.white,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: const Alignment(0.25, -0.2),
            child: FadeTransition(
              opacity: _firstChildAnimation,
              child: Transform.scale(
                scale: 0.55,
                child: Transform.rotate(
                  angle: pi / 12,
                  child: musicNote,
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.08, -0.1),
            child: FadeTransition(
              opacity: _secondChildAnimation,
              child: Transform.scale(
                scale: 0.72,
                child: Transform.rotate(
                  angle: 12,
                  child: musicNote,
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(-0.1, 0),
            child: FadeTransition(
              opacity: _thirdChildAnimation,
              child: musicNote,
            ),
          ),
        ],
      ),
    );
  }
}
