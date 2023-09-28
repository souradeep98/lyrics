part of '../widgets.dart';

class ProgressSlider extends StatefulWidget {
  final Duration totalDuration;
  final Duration currentDuration;
  final DateTime setAt;
  final ActivityState state;
  final Future<void> Function(Duration duration) onDurationChange;

  const ProgressSlider({
    super.key,
    required this.currentDuration,
    required this.totalDuration,
    required this.setAt,
    required this.state,
    required this.onDurationChange,
  });

  @override
  State<ProgressSlider> createState() => _ProgressSliderState();
}

class _ProgressSliderState extends State<ProgressSlider>
    with SingleTickerProviderStateMixin, LogHelperMixin {
  late final AnimationController _animationController;
  final Tween<double> _durationBoundTween = Tween<double>(begin: 0);

  @override
  void initState() {
    super.initState();
    _durationBoundTween.end = widget.totalDuration.inMilliseconds.toDouble();

    final (double, Duration) currentValue = _getCurrentValue();

    final double value = currentValue.$1;

    _animationController = AnimationController(
      vsync: this,
      value: value,
    );

    _playIfApplicable(currentDuration: currentValue.$2);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ProgressSlider oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.totalDuration != oldWidget.totalDuration) {
      _durationBoundTween.end = widget.totalDuration.inMilliseconds.toDouble();
    }

    final (double, Duration) currentValue = _getCurrentValue();

    //_animationController.value = currentValue.$1;
    _setAnimationControllerValue(currentValue.$1);
    _playIfApplicable(currentDuration: currentValue.$2);
  }

  void _setAnimationControllerValue(double value) {
    if (value > _animationController.value) {
      _animationController.animateTo(
        value,
        duration: Duration.zero,
      );
    } else if (value < _animationController.value) {
      _animationController.animateBack(
        value,
        duration: Duration.zero,
      );
    }
  }

  /// returns in bound 0 - 1, alongwise the calculated duration
  (double, Duration) _getCurrentValue() {
    final Duration currentDuration = _getCurrentDuration();
    return (
      projectDouble(
        value: currentDuration.inMilliseconds.toDouble(),
        oldMin: 0,
        oldMax: _durationBoundTween.end!,
        newMin: 0,
        newMax: 1,
      ),
      currentDuration,
    );
  }

  Duration _getCurrentDuration() {
    //logER("Set at: ${widget.setAt}");
    //logER("Set duration: ${widget.currentDuration}");

    final Duration setBefore = DateTime.now().difference(widget.setAt);

    //logER("Set before: $setBefore");

    return switch (widget.state) {
      ActivityState.playing => widget.currentDuration + setBefore,
      ActivityState.paused => widget.currentDuration,
    };
  }

  void _playIfApplicable({Duration? currentDuration}) {
    if (widget.state == ActivityState.playing) {
      logER("Playing...");
      _animationController.animateTo(
        1,
        duration:
            widget.totalDuration - (currentDuration ?? _getCurrentDuration()),
      );
    } else {
      logER("Stopping...");
      _animationController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final int currentMilliseconds =
            _durationBoundTween.evaluate(_animationController).toInt();
        final Duration currentDuration =
            Duration(milliseconds: currentMilliseconds);
        //logER("Building: $currentDuration");
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: CupertinoSlider(
                    value: _animationController.value,
                    onChanged: (x) {
                      //logER("onChanged");
                      _setAnimationControllerValue(x);
                      _playIfApplicable();
                    },
                    onChangeEnd: (value) async {
                      await widget.onDurationChange(currentDuration);
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentDuration.clockDurationString(),
                  ),
                  child!,
                ],
              ),
            ),
          ],
        );
      },
      child: Text(
        widget.totalDuration.clockDurationString(),
      ),
    );
  }
}
