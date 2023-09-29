part of '../widgets.dart';

//! Currently Playing - Lyrics Content View
/// Fetches the lyrics, handles song changes, uses _LyricsViewScrollHandler
class LyricsView extends StatefulWidget {
  //final PlayerStateData playerStateData;
  //final int initialLine;
  final SongBase? song;
  final Uint8List? initialImage;
  final AsyncVoidCallback? seekToStart;
  //final bool goWithFlow;
  //final bool isPlaying;
  final Future<void> Function()? onStartSynchronisation;

  final Duration? totalDuration;
  final Duration? setDuration;
  final DateTime? setAt;
  final ActivityState? state;
  final Future<void> Function(Duration duration)? onDurationChange;

  const LyricsView({
    // ignore: unused_element
    super.key,
    required this.song,
    //required this.goWithFlow,
    this.initialImage,
    // ignore: unused_element
    //this.initialLine = 0,
    this.seekToStart,
    this.totalDuration,
    this.setDuration,
    this.setAt,
    this.state,
    this.onDurationChange,
    required this.onStartSynchronisation,
    //required this.isPlaying,
  });

  @override
  State<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> with LogHelperMixin {
  late StreamDataObservable<List<LyricsLine>?> _lyrics;
  SongBase? get _song => widget.song;

  UniqueKey _key = UniqueKey();

  @override
  void initState() {
    super.initState();
    logER(
      "Lyrics_View: ${_song?.signature()} initState",
    );
    _lyrics = GetXControllerManager.getLyricsController(_song);
    _initializeSharedPreferencesListener();
  }

  @override
  void didUpdateWidget(LyricsView oldWidget) {
    logER(
      "Lyrics_View: ${_song?.signature()} didUpdateWidget",
    );
    super.didUpdateWidget(oldWidget);
    if (oldWidget.song != widget.song) {
      logER("Should load new lyrics");
      _lyrics = GetXControllerManager.getLyricsController(_song);
      GetXControllerManager.removeLyricsController(oldWidget.song);
      _key = UniqueKey();
      _disposeSharedPreferencesListener();
      _initializeSharedPreferencesListener();
    }
  }

  @override
  void dispose() {
    logER(
      "Lyrics_View: ${_song?.signature()} dispose",
    );
    _disposeSharedPreferencesListener();
    super.dispose();
  }

  final String _sharedPreferencesKey =
      SharedPreferencesHelper.keys.lyricsTranslationLanguage;

  void _initializeSharedPreferencesListener() {
    SharedPreferencesHelper.addListener(
      _sharedPreferencesListener,
      key: _sharedPreferencesKey,
    );
  }

  void _disposeSharedPreferencesListener() {
    SharedPreferencesHelper.removeListener(
      _sharedPreferencesListener,
      key: _sharedPreferencesKey,
    );
  }

  void _sharedPreferencesListener(dynamic value) {
    GetXControllerManager.reloadLyricsController(_song);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: StreamDataObserver<StreamDataObservable<List<LyricsLine>?>>(
        key: _key,
        observable: _lyrics,
        builder: (x) {
          final List<LyricsLine>? data = x.data;
          return _LyricsViewScrollHandler(
            lyrics: x.data!,
            //goWithFlow: widget.goWithFlow,
            onEdit: () async {
              await addOrEditLyrics(
                initialSong: _song,
                initialImage: widget.initialImage,
                initialLyrics: data,
                //seekToStart: widget.seekToStart,
                onStartSynchronisation: widget.onStartSynchronisation!,
                onDurationChange: widget.onDurationChange!,
              );
            },
            onAddImage: () async {
              /*await addAlbumArt(
                _song ?? const SongBase.doesNotExist(),
              );*/
              await addOrEditAlbumArtOrClip(
                initialImage: widget.initialImage,
                song: _song ?? const SongBase.doesNotExist(),
              );
            },
            seekToStart: widget.seekToStart,
            playVisualizerAnimation: (widget.state == null) ||
                (widget.state == ActivityState.playing),
            totalDuration: widget.totalDuration,
            setDuration: widget.setDuration,
            setAt: widget.setAt,
            state: widget.state,
            onDurationChange: widget.onDurationChange,
          );
        },
        dataIsEmpty: (x) {
          final bool result = x.data == null;
          return result;
        },
        loadingIndicator: const AppLoadingIndicator(
          backgroundColor: Colors.transparent,
        ),
        emptyWidgetBuilder: (x) {
          return _LyricsNotPresent(
            onAddAlbumArt: () async {
              /*await addAlbumArt(
                _song ?? const SongBase.doesNotExist(),
              );*/
              await addOrEditAlbumArtOrClip(
                initialImage: widget.initialImage,
                song: _song ?? const SongBase.doesNotExist(),
              );
            },
            onAddLyrics: () async {
              await addOrEditLyrics(
                initialSong: _song,
                initialImage: widget.initialImage,
                initialLyrics: null,
                //seekToStart: widget.seekToStart,
                onStartSynchronisation: widget.onStartSynchronisation!,
                onDurationChange: widget.onDurationChange!,
              );
            },
          );
        },
      ),
    );
  }
}

