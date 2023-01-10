part of widgets;

class NavigationBarAnimated extends StatefulWidget {
  final List<NavigationBarAnimatedItem> items;
  final void Function(int) onSelected;
  final double height;
  final int currentSelection;
  final Color? backgroundColor;
  final Duration? animationDuration;
  final Curve animationCurve;

  const NavigationBarAnimated({
    super.key,
    required this.items,
    required this.onSelected,
    this.height = 55,
    required this.currentSelection,
    this.backgroundColor,
    this.animationDuration,
    this.animationCurve = Curves.ease,
  });

  @override
  State<NavigationBarAnimated> createState() => _NavigationBarAnimatedState();
}

class _NavigationBarAnimatedState extends State<NavigationBarAnimated>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  //final Map<double, double> _cachedValues = {};
  /*late final Animation<RelativeRect> _relativeRectAnimation;
  final RelativeRectTween _relativeRectTween = RelativeRectTween(
    begin: RelativeRect.,
    end: ,
  );*/
  List<Widget>? _children;
  BoxConstraints? _oldConstraints;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      value: _currentIndexFactor,
    );
    //_relativeRectAnimation =
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(NavigationBarAnimated oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.items, oldWidget.items)) {
      _children = null;
    }

    if (widget.currentSelection != oldWidget.currentSelection) {
      _transitIndicatorToCurrentIndex();
    }
  }

  void _transitIndicatorToCurrentIndex() {
    _animationController.animateTo(
      _currentIndexFactor,
      duration: widget.animationDuration ?? const Duration(milliseconds: 350),
      curve: widget.animationCurve,
    );
  }

  /// Projects the value from 0 - 1 to 0 - 2 and then -2 from it
  /*double _getAlignmentForIndex(double index) {
    if (_cachedAlignments.containsKey(index)) {
      return _cachedAlignments[index]!;
    }

    final double factor = _getPositionFactorOfIndex(index);

    final double result =
        _cachedAlignments[index] = _getAlignmentForFactor(factor);

    logExceptRelease("Alignment for $index: $result");
    return result;
  }*/

  /// Returns percentage factor for alignment in the scale of [0 - 1] from indices (eg. 0, 1, 2, 3...)
  double _getPositionFactorOfIndex(double index) {
    final double result = (1 / (widget.items.length + 1)) * (index + 1);
    //logExceptRelease("PositionFactor for $index: $result");
    return result;
  }

  /*double _getAlignmentForFactor(double factor) {
    // To obtain the alignment, the factor should be scaled in 0 - 2 range
    final double scaledFactor = project(
      oldMin: 0,
      oldMax: 1,
      newMin: 0,
      newMax: 2,
      value: factor,
    );

    // And then subtract 1 from it
    final double result = scaledFactor - 1;

    return result;
  }*/

  /*double get _indicatorAlignment {
    final double currentValue = _animationController.value;
    return _getAlignmentForFactor(currentValue);
  }*/

  double _getindicatorOffset(double width) {
    final double factor = _animationController.value;
    final double dx = width * factor;
    return dx;
  }

  double get _currentIndexFactor {
    return _getPositionFactorOfIndex(widget.currentSelection.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Theme.of(context).canvasColor;
    const Widget indicator = _Indicator(
      backgroundColor: Colors.white,
    );
    final double itemBaseAlignment = widget.height / 2;
    final double radius = itemBaseAlignment;
    final double size = radius * 0.6;
    final double indicatorHeight = widget.height;
    final double indicatorBaseAlignment = widget.height - (indicatorHeight / 2);

    return SizedBox(
      height: widget.height,
      child: ColoredBox(
        color: widget.backgroundColor ?? backgroundColor,
        child: Material(
          type: MaterialType.transparency,
          child: LayoutBuilder(
            builder: (context, constraints) {
              //final double dx = constraints.maxWidth * _getAlignmentFor(1);
              if (_oldConstraints != constraints) {
                _children = null;
              }

              _oldConstraints = constraints;

              _children ??= [
                ...widget.items.asMap().entries.map<Widget>(
                  (e) {
                    final double factor =
                        _getPositionFactorOfIndex(e.key.toDouble());
                    final double dx = constraints.maxWidth * factor;
                    return Positioned.fromRect(
                      rect: Rect.fromCenter(
                        center: Offset(dx, itemBaseAlignment),
                        width: 80,
                        height: 50,
                      ),
                      child: InkWell(
                        onTap: () {
                          widget.onSelected(e.key);
                        },
                        //splashRadius: radius,
                        radius: size,
                        child: _NavigationBarAnimatedItemView(
                          item: e.value,
                          isSelected: widget.currentSelection == e.key,
                        ),
                        //iconSize: size,
                      ),
                    );
                  },
                ),
              ];

              /*final List<Widget> additionalChildren = [
                /*for (double i = -1; i <= 1; i += 0.1)
                  Align(
                    alignment: Alignment(
                      i,
                      1,
                    ),
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Text(
                        "${i.toStringAsFixed(1)} -",
                        textScaleFactor: 0.5,
                      ),
                    ),
                  ),
                for (final MapEntry<double, double> x
                    in _cachedAlignments.entries)
                  Align(
                    alignment: Alignment(
                      x.value,
                      1,
                    ),
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Text(
                        "${x.value.toStringAsFixed(2)} -",
                        textScaleFactor: 0.5,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                */
                /*Positioned.fromRect(
                  rect: Rect.fromCenter(
                    center: Offset(dx, 0),
                    width: 1,
                    height: 1,
                  ),
                  child: const Icon(
                    Icons.circle,
                    size: 1,
                    color: Colors.red,
                  ),
                ),*/

                /*Positioned(child: child),
                Positioned.fromRelativeRect(rect: RelativeRect, child: const Text("Positioned.fromRelativeRect"),),*/
              ];*/

              return AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  final List<Widget> childrenWithIndicator = [
                    Positioned.fromRect(
                      rect: Rect.fromCenter(
                        center: Offset(
                          _getindicatorOffset(constraints.maxWidth),
                          indicatorBaseAlignment,
                        ),
                        width: indicatorHeight,
                        height: indicatorHeight,
                      ),
                      child: indicator,
                    ),
                    if (_children != null) ..._children!,
                    //...additionalChildren,
                  ];

                  return Stack(
                    clipBehavior: Clip.none,
                    fit: StackFit.expand,
                    children: childrenWithIndicator,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final Color? color;
  final Color backgroundColor;

  const _Indicator({
    // ignore: unused_element
    super.key,
    // ignore: unused_element
    this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = color ?? Theme.of(context).primaryColorDark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double radius = constraints.maxHeight;
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Transform.scale(
              scaleY: 0.5,
              scaleX: 1.1,
              alignment: Alignment.bottomCenter,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      /*for (int i = 0; i < 2; ++i)
                        backgroundColor.withOpacity(0),
                      for (double i = 0.0; i <= 0.5; i += 0.2)
                        effectiveColor.withOpacity(i),*/
                      for (double i = 0.4; i >= 0; i -= 0.1)
                        effectiveColor.withOpacity(i),
                      for (int i = 0; i < 2; ++i)
                        backgroundColor.withOpacity(0),
                    ],
                    /*stops: const [
                      0.5,
                      0.8,
                    ],*/
                    center: const Alignment(0, 0.5),
                    focal: const Alignment(0, 0.8),
                    radius: 0.6,
                  ),
                ),
                child: SizedBox(
                  height: radius,
                  width: radius,
                ),
              ),
            ),
            PhysicalShape(
              clipper: const ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),
              color: effectiveColor,
              child: const SizedBox(
                height: 5,
                width: 30,
              ),
            ),
          ],
        );
      },
    );
  }
}

