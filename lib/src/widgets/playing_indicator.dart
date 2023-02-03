part of widgets;

class PlayingIndicator extends StatefulWidget {
  final int barsCount;
  final Color? color;
  final bool play;
  final double? width;
  final double? height;
  final double? gap;

  const PlayingIndicator({
    super.key,
    this.color,
    this.barsCount = 3,
    this.play = true,
    this.width,
    this.gap,
    this.height,
  });

  @override
  State<PlayingIndicator> createState() => _PlayingIndicatorState();
}

class _PlayingIndicatorState extends State<PlayingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late double _height;

  @override
  void initState() {
    super.initState();
    _height = widget.height ?? 10;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _setNewTweens();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.play) {
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
    _setNewTweens();
    super.didUpdateWidget(oldWidget);
    if (oldWidget.play != widget.play) {
      if (widget.play) {
        _play();
      } else {
        _stop();
      }
    }
  }

  Future<void> _play() async {
    await Future.doWhile(() async {
      await _cycle();
      return widget.play && mounted;
    });
  }

  Future<void> _cycle() async {
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
    _setNewTweens();
  }

  void _stop() {
    _animationController.stop();
  }

  final Map<int, Tween<double>> _tweens = {};

  void _setNewTweens() {
    /*logExceptRelease(
      "Setting new tweens, animation controller value: ${_animationController.value}, ${_animationController.status}",
    );*/
    for (int i = 0; i < widget.barsCount; ++i) {
      //Tween<double>? result = _tweens[i];
      if (_tweens[i] == null) {
        //! Tween was not present
        /*logExceptRelease(
          "Tween at index: $i is unavailable. Assigning a new tween",
        );*/
        final Random random = Random();
        final double randomUpperRange = random.randomDouble(min: 0, max: _height);
        final double randomLowerRange = random.randomDouble(
          min: 0,
          max: randomUpperRange / 2,
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
          if (_tweens[i]!.begin! <= _tweens[i]!.end!) {
            // Needs new upper bound (end)
            _tweens[i]!.end = Random()
                .randomDouble(min: min(_tweens[i]!.begin! * 2, _height), max: _height);
          } else {
            // Needs new lower bound (end)
            _tweens[i]!.end =
                Random().randomDouble(min: 0, max: _tweens[i]!.begin! / 2);
          }
        } else {
          //_animationController.value == 1
          if (_tweens[i]!.end! <= _tweens[i]!.begin!) {
            // Needs new upper bound (begin)
            _tweens[i]!.begin = Random()
                .randomDouble(min: min(_tweens[i]!.end! * 2, _height), max: _height);
          } else {
            // Needs new lower bound (begin)
            _tweens[i]!.begin =
                Random().randomDouble(min: 0, max: _tweens[i]!.end! / 2);
          }
        }
      }
      //logExceptRelease("Tween at index $i: ${_tweens[i]}");
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
