part of widgets;

class PlayingIndicator extends StatefulWidget {
  final int barsCount;
  final Color? color;
  final bool play;
  final double barWidth;
  final double height;
  final double gapBetweenBars;
  final double stoppedBarHeight;
  final PlayingIndicatorStopBehavior stopBehavior;
  final Duration halfCycleDuration;

  const PlayingIndicator({
    super.key,
    this.barsCount = 3,
    this.color,
    this.play = true,
    this.barWidth = 3,
    this.height = 10,
    this.gapBetweenBars = 3,
    this.stoppedBarHeight = 1,
    this.stopBehavior = PlayingIndicatorStopBehavior.pauseState,
    this.halfCycleDuration = const Duration(milliseconds: 300),
  }) : assert(stoppedBarHeight < height);

  @override
  State<PlayingIndicator> createState() => _PlayingIndicatorState();
}

class _PlayingIndicatorState extends State<PlayingIndicator>
    with
        SingleTickerProviderStateMixin<PlayingIndicator>,
        LogHelperMixin,
        _PlayerIndicatorControlMixin {
  @override
  Widget build(BuildContext context) {
    final Color? color =
        widget.color ?? Theme.of(context).textTheme.bodyMedium?.color;
    final double width = widget.barWidth;
    final double gap = widget.gapBetweenBars;
    final int loopFor = widget.barsCount - 1;
    double? stoppedHeight;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (int i = 0; i < loopFor; ++i) ...[
              _Bar(
                color: color,
                width: width,
                height: _tweens[i]?.evaluate(_animationController) ??
                    (stoppedHeight ??= widget.stoppedBarHeight),
              ),
              SizedBox(
                width: gap,
              ),
            ],
            _Bar(
              color: color,
              width: width,
              height: _tweens[widget.barsCount - 1]
                      ?.evaluate(_animationController) ??
                  (stoppedHeight ??= widget.stoppedBarHeight),
            ),
          ],
        );
      },
    );
  }
}