class NavigationBarAnimatedItem {
  final Widget Function(BuildContext context, bool isSelected) itemBuilder;
  final String label;
  final Color? selectedColor;

  const NavigationBarAnimatedItem({
    required this.itemBuilder,
    required this.label,
    required this.selectedColor,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NavigationBarAnimatedItem &&
        other.itemBuilder == itemBuilder &&
        other.label == label &&
        other.selectedColor == selectedColor;
  }

  @override
  int get hashCode =>
      itemBuilder.hashCode ^ label.hashCode ^ selectedColor.hashCode;
}

class _NavigationBarAnimatedItemView extends StatefulWidget {
  final NavigationBarAnimatedItem item;
  final bool isSelected;

  const _NavigationBarAnimatedItemView({
    // ignore: unused_element
    super.key,
    required this.item,
    required this.isSelected,
  });

  @override
  State<_NavigationBarAnimatedItemView> createState() =>
      _NavigationBarAnimatedItemViewState();
}

class _NavigationBarAnimatedItemViewState
    extends State<_NavigationBarAnimatedItemView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 3,
            child: widget.item.itemBuilder(context, widget.isSelected),
          ),
          Expanded(
            flex: 2,
            child: Text(
              widget.item.label,
              textScaleFactor: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

/*
class Outline extends StatelessWidget {
  final String text;
  final Widget child;
  final Color? color;

  const Outline({
    // ignore: unused_element
    super.key,
    required this.child,
    required this.text, this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: color ?? Colors.red,
          width: 2,
        ),
      ),
      child: IntrinsicWidth(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                text,
                textScaleFactor: 0.6,
              ),
            ),
            const VerticalDivider(
              width: 3,
              color: Colors.red,
            ),
            child,
          ],
        ),
      ),
    );
  }
}*/