/// Used by Lyrics View.
///
/// Does the original job: showing the lyrics.
///
/// Also handles autoscroll according to song progress.
///
/// LyricsView passes the fetched lyrics to this Widget.
class _LyricsViewScrollHandler extends StatefulWidget {
  final AsyncVoidCallback onEdit;
  final AsyncVoidCallback onAddImage;
  final List<LyricsLine> lyrics;
  final AsyncVoidCallback? seekToStart;
  final bool playVisualizerAnimation;

  final Duration? totalDuration;
  final Duration? setDuration;
  final DateTime? setAt;
  final ActivityState? state;
  final Future<void> Function(Duration duration)? onDurationChange;

  const _LyricsViewScrollHandler({
    // ignore: unused_element
    super.key,
    required this.lyrics,
    required this.onEdit,
    required this.onAddImage,
    required this.seekToStart,
    required this.playVisualizerAnimation,
    required this.totalDuration,
    required this.setDuration,
    required this.setAt,
    required this.state,
    required this.onDurationChange,
  });

  @override
  State<_LyricsViewScrollHandler> createState() =>
      _LyricsViewScrollHandlerState();
}

class _LyricsViewScrollHandlerState extends State<_LyricsViewScrollHandler> {
  late final ItemScrollController _itemScrollController;
  late final ItemPositionsListener _itemPositionsListener;

  late final ValueNotifier<int> _currentLine;
  late List<LyricsLine> _lyrics;
  //late List<String> _lines;

  Timer? _nextLineTimer;
  late final Stopwatch _stopwatch;
  Duration? _midPassDuration;
  late final ValueNotifier<bool> _isCurrentLineVisible;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _itemScrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();
    _lyrics = _generateLyrics();
    _isCurrentLineVisible = ValueNotifier<bool>(
      _itemPositionsListener.itemPositions.value
          .any((element) => element.index == _currentLine.value),
    );
    _itemPositionsListener.itemPositions.addListener(_linePositionListener);

    _currentLine = ValueNotifier<int>(_getCurrentLine())
      ..addListener(_lineChangeListener);