mixin _PlayerIndicatorControlMixin
    on
        State<PlayingIndicator>,
        SingleTickerProviderStateMixin<PlayingIndicator>,
        LogHelperMixin {
  late final AnimationController _animationController;
  final Map<int, Tween<double>> _tweens = {};
  _PlayingIndicatorInternalState? _currentState;
  final Random _random = Random();
  VoidCallback? _postHalfCycleCallback;
  late double _mid;

  /*@override
  bool shouldLog = false;*/

  @override
  void initState() {
    super.initState();
    logER("initState()");
    _animationController = AnimationController(
      vsync: this,
      duration: widget.halfCycleDuration,
    );

    final bool play = widget.play;

    _mid = (widget.height - widget.stoppedBarHeight) / 2;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (play) {
          _play();
        } else {
          _stop();
        }
      },
    );
  }

  @override
  void didUpdateWidget(PlayingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    logER("didUpdateWidget()");
    if (widget.halfCycleDuration != oldWidget.halfCycleDuration) {
      _animationController.duration = widget.halfCycleDuration;
    }

    if ((widget.stoppedBarHeight != oldWidget.stoppedBarHeight) ||
        (widget.height != oldWidget.height)) {
      _mid = (widget.height - widget.stoppedBarHeight) / 2;
    }

    if (widget.play) {
      _play();
    } else {
      _stop(
        stoppedHeightChanged:
            oldWidget.stoppedBarHeight != widget.stoppedBarHeight,
      );
    }
  }

  @override
  void dispose() {
    logER("dispose()");
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    if (_currentState == _PlayingIndicatorInternalState.playing) {
      logER("Already playing");
      return;
    }
    _PlayingIndicatorInternalState? oldState = _currentState;

    _PlayingIndicatorInternalState? getOldState() {
      if (oldState == null) {
        return null;
      }
      final _PlayingIndicatorInternalState result = oldState!;
      oldState = null;
      return result;
    }

    _currentState = _PlayingIndicatorInternalState.playing;

    logER("Playing");

    await Future.doWhile(
      () async {
        _setNewTweens(argument: getOldState());
        await _serveHalfCycle();
        return _currentState == _PlayingIndicatorInternalState.playing;
      },
    );
    logER("Play cycle stopping...");
  }

  void _stop({bool? stoppedHeightChanged}) {
    switch (widget.stopBehavior) {
      case PlayingIndicatorStopBehavior.pauseState:
        _handleStopBehaviorPauseState();
        break;
      case PlayingIndicatorStopBehavior.jumpBackToStart:
        _handleStopBehaviorJumpBackToStart(stoppedHeightChanged ?? false);
        break;
      case PlayingIndicatorStopBehavior.goBackToStart:
        _handleStopBehaviorGoBackToStart(stoppedHeightChanged ?? false);
        break;
    }
  }

  Future<void> _serveHalfCycle() async {
    logER("Serving halfCycle, currentStatus: ${_animationController.status}");
    await _animationController.halfCycle();
    logER("HalfCycle complete, status: ${_animationController.status}");
    if (_postHalfCycleCallback != null) {
      logER("Calling post-halfCycle");
      _postHalfCycleCallback!.call();
      _postHalfCycleCallback = null;
    }
  }

  void _handleStopBehaviorPauseState() {
    if (_currentState == _PlayingIndicatorInternalState.pauseState) {
      return;
    }
    _currentState = _PlayingIndicatorInternalState.pauseState;

    logER("Handling StopBehavior: PauseState...");
    _animationController.stop();
    logER("Handled StopBehavior: PauseState.");
  }

  void _handleStopBehaviorJumpBackToStart(bool stoppedHeightChanged) {
    if (_currentState == _PlayingIndicatorInternalState.jumpBackToStart) {
      if (stoppedHeightChanged) {
        _setNewTweens();
      }
      return;
    }

    _currentState = _PlayingIndicatorInternalState.jumpBackToStart;

    logER("Handling StopBehavior: JumpBackToStart...");
    _setNewTweens();
    _animationController.reset();
    logER("Handled StopBehavior: JumpBackToStart.");
  }

  Future<void> _handleStopBehaviorGoBackToStart(
    bool stoppedHeightChanged,
  ) async {
    if (_currentState == _PlayingIndicatorInternalState.goBackToStart) {
      if (stoppedHeightChanged) {
        _setNewTweens();
      }
      return;
    }
    _currentState = _PlayingIndicatorInternalState.goBackToStart;

    logER("Handling StopBehavior: GoBackToStart...");
    _postHalfCycleCallback = () async {
      _animationController.stop();
      _setNewTweens(argument: true);
      await _animationController.halfCycle();
      _animationController.stop();
      _setNewTweens();
      logER("Handled StopBehavior: GoBackToStart.");
    };
  }

  void _setNewTweens({Object? argument}) {
    switch (_currentState) {
      case _PlayingIndicatorInternalState.playing:
        _setNewTweensForPlaying(argument as _PlayingIndicatorInternalState?);
        break;

      case _PlayingIndicatorInternalState.jumpBackToStart:
        _setNewTweensForJumpBackToStart();
        break;

      case _PlayingIndicatorInternalState.goBackToStart:
        _setNewTweensForGoBackToStart(argument as bool?);
        break;

      default:
    }

    bool? toRight;
    bool getDirection() {
      switch (_animationController.status) {
        case AnimationStatus.dismissed:
        case AnimationStatus.forward:
          return true;
        case AnimationStatus.reverse:
        case AnimationStatus.completed:
          return false;
      }
    }

    if (_currentState != _PlayingIndicatorInternalState.pauseState) {
      logER(
        "New tweens: ${_tweens.entries.map<String>((e) {
          if (toRight ??= getDirection()) {
            return "[${e.key}]: ${e.value.begin} -> ${e.value.end}";
          } else {
            return "[${e.key}]: ${e.value.end} -> ${e.value.begin}";
          }
        }).toList()}",
      );
    }
  }

  void _setNewTweensForPlaying(_PlayingIndicatorInternalState? oldState) {
    logER("Setting twins for Playing...");

    if (const [
      _PlayingIndicatorInternalState.jumpBackToStart,
      _PlayingIndicatorInternalState.goBackToStart,
    ].contains(oldState)) {
      return;
    }

    for (int i = 0; i < widget.barsCount; ++i) {
      final Tween<double>? oldTween = _tweens[i];
      if (oldTween != null) {
        // Old candidate
        switch (_animationController.status) {
          case AnimationStatus.dismissed:
            // Needs new bound at end
            switch (_getHeightAnimationProfile(i)) {
              case _BarHeightAnimationProfile.lowToHigh:
                // Needs new upper bound at end
                _tweens[i]!.end = _getUpperBound();
                break;
              case _BarHeightAnimationProfile.highToLow:
                // Needs new lower bound at end

                _tweens[i]!.end = _getLowerBound();
                break;
              default:
            }
            break;

          case AnimationStatus.completed:
            switch (_getHeightAnimationProfile(i)) {
              case _BarHeightAnimationProfile.lowToHigh:
                // Needs new upper bound at beginning
                _tweens[i]!.begin = _getUpperBound();
                break;
              case _BarHeightAnimationProfile.highToLow:
                // Needs new lower bound at beginning
                _tweens[i]!.begin = _getLowerBound();
                break;
              default:
            }
            break;

          default:
        }
      } else {
        // New candidate
        switch (_getHeightAnimationProfile(i)) {
          case _BarHeightAnimationProfile.lowToHigh:
            _tweens[i] = Tween<double>(
              begin: _getLowerBound(),
              end: _getUpperBound(),
            );
            break;
          case _BarHeightAnimationProfile.highToLow:
            _tweens[i] = Tween<double>(
              begin: _getUpperBound(),
              end: _getLowerBound(),
            );
            break;
          default:
        }
      }
    }
    logER("Setting twins for Playing is successful.");
  }

  void _setNewTweensForJumpBackToStart() {
    logER("Setting twins for StopBehavior: JumpBackToStart...");
    final double stoppedBarHeight = widget.stoppedBarHeight;

    for (int i = 0; i < widget.barsCount; ++i) {
      final Tween<double>? oldTween = _tweens[i];

      if (oldTween != null) {
        // Old candidate
        switch (_animationController.status) {
          /*case AnimationStatus.forward:
          case AnimationStatus.dismissed:
            _tweens[i]!.end = oldTween.end;
            break;*/
          case AnimationStatus.reverse:
          case AnimationStatus.completed:
            _tweens[i]!.end = oldTween.begin;
            break;
          default:
        }
        _tweens[i]!.begin = stoppedBarHeight;
      } else {
        // New candidate
        switch (_getHeightAnimationProfile(i)) {
          case _BarHeightAnimationProfile.lowToHigh:
            _tweens[i] = Tween<double>(
              begin: stoppedBarHeight,
              end: _getUpperBound(),
            );
            break;
          case _BarHeightAnimationProfile.highToLow:
            _tweens[i] = Tween<double>(
              begin: stoppedBarHeight,
              end: _getLowerBound(),
            );
            break;
          default:
        }
      }
      //_tweens[i] = ConstantTween<double>(stoppedBarHeight);
    }
    logER("Setting twins for StopBehavior: JumpBackToStart is successful.");
  }

  void _setNewTweensForGoBackToStart(bool? reset) {
    final bool shouldReset = reset ?? false;
    logER(
      "Setting twins for StopBehavior: GoBackToStart - reset: $shouldReset...",
    );
    final double stoppedBarHeight = widget.stoppedBarHeight;

    if (shouldReset) {
      for (int i = 0; i < widget.barsCount; ++i) {
        final Tween<double>? oldTween = _tweens[i];
        if (oldTween != null) {
          // Old candidate
          switch (_animationController.status) {
            case AnimationStatus.forward:
            case AnimationStatus.dismissed:
              _tweens[i]!.end = stoppedBarHeight;
              break;
            case AnimationStatus.reverse:
            case AnimationStatus.completed:
              _tweens[i]!.begin = stoppedBarHeight;
              break;
          }
        } else {
          // New candidate
          switch (_getHeightAnimationProfile(i)) {
            case _BarHeightAnimationProfile.lowToHigh:
              switch (_animationController.status) {
                case AnimationStatus.forward:
                case AnimationStatus.dismissed:
                  _tweens[i] = Tween<double>(
                    begin: _getLowerBound(),
                    end: stoppedBarHeight,
                  );
                  break;
                case AnimationStatus.reverse:
                case AnimationStatus.completed:
                  _tweens[i]!.begin = stoppedBarHeight;
                  _tweens[i] = Tween<double>(
                    begin: stoppedBarHeight,
                    end: _getLowerBound(),
                  );
                  break;
              }
              break;
            case _BarHeightAnimationProfile.highToLow:
              switch (_animationController.status) {
                case AnimationStatus.forward:
                case AnimationStatus.dismissed:
                  _tweens[i] = Tween<double>(
                    begin: _getUpperBound(),
                    end: stoppedBarHeight,
                  );
                  break;
                case AnimationStatus.reverse:
                case AnimationStatus.completed:
                  _tweens[i]!.begin = stoppedBarHeight;
                  _tweens[i] = Tween<double>(
                    begin: stoppedBarHeight,
                    end: _getUpperBound(),
                  );
                  break;
              }
              break;
          }
        }
      }
    } else {
      for (int i = 0; i < widget.barsCount; ++i) {
        final Tween<double>? oldTween = _tweens[i];

        if (oldTween != null) {
          switch (_animationController.status) {
            case AnimationStatus.forward:
            case AnimationStatus.dismissed:
              switch (_getHeightAnimationProfile(i)) {
                case _BarHeightAnimationProfile.lowToHigh:
                  _tweens[i]!.end = _getUpperBound();
                  break;
                case _BarHeightAnimationProfile.highToLow:
                  _tweens[i]!.end = _getLowerBound();
                  break;
              }
              break;
            case AnimationStatus.reverse:
            case AnimationStatus.completed:
              switch (_getHeightAnimationProfile(i)) {
                case _BarHeightAnimationProfile.lowToHigh:
                  _tweens[i]!.begin = _getUpperBound();
                  break;
                case _BarHeightAnimationProfile.highToLow:
                  _tweens[i]!.begin = _getLowerBound();
                  break;
              }
          }
        } else {
          switch (_animationController.status) {
            case AnimationStatus.forward:
            case AnimationStatus.dismissed:
              switch (_getHeightAnimationProfile(i)) {
                case _BarHeightAnimationProfile.lowToHigh:
                  _tweens[i] = Tween<double>(
                    begin: stoppedBarHeight,
                    end: _getUpperBound(),
                  );
                  break;
                case _BarHeightAnimationProfile.highToLow:
                  _tweens[i] = Tween<double>(
                    begin: stoppedBarHeight,
                    end: _getLowerBound(),
                  );
                  break;
              }
              break;
            case AnimationStatus.reverse:
            case AnimationStatus.completed:
              switch (_getHeightAnimationProfile(i)) {
                case _BarHeightAnimationProfile.lowToHigh:
                  _tweens[i] = Tween<double>(
                    begin: _getUpperBound(),
                    end: stoppedBarHeight,
                  );
                  break;
                case _BarHeightAnimationProfile.highToLow:
                  _tweens[i] = Tween<double>(
                    begin: _getLowerBound(),
                    end: stoppedBarHeight,
                  );
                  break;
              }
          }
        }
      }
    }

    logER(
      "Setting twins for StopBehavior: GoBackToStart - reset: $shouldReset is successful.",
    );
  }

  _BarHeightAnimationProfile _getHeightAnimationProfile(int index) {
    switch (_animationController.status) {
      case AnimationStatus.dismissed:
      case AnimationStatus.reverse:
        return _BarHeightAnimationProfile.fromBool(index.isEven);

      case AnimationStatus.completed:
      case AnimationStatus.forward:
        return _BarHeightAnimationProfile.fromBool(index.isOdd);
    }
  }

  double _getUpperBound() {
    return _random.randomDouble(min: _mid, max: widget.height);
  }

  double _getLowerBound() {
    return _random.randomDouble(min: widget.stoppedBarHeight, max: _mid);
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

enum PlayingIndicatorStopBehavior {
  pauseState,
  goBackToStart,
  jumpBackToStart;
}

enum _BarHeightAnimationProfile {
  lowToHigh,
  highToLow;

  // ignore: avoid_positional_boolean_parameters
  static _BarHeightAnimationProfile fromBool(bool x) {
    return x ? highToLow : lowToHigh;
  }
}

enum _PlayingIndicatorInternalState {
  playing,
  pauseState,
  goBackToStart,
  jumpBackToStart;

  /*static _PlayingIndicatorInternalState fromStopBehavior(
    PlayingIndicatorStopBehavior? behavior,
  ) {
    switch (behavior) {
      case PlayingIndicatorStopBehavior.pauseState:
        return pauseState;
      case PlayingIndicatorStopBehavior.goBackToStart:
        return goBackToStart;
      case PlayingIndicatorStopBehavior.jumpBackToStart:
        return jumpBackToStart;
      case null:
        return playing;
    }
  }*/

  PlayingIndicatorStopBehavior? toInternalState() {
    switch (this) {
      case playing:
        return null;
      case pauseState:
        return PlayingIndicatorStopBehavior.pauseState;
      case goBackToStart:
        return PlayingIndicatorStopBehavior.goBackToStart;
      case jumpBackToStart:
        return PlayingIndicatorStopBehavior.jumpBackToStart;
    }
  }
}

extension on AnimationController {
  /*void jumpHalfCycle() {
    switch (status) {
      case AnimationStatus.dismissed:
      case AnimationStatus.forward:
        value = 1;
        break;
      case AnimationStatus.completed:
      case AnimationStatus.reverse:
        value = 0;
    }
  }*/

  /*bool get isHalfCycleCompleted => const [
        AnimationStatus.completed,
        AnimationStatus.dismissed,
      ].contains(status);*/

  TickerFuture halfCycle() {
    switch (status) {
      case AnimationStatus.reverse:
      case AnimationStatus.dismissed:
        return forward();
      case AnimationStatus.forward:
      case AnimationStatus.completed:
        return reverse();
    }
  }
}
