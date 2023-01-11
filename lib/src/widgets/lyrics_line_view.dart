part of widgets;

class LyricsLineView extends StatefulWidget {
  final String text;
  final bool isCurrent;
  final int index;
  final bool shouldHighlight;
  final VoidCallback? onTap;
  final double opacity;

  const LyricsLineView({
    super.key,
    required this.text,
    required this.isCurrent,
    required this.index,
    required this.shouldHighlight,
    this.onTap,
    required this.opacity,
  });

  @override
  State<LyricsLineView> createState() => _LyricsLineViewState();
}

class _LyricsLineViewState extends State<LyricsLineView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _opacityController;

  late final TextStyle _textStyle;
  late final TextStyleTween _textStyleTween;
  TextStyle _textStyleValue(Animation<double> animation) =>
      _textStyleTween.evaluate(
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
    //_textScaleFactorTween = Tween<double>(begin: 1.2, end: 1.25);
    _tileColorTween = ColorTween(end: Colors.black.withOpacity(0.2));
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
        reverseDuration: const Duration(milliseconds: 150),
        forwardCurve: Curves.easeIn,
        reverseCurve: Curves.easeIn,
        builder: (context, animation, child) {
          return ColoredBox(
            color: _tileColorValue(animation) ?? Colors.transparent,
            child: Material(
              type: MaterialType.transparency,
              child: ListTile(
                onTap: widget.onTap,
                title: Text(
                  widget.text,
                  textScaleFactor: 1.2, // _textScaleFactorValue(animation),
                  textAlign: TextAlign.center,
                  style: _textStyleValue(animation),
                ),
                //tileColor: _tileColorValue(animation),
              ),
            ),
          );
        },
        state: widget.shouldHighlight && widget.isCurrent,
      ),
    );
  }
}
