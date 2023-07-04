part of '../widgets.dart';

class LyricsListView extends StatefulWidget {
  final List<LyricsLine> lyrics;
  final int initialLine;
  final ItemScrollController? controller;
  final ItemPositionsListener? positionsListener;
  final VoidCallback? Function(int index)? onTap;
  final int? currentLine;
  final double opacityThreshold;
  final bool showBackground;
  final bool playMusicVisualizerAnimation;

  const LyricsListView({
    super.key,
    required this.lyrics,
    this.initialLine = 0,
    this.controller,
    this.currentLine,
    this.positionsListener,
    this.onTap,
    this.opacityThreshold = 0.2,
    this.showBackground = false,
    this.playMusicVisualizerAnimation = true,
  });

  @override
  State<LyricsListView> createState() => _LyricsListViewState();
}

class _LyricsListViewState extends State<LyricsListView> {
  //late ItemPositionsListener _itemPositionsListener;
  //late final _Opacities _opacities;

  /*@override
  void initState() {
    super.initState();
    /*_opacities = _Opacities(
      threshold: widget.opacityThreshold,
    );*/
    _itemPositionsListener =
        widget.positionsListener ?? ItemPositionsListener.create();
    _itemPositionsListener.itemPositions.addListener(_linePositionListener);
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_linePositionListener);
    super.dispose();
  }

  @override
  void didUpdateWidget(LyricsListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _itemPositionsListener.itemPositions.removeListener(_linePositionListener);
    _itemPositionsListener =
        widget.positionsListener ?? ItemPositionsListener.create();
    _itemPositionsListener.itemPositions.addListener(_linePositionListener);
  }*/

  /*void _linePositionListener() {
    final List<ItemPosition> positions =
        _itemPositionsListener.itemPositions.value.toList();
    //_opacities.setOpacitiesForItemPositions(positions, widget.currentLine);
  }*/

  late Gradient _gradient;
  Rect? _cachedForBounds;
  late Shader _cachedShader;

  @override
  void initState() {
    super.initState();
    _setGradient();
  }

  @override
  void didUpdateWidget(LyricsListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.opacityThreshold != oldWidget.opacityThreshold) {
      _setGradient();
    }
  }

  void _setGradient() {
    final double opacityThreshold = widget.opacityThreshold;

    final double invisiblePart = opacityThreshold * 0.25;

    _gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Colors.transparent,
        Colors.transparent,
        Colors.white,
        Colors.white,
        Colors.transparent,
        Colors.transparent,
      ],
      stops: [
        0.0,
        invisiblePart,
        opacityThreshold,
        1 - opacityThreshold,
        1 - invisiblePart,
        1.0,
      ],
    );
  }

  Shader _getShaderFor(Rect bounds) {
    if (_cachedForBounds != bounds) {
      _cachedForBounds = bounds;
      return _cachedShader = _gradient.createShader(bounds);
    }
    return _cachedShader;
  }

  @override
  Widget build(BuildContext context) {
    final List<LyricsLine> lyrics = widget.lyrics;
    final int? currentLine = widget.currentLine;
    final VoidCallback? Function(int index)? onTapGetter = widget.onTap;
    return ShaderMask(
      shaderCallback: (bounds) {
        return _getShaderFor(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: NoOverscrollGlow(
        child: SharedPreferenceListener<String?, Widget>(
          sharedPreferenceKey:
              SharedPreferencesHelper.keys.lyricsTranslationLanguage,
          valueIfNull: null,
          builder: (context, value, separator) {
            final bool showTranslation = value != null;
            return ScrollablePositionedList.separated(
              initialScrollIndex: widget.initialLine,
              itemScrollController: widget.controller,
              itemPositionsListener: widget.positionsListener,
              itemCount: lyrics.length,
              itemBuilder: (context, index) {
                final VoidCallback? onTap = onTapGetter?.call(index);
                final bool showHeighlightAndVisualization =
                    (index > 0) && (index < (lyrics.length - 1));
                final bool isCurrent = index == currentLine;
                final LyricsLine line = lyrics[index];

                return LyricsLineView(
                  //opacity: opacity,
                  onTap: onTap,
                  line: line,
                  shouldHighlight: showHeighlightAndVisualization,
                  index: index,
                  isCurrent: isCurrent,
                  showTranslation: showTranslation,
                  showBackground: widget.showBackground,
                  showMusicVisualizerAnimation: showHeighlightAndVisualization,
                  playMusicVisualizerAnimation:
                      widget.playMusicVisualizerAnimation,
                );
              },
              separatorBuilder: (context, index) => separator!,
            );
          },
          object: const SizedBox(
            height: 10,
          ),
        ),
      ),
    );
  }
}

/*
class _Opacities {
  final double _threshold;

  _Opacities({
    // ignore: unused_element
    double? threshold,
  }) : _threshold = threshold ?? 0.1;

  final Map<int, double> opacities = {};

  @protected
  final Map<int, List<VoidCallback>> listeners = {};

  @protected
  final Map<int, bool> shouldNotify = {};

  void setOpacitiesForItemPositions(
    List<ItemPosition> itemPositions,
    int? currentLine,
  ) {
    opacities.clear();
    shouldNotify.clear();

    final int length = itemPositions.length;
    final int middle = length ~/ 2;

    for (int i = 0; i < length; ++i) {
      final ItemPosition itemPosition = itemPositions[i];
      final int index = itemPosition.index;
      late final double opacity;

      final double considerableEdge = (i <= middle)
          ? itemPosition.itemLeadingEdge
          : (1 - itemPosition.itemTrailingEdge);

      //const double threshold = 0.15;

      //logExceptRelease("Considerable Edge for $index: $considerableEdge");

      if (considerableEdge <= _threshold) {
        opacity = _project(considerableEdge, _threshold);
      } else {
        opacity = 1;
      }

      opacities[index] = opacity;
      shouldNotify[index] = true;
    }

    notifyListeners();
  }

  double _project(double value, double threshold) {
    final double clampedValue = clampDouble(value, 0, threshold);

    final double projectedValue = clampedValue / threshold;

    return projectedValue;
  }

  @protected
  void notifyListeners() {
    final List<MapEntry<int, bool>> toNotify = shouldNotify.entries
        .where(
          (element) => element.value,
        )
        .toList();

    for (final MapEntry<int, bool> element in toNotify) {
      for (final VoidCallback x in listeners[element.key] ?? []) {
        x();
      }
    }
    shouldNotify.clear();
  }

  void addListener(int line, VoidCallback callback) {
    if (listeners[line] == null) {
      listeners[line] = [];
    }
    listeners[line]!.add(callback);
  }

  void removeListener(int line, VoidCallback callback) {
    listeners[line]?.remove(callback);
  }

  double operator [](int index) {
    return opacities[index] ?? 0;
  }
}

typedef OpacityListenerBuilder = Widget Function(
  BuildContext context,
  double opacity,
);

class _OpacityChangeListener extends StatefulWidget {
  final int line;
  final OpacityListenerBuilder builder;
  final _Opacities opacities;

  const _OpacityChangeListener({
    // ignore: unused_element
    super.key,
    required this.line,
    required this.builder,
    required this.opacities,
  });

  @override
  State<_OpacityChangeListener> createState() => __OpacityChangeListenerState();
}

class __OpacityChangeListenerState extends State<_OpacityChangeListener> {
  @override
  void initState() {
    super.initState();
    widget.opacities.addListener(widget.line, _listener);
  }

  @override
  void dispose() {
    widget.opacities.removeListener(widget.line, _listener);
    super.dispose();
  }

  @override
  void didUpdateWidget(_OpacityChangeListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.opacities.removeListener(oldWidget.line, _listener);
    widget.opacities.addListener(widget.line, _listener);
  }

  void _listener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.opacities[widget.line]);
  }
}
*/
