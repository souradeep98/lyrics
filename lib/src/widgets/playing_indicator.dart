part of widgets;

class PlayingIndicator extends StatefulWidget {
  final int barsCount;
  final Color? color;
  final bool play;
  final double? width;
  final double? height;
  final double? gap;
  final bool backToStartWhenStopped;
  final double? stoppedHeight;

  const PlayingIndicator({
    super.key,
    this.color,
    this.barsCount = 3,
    this.play = true,
    this.width,
    this.gap,
    this.height,
    this.backToStartWhenStopped = true,
    this.stoppedHeight,
  });

  @override
  State<PlayingIndicator> createState() => _PlayingIndicatorState();
}

class _PlayingIndicatorState extends State<PlayingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late double _height;
  late double _stoppedHeight;
  late bool _shouldPlay;
  late bool _stopScheduled;
  late bool _wasScheduledStopped;
  bool? _isPlaying;

  @override
  void initState() {
    super.initState();
    _wasScheduledStopped = false;
    _stopScheduled = false;
    _height = widget.height ?? 10;
    _stoppedHeight = widget.stoppedHeight ?? 3;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _setNewTweens();
    _shouldPlay = widget.play;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_shouldPlay) {
        _play();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PlayingIndicator oldWidget) {
    _height = widget.height ?? 10;
    super.didUpdateWidget(oldWidget);
    if (oldWidget.play != widget.play) {
      if (widget.play) {
        if (_wasScheduledStopped) {
          _setNewTweens();
        }
        _play();
      } else if (_isPlaying ?? false) {
        _stop();
      }
    }
  }

  Future<void> _play() async {
    _wasScheduledStopped = false;
    _isPlaying = true;
    await Future.doWhile(() async {
      await _halfCycle();
      return _shouldPlay;
    });
  }

  Future<void> _halfCycle() async {
    if (_animationController.value == 0) {
      await _animationController.animateTo(1);
    } else {
      await _animationController.animateBack(0);
    }
    /*logExceptRelease(
      _animationController.value == 1
          ? "Completed a half-cycle"
          : "Completed a full-cycle",
    );*/
    if (_stopScheduled) {
      await _scheduledStop();
    } else {
      _setNewTweens();
    }
  }

  Future<void> _stop() async {
    if (widget.backToStartWhenStopped) {
      _stopScheduled = true;
    } else {
      _animationController.stop();
    }
  }

  Future<void> _scheduledStop() async {
    _resetTweens();
    if (_animationController.value == 0) {
      await _animationController.animateTo(1);
    } else {
      await _animationController.animateBack(0);
    }
    _animationController.stop();
    _wasScheduledStopped = true;
    _shouldPlay = false;
    _stopScheduled = false;
  }

  final Map<int, Tween<double>> _tweens = {};

  void _setNewTweens() {
    /*logExceptRelease(
      "Setting new tweens, animation controller value: ${_animationController.value}, ${_animationController.status}",
    );*/
    for (int i = 0; i < widget.barsCount; ++i) {
      final Tween<double>? value = _tweens[i];

      if (_wasScheduledStopped) {
        final Random random = Random();

        final double randomLowerRange = random.randomDouble(
          min: _stoppedHeight,
          max: _height / 2,
        );

        final double randomUpperRange = random.randomDouble(
          min: randomLowerRange,
          max: _height,
        );

        if (i.isEven && (_animationController.value == 0)) {
          _tweens[i] = Tween<double>(
            begin: randomUpperRange,
            end: randomLowerRange,
          );
        } else {
          _tweens[i] = Tween<double>(
            begin: randomLowerRange,
            end: randomUpperRange,
          );
        }
      } else if (value == null) {
        //! Tween was not present
        /*logExceptRelease(
          "Tween at index: $i is unavailable. Assigning a new tween",
        );*/
        final Random random = Random();

        final double randomLowerRange = random.randomDouble(
          min: _stoppedHeight,
          max: _height / 2,
        );

        final double randomUpperRange = random.randomDouble(
          min: randomLowerRange,
          max: _height,
        );

        if (i.isEven && (_animationController.value == 0)) {
          _tweens[i] = Tween<double>(
            begin: randomUpperRange,
            end: randomLowerRange,
          );
        } else {
          _tweens[i] = Tween<double>(
            begin: randomLowerRange,
            end: randomUpperRange,
          );
        }
        /*logExceptRelease(
          "Assigned Tween at index $i: ${_tweens[i]}",
        );*/
      } else {
        if (_animationController.value == 0) {
          if (value.begin! <= value.end!) {
            // Needs new upper bound (end)
            _tweens[i]!.end = Random().randomDouble(
              min: min(value.begin! * 2, _height),
              max: _height,
            );
          } else {
            // Needs new lower bound (end)
            _tweens[i]!.end = Random().randomDouble(
              min: _stoppedHeight,
              max: value.begin! / 2,
            );
          }
        } else {
          //_animationController.value == 1
          if (value.end! <= value.begin!) {
            // Needs new upper bound (begin)
            _tweens[i]!.begin = Random().randomDouble(
              min: min(value.end! * 2, _height),
              max: _height,
            );
          } else {
            // Needs new lower bound (begin)
            _tweens[i]!.begin = Random().randomDouble(
              min: _stoppedHeight,
              max: value.end! / 2,
            );
          }
        }
      }
      //logExceptRelease("Tween at index $i: ${_tweens[i]}");
    }
  }

  void _resetTweens() {
    for (int i = 0; i < widget.barsCount; ++i) {
      final Tween<double>? value = _tweens[i];
      if (value == null) {
        _tweens[i] = ConstantTween<double>(_stoppedHeight);
      } else {
        if (_animationController.value == 0) {
          if (value.begin! <= value.end!) {
            // Needs new upper bound (end)
            _tweens[i]!.end = _stoppedHeight;
          } else {
            // Needs new lower bound (end)
            _tweens[i]!.end = _stoppedHeight;
          }
        } else {
          //_animationController.value == 1
          if (value.end! <= value.begin!) {
            // Needs new upper bound (begin)
            _tweens[i]!.begin = _stoppedHeight;
          } else {
            // Needs new lower bound (begin)
            _tweens[i]!.begin = _stoppedHeight;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color? color =
        widget.color ?? Theme.of(context).textTheme.bodyMedium?.color;
    final double width = widget.width ?? 3;
    final double gap = widget.gap ?? 3;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (int i = 0; i < widget.barsCount - 1; ++i) ...[
              _Bar(
                color: color,
                width: width,
                height: _tweens[i]!.evaluate(_animationController),
              ),
              SizedBox(
                width: gap,
              ),
            ],
            _Bar(
              color: color,
              width: width,
              height:
                  _tweens[widget.barsCount - 1]!.evaluate(_animationController),
            ),
          ],
        );
      },
    );
  }
}

class _Bar extends StatelessWidget {
  final Color? color;
  final double? width;
  final double? height;

  // ignore: unused_element
  const _Bar({super.key, this.color, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      width: width,
      height: height,
    );
  }
}
