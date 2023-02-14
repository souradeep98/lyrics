part of widgets;


class DimOverlay extends StatefulWidget {
  final double dimValue;
  final Duration animateDuration;
  final Curve animationCurve;
  final Color? dimColor;

  const DimOverlay({
    // ignore: unused_element
    super.key,
    required this.dimValue,
    // ignore: unused_element
    this.animateDuration = const Duration(milliseconds: 350),
    // ignore: unused_element
    this.animationCurve = Curves.linear,
    // ignore: unused_element
    this.dimColor,
  });

  @override
  State<DimOverlay> createState() => _DimOverlayState();
}

class _DimOverlayState extends State<DimOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, value: widget.dimValue);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DimOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _animationController.animateTo(
      widget.dimValue,
      duration: widget.animateDuration,
      curve: widget.animationCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color color = widget.dimColor ?? Colors.black;
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ColoredBox(
          color: color.withOpacity(_animationController.value),
          child: child,
        );
      },
      child: const SizedBox.expand(),
    );
  }
}
