part of widgets;

class LyricsLineView extends StatefulWidget {
  final LyricsLine line;
  final bool isCurrent;
  final int index;
  final bool shouldHighlight;
  final VoidCallback? onTap;
  final double opacity;
  final bool showTranslation;

  const LyricsLineView({
    super.key,
    required this.line,
    required this.isCurrent,
    required this.index,
    required this.shouldHighlight,
    this.onTap,
    required this.opacity,
    required this.showTranslation,
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

  //late final ColorTween _tileColorTween;
  /*Color? _tileColorValue(Animation<double> animation) =>
      _tileColorTween.evaluate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(
            0,
            0.1,
            curve: Curves.easeOutQuint,
          ),
        ),
      );*/

  @override
  void initState() {
    super.initState();
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
    //_tileColorTween = ColorTween(end: Colors.black.withOpacity(0.2));
  }

  @override
  void dispose() {
    _opacityController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LyricsLineView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.opacity != oldWidget.opacity) {
      _opacityController.value = widget.opacity;
    }
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
        builder: (context, animation, child) {
          return Material(
            type: MaterialType.transparency,
            child: ListTile(
              onTap: widget.onTap,
              title: Text(
                widget.line.line,
                textScaleFactor: 1.2, // _textScaleFactorValue(animation),
                textAlign: TextAlign.center,
                style: _textStyleValue(animation),
              ),
              subtitle:
                  widget.showTranslation && (widget.line.translation != null)
                      ? Text(
                          widget.line.translation!,
                          textScaleFactor: 1.1,
                          textAlign: TextAlign.center,
                          style: _translationStyleValue(animation),
                        )
                      : null,
            ),
          );
          /*return ColoredBox(
            color: _tileColorValue(animation) ?? Colors.transparent,
            child: Material(
              type: MaterialType.transparency,
              child: ListTile(
                onTap: widget.onTap,
                title: Text(
                  widget.line.line,
                  textScaleFactor: 1.2, // _textScaleFactorValue(animation),
                  textAlign: TextAlign.center,
                  style: _textStyleValue(animation),
                ),
                subtitle:
                    widget.showTranslation && (widget.line.translation != null)
                        ? Text(
                            widget.line.translation!,
                            textScaleFactor: 1.1,
                            textAlign: TextAlign.center,
                            style: _translationStyleValue(animation),
                          )
                        : null,
                //tileColor: _tileColorValue(animation),
              ),
            ),
          );*/
        },
        state: widget.shouldHighlight && widget.isCurrent,
      ),
    );
  }
}
