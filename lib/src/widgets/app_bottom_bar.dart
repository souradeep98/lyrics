part of '../widgets.dart';
/*
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
  TweenSequence<Color?>? _colorSequence;
  TweenSequence<double>? _bloomSequence;
  TweenSequence<double>? _opacitySequence;
  Animation<double>? _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      value: _currentIndexFactor,
    );
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
      _resetCaches();
    }

    _transitIndicatorToCurrentIndex();
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

  double _getIndicatorDXOffset(double width) {
    final double factor = _animationController.value;
    final double dx = width * factor;
    return dx;
  }

  double get _currentIndexFactor {
    return _getPositionFactorOfIndex(widget.currentSelection.toDouble());
  }

  /*double _getDxFromFactor(double width, double factor) {
    return width * factor;
  }*/

  List<Widget> _getChildren({
    required double maxWidth,
    required double itemBaseAlignment,
    required double inkwellSize,
    required Color primaryColor,
    required double minBloom,
    required double maxBloom,
    required double minOpacity,
    required double maxOpacity,
  }) {
    logExceptRelease("Caching");
    if (widget.items.isEmpty) {
      return const [];
    }

    final double weight = 1 / (widget.items.length + 1);
    final double weightByTwo = weight / 2;

    //! Determine color sequences
    final List<TweenSequenceItem<Color?>> colorSequence = [];

    colorSequence.add(
      TweenSequenceItem<Color?>(
        tween: ColorTween(
          begin: widget.items.first.selectedColor ?? primaryColor,
          end: widget.items.first.selectedColor ?? primaryColor,
        ),
        weight: weight,
      ),
    );

    for (int i = 0; i < widget.items.length - 1; ++i) {
      colorSequence.add(
        TweenSequenceItem<Color?>(
          tween: ColorTween(
            begin: widget.items[i].selectedColor ?? primaryColor,
            end: widget.items[i + 1].selectedColor ?? primaryColor,
          ),
          weight: weight,
        ),
      );
    }

    colorSequence.add(
      TweenSequenceItem<Color?>(
        tween: ColorTween(
          begin: widget.items.last.selectedColor ?? primaryColor,
          end: widget.items.last.selectedColor ?? primaryColor,
        ),
        weight: weight,
      ),
    );

    //! Determine bloom & opacity sequences
    final List<TweenSequenceItem<double>> bloomSequence = [];
    final List<TweenSequenceItem<double>> opacitySequence = [];

    bloomSequence.addAll([
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: minBloom,
          end: maxBloom,
        ),
        weight: weight,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: maxBloom,
          end: minBloom,
        ),
        weight: weightByTwo,
      ),
    ]);
    opacitySequence.addAll([
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: minOpacity,
          end: maxOpacity,
        ),
        weight: weight,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: maxOpacity,
          end: minOpacity,
        ),
        weight: weightByTwo,
      ),
    ]);

    for (int i = 0; i < widget.items.length - 2; ++i) {
      bloomSequence.addAll([
        TweenSequenceItem<double>(
          tween: Tween<double>(
            begin: minBloom,
            end: maxBloom,
          ),
          weight: weightByTwo,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(
            begin: maxBloom,
            end: minBloom,
          ),
          weight: weightByTwo,
        ),
      ]);
      opacitySequence.addAll([
        TweenSequenceItem<double>(
          tween: Tween<double>(
            begin: minOpacity,
            end: maxOpacity,
          ),
          weight: weightByTwo,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(
            begin: maxOpacity,
            end: minOpacity,
          ),
          weight: weightByTwo,
        ),
      ]);
    }

    bloomSequence.addAll([
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: minBloom,
          end: maxBloom,
        ),
        weight: weightByTwo,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: maxBloom,
          end: minBloom,
        ),
        weight: weight,
      ),
    ]);
    opacitySequence.addAll([
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: minOpacity,
          end: maxOpacity,
        ),
        weight: weightByTwo,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: maxOpacity,
          end: minOpacity,
        ),
        weight: weight,
      ),
    ]);

    final List<Widget> result = widget.items.asMap().entries.map<Widget>(
      (element) {
        final double factor = _getPositionFactorOfIndex(element.key.toDouble());
        final double dx = maxWidth * factor;

        return Positioned.fromRect(
          rect: Rect.fromCenter(
            center: Offset(dx, itemBaseAlignment),
            width: 80,
            height: 50,
          ),
          child: InkWell(
            onTap: () {
              widget.onSelected(element.key);
            },
            //splashRadius: radius,
            radius: inkwellSize,
            child: _NavigationBarAnimatedItemView(
              item: element.value,
              isSelected: widget.currentSelection == element.key,
            ),
            //iconSize: size,
          ),
        );
      },
    ).toList();

    _colorSequence = TweenSequence<Color?>(colorSequence);
    _bloomSequence = TweenSequence<double>(bloomSequence);
    _opacitySequence = TweenSequence<double>(opacitySequence);
    _opacityAnimation = _opacitySequence!.animate(_animationController);

    return result;
  }

  void _resetCaches() {
    _children = null;
    _colorSequence = null;
    _bloomSequence = null;
    _opacitySequence = null;
    _opacityAnimation = null;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final Color backgroundColor = themeData.canvasColor;
    final Color primaryColor = themeData.primaryColor;
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
              if (_oldConstraints != constraints) {
                _resetCaches();
              }

              _oldConstraints = constraints;

              _children ??= [
                ..._getChildren(
                  maxWidth: constraints.maxWidth,
                  itemBaseAlignment: itemBaseAlignment,
                  inkwellSize: size,
                  primaryColor: primaryColor,
                  minBloom: 0.2,
                  maxBloom: 0.7,
                  minOpacity: 0,
                  maxOpacity: 1,
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
                          _getIndicatorDXOffset(constraints.maxWidth),
                          indicatorBaseAlignment,
                        ),
                        width: indicatorHeight,
                        height: indicatorHeight,
                      ),
                      child: FadeTransition(
                        opacity: _opacityAnimation ??
                            const AlwaysStoppedAnimation(1),
                        child: _Indicator(
                          backgroundColor: Colors.white,
                          color: _colorSequence?.evaluate(_animationController),
                          bloomRadius:
                              _bloomSequence?.evaluate(_animationController),
                        ),
                      ),
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
  final double? bloomRadius;
  final Size indicatorSize;

  const _Indicator({
    // ignore: unused_element
    super.key,
    // ignore: unused_element
    this.color,
    required this.backgroundColor,
    // ignore: unused_element
    this.bloomRadius,
    // ignore: unused_element
    this.indicatorSize = const Size(30, 5),
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
                    radius: bloomRadius ?? 0.6,
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
              child: SizedBox.fromSize(
                size: indicatorSize,
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
            child: FittedBox(
              child: widget.item.itemBuilder(context, widget.isSelected),
            ),
          ),
          const SizedBox(
            height: 2,
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
}*/

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