    //_lines = _lyrics.map<String>((e) => e.line).toList();
  }

  @override
  void dispose() {
    _currentLine.dispose();
    _itemPositionsListener.itemPositions.removeListener(_linePositionListener);
    _isCurrentLineVisible.dispose();
    _nextLineTimer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  void didUpdateWidget(_LyricsViewScrollHandler oldWidget) {
    super.didUpdateWidget(oldWidget);
    /*if (oldWidget.initialLine != widget.initialLine) {
      _startFromLine(widget.initialLine);
    }*/
    if (widget.state != oldWidget.state) {
      _setActivityState(widget.state == ActivityState.playing);
    }
    if (!listEquals(oldWidget.lyrics, widget.lyrics)) {
      _lyrics = _generateLyrics();
      _currentLine.value = _getCurrentLine();
      _goWithFlow();
    }
  }

  void _linePositionListener() {
    final List<ItemPosition> positions =
        _itemPositionsListener.itemPositions.value.toList();
    final int currentLine = _currentLine.value;
    _detectIfCurrentItemIsVisible(positions, currentLine);
  }

  void _detectIfCurrentItemIsVisible(
    List<ItemPosition> positions,
    int currentLine,
  ) {
    final bool result =
        positions.any((element) => element.index == currentLine);
    _isCurrentLineVisible.value = result;
  }

  /// Adds an empty line in front of the lyriclines
  List<LyricsLine> _generateLyrics() {
    return [const LyricsLine.empty(), ...widget.lyrics];
  }

  void _goWithFlow() {
    final int current = _currentLine.value;
    if (current >= (_lyrics.length - 1)) {
      return;
    }

    late final Duration delay;
    if (_midPassDuration != null) {
      delay = _lyrics[current + 1].duration - _midPassDuration!;
      _midPassDuration = null;
    } else {
      delay = _lyrics[current + 1].duration;
    }

    logExceptRelease("Going to the nextline after: $delay", name: "LyricsView");
    _stopwatch.reset();
    _stopwatch.start();
    _nextLineTimer = Timer(delay, () {
      ++_currentLine.value;
    });
  }

  void _pause() {
    _midPassDuration = _stopwatch.elapsed;
    _stopwatch.stop();
    _nextLineTimer?.cancel();
  }

  void _setActivityState(bool state) {
    if (state) {
      _goWithFlow();
    } else {
      _pause();
    }
  }

  void _lineChangeListener() {
    _nextLineTimer?.cancel();

    if (_isCurrentLineVisible.value) {
      _scrollToCurrentItem();
    }
    _goWithFlow();
  }

  void _startFromLine(int line) {
    _midPassDuration = null;
    final int currentLine = _currentLine.value;
    if (currentLine == line) {
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      _currentLine.notifyListeners();
    } else {
      _currentLine.value = line;
    }

    widget.onDurationChange?.call(_lyrics[line].duration);
  }

  void _scrollToCurrentItem() {
    final int currentLine = _currentLine.value;
    _itemScrollController.scrollTo(
      index: currentLine,
      duration: const Duration(
        milliseconds: 350,
      ),
      curve: const Interval(0, 1, curve: Curves.easeOutQuad),
      alignment: 0.45,
    );
  }

  int _getCurrentLine() {
    if ((widget.setDuration == null) || (widget.setAt == null) || (widget.state == null)) {
      return 0;
    }

    final int lengthMinusOne = _lyrics.length - 1;
    
    final Duration currentDuration = PlayerMediaInfo.getCurrentDurationFor(
      state: widget.state!,
      setDuration: widget.setDuration!,
      occurrenceTime: widget.setAt!,
    );

    for (int i = 1; i < lengthMinusOne; ++i) {
      if (_lyrics[i].duration > currentDuration) {
        return i - 1;
      }
    }

    return lengthMinusOne;
  }

  @override
  Widget build(BuildContext context) {
    //final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final Color? iconColor = IconTheme.of(context).color;
    return Column(
      children: [
        // Icons: add/edit lyrics, add/edit album art
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  onPressed: Navigator.of(context).pop,
                  icon: const Icon(Icons.list_rounded),
                  tooltip: "Go back to catalog".translate(context),
                ),
                const Spacer(),
                ValueListenableBuilder<bool>(
                  valueListenable: _isCurrentLineVisible,
                  builder: (context, isCurrentItemVisible, button) {
                    return AnimatedShowHide(
                      showDuration: const Duration(milliseconds: 200),
                      hideDuration: const Duration(milliseconds: 200),
                      isShown: !isCurrentItemVisible && widget.state != null,
                      child: button!,
                    );
                  },
                  child: IconButton(
                    icon: const Icon(Icons.vertical_align_center),
                    onPressed: _scrollToCurrentItem,
                    tooltip: "Go back to current line".translate(context),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await widget.seekToStart?.call();
                    _startFromLine(0);
                  },
                  icon: const Icon(Icons.keyboard_arrow_up_rounded),
                  tooltip: "Start from the beginning".translate(context),
                ),
                LoadingIconButton(
                  onPressed: () async {
                    await widget.onAddImage();
                    return null;
                  },
                  icon: const Icon(Icons.image),
                  tooltip: "Edit Album art".translate(context),
                  loadingButtonOptions: LoadingButtonOptions(
                    loadingButtonWidgets: LoadingButtonWidgets(
                      loadingChild: SpinKitDoubleBounce(
                        color: iconColor,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await widget.onEdit();
                  },
                  icon: const Icon(Icons.edit),
                  tooltip: "Edit Lyrics".translate(context),
                ),
              ],
            ),
          ),
        ),

        // Lyrics List View, inside current line notifier
        Expanded(
          child: _FadeInTransition(
            child: ValueListenableBuilder<int>(
              valueListenable: _currentLine,
              builder: (context, currentLine, _) {
                return LyricsListView(
                  lyrics: _lyrics,
                  controller: _itemScrollController,
                  positionsListener: _itemPositionsListener,
                  onTap: (index) => () {
                    _startFromLine(index);
                  },
                  currentLine: currentLine,
                  playMusicVisualizerAnimation: widget.playVisualizerAnimation,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

//! Content View - Lyrics Not Present View
class _LyricsNotPresent extends StatelessWidget {
  final AsyncVoidCallback onAddLyrics;
  final AsyncVoidCallback onAddAlbumArt;

  const _LyricsNotPresent({
    // ignore: unused_element
    super.key,
    required this.onAddLyrics,
    required this.onAddAlbumArt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: Navigator.of(context).pop,
                  icon: const Icon(Icons.list_rounded),
                  tooltip: "Go back to catalog".translate(context),
                ),
                /*IconButton(
                  onPressed: onAddAlbumArt,
                  icon: const Icon(Icons.photo),
                ),*/
              ],
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: onAddLyrics,
            child: Center(
              child: Text(
                "Tap to add lyrics".translate(context),
                textScaleFactor: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FadeInTransition extends StatefulWidget {
  final Duration revealDuration;
  final Widget child;
  const _FadeInTransition({
    // ignore: unused_element
    super.key,
    required this.child,
    // ignore: unused_element
    this.revealDuration = const Duration(milliseconds: 350),
  });

  @override
  State<_FadeInTransition> createState() => __FadeInTransitionState();
}

class __FadeInTransitionState extends State<_FadeInTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: widget.revealDuration);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_FadeInTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.revealDuration != oldWidget.revealDuration) {
      _animationController.duration = widget.revealDuration;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController,
      child: widget.child,
    );
  }
}
