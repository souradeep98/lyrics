part of widgets;

class LyricsLineView extends StatefulWidget {
  final LyricsLine line;
  final bool isCurrent;
  final int index;
  final bool shouldHighlight;
  final VoidCallback? onTap;
  final double opacity;
  final bool showTranslation;
  final bool showMusicVisualizerAnimation;
  final bool showBackground;

  const LyricsLineView({
    super.key,
    required this.line,
    required this.isCurrent,
    required this.index,
    required this.shouldHighlight,
    this.onTap,
    required this.opacity,
    required this.showTranslation,
    this.showMusicVisualizerAnimation = false,
    this.showBackground = false,
  });

  @override
  State<LyricsLineView> createState() => _LyricsLineViewState();
}

class _LyricsLineViewState extends State<LyricsLineView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _opacityController;

  late final TextStyle _textStyle;
  late final TextStyleTween _textStyleTween;
  late final TextStyle _translationStyle;
  late final TextStyleTween _translationStyleTween;

  late bool _shouldShowMusicVisualizer;
  late bool _shouldShowTranslation;
  late AnimatedStateWidgetBuilder _builder;

  TextStyle _textStyleValue(Animation<double> animation) =>
      _textStyleTween.evaluate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeIn,
        ),
      );

  TextStyle _translationStyleValue(Animation<double> animation) =>
      _translationStyleTween.evaluate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeIn,
        ),
      );

  /*late final Tween<double> _textScaleFactorTween;
  double _textScaleFactorValue(Animation<double> animation) =>
      _textScaleFactorTween.evaluate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(
            0,
            0.3,
            curve: Curves.easeOutQuint,
          ),
        ),
      );*/

  late final ColorTween _tileColorTween;
  Color? _tileColorValue(Animation<double> animation) =>
      _tileColorTween.evaluate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(
            0,
            0.1,
            curve: Curves.easeOutQuint,
          ),
        ),
      );

  @override
  void initState() {
    super.initState();
    _shouldShowMusicVisualizer =
        widget.showMusicVisualizerAnimation && widget.line.line.isEmpty;

    _shouldShowTranslation =
        widget.showTranslation && (widget.line.translation != null);

    _opacityController = AnimationController(
      vsync: this,
      value: widget.opacity,
    );
    _textStyle = GoogleFonts.nunito(
      color: Colors.white54,
    );
    _textStyleTween = TextStyleTween(
      begin: _textStyle,
      end: _textStyle.copyWith(
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
    _translationStyle = GoogleFonts.nunito(
      color: Colors.white30,
    );
    _translationStyleTween = TextStyleTween(
      begin: _translationStyle,
      end: _translationStyle.copyWith(
        fontWeight: FontWeight.w500,
        color: Colors.white54,
      ),
    );
    //_textScaleFactorTween = Tween<double>(begin: 1.2, end: 1.25);
    _tileColorTween = ColorTween(end: Colors.black.withOpacity(0.2));

    _builder = widget.showBackground ? _backgroundBuilder : _mainBuilder;
  }

  @override
  void dispose() {
    _opacityController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LyricsLineView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.showMusicVisualizerAnimation !=
            oldWidget.showMusicVisualizerAnimation) ||
        (widget.line.line != oldWidget.line.line)) {
      _shouldShowMusicVisualizer =
          widget.showMusicVisualizerAnimation && widget.line.line.isEmpty;
    }

    if ((widget.showTranslation != oldWidget.showTranslation) ||
        (widget.line.translation != oldWidget.line.translation)) {
      _shouldShowTranslation =
          widget.showTranslation && (widget.line.translation != null);
    }

    if (widget.opacity != oldWidget.opacity) {
      _opacityController.value = widget.opacity;
    }

    if (widget.showBackground != oldWidget.showBackground) {
      _builder = widget.showBackground ? _backgroundBuilder : _mainBuilder;
    }
  }

  Widget _mainBuilder(
    BuildContext context,
    Animation<double> animation,
    Widget? child,
  ) {
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        onTap: widget.onTap,
        title: _shouldShowMusicVisualizer
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PlayingIndicator(
                    play: widget.isCurrent,
                  ),
                ],
              )
            : Text(
                widget.line.line,
                textScaleFactor: 1.2, // _textScaleFactorValue(animation),
                textAlign: TextAlign.center,
                style: _textStyleValue(animation),
              ),
        subtitle: _shouldShowTranslation
            ? Text(
                widget.line.translation!,
                textScaleFactor: 1.1,
                textAlign: TextAlign.center,
                style: _translationStyleValue(animation),
              )
            : null,
        //tileColor: _tileColorValue(animation),
      ),
    );
  }

  Widget _backgroundBuilder(
    BuildContext context,
    Animation<double> animation,
    Widget? child,
  ) {
    return ColoredBox(
      color: _tileColorValue(animation) ?? Colors.transparent,
      child: _mainBuilder(context, animation, child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityController,
      child: AnimatedStateBuilder(
        duration: const Duration(milliseconds: 350),
        reverseDuration: const Duration(milliseconds: 50),
        forwardCurve: Curves.easeOut,
        reverseCurve: Curves.easeOut,
        builder: _builder,
        state: widget.shouldHighlight && widget.isCurrent,
      ),
    );
  }
}
