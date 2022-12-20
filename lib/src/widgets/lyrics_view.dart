part of widgets;

//! Currently Playing - Lyrics Content View
class LyricsView extends StatefulWidget {
  //final PlayerStateData playerStateData;
  final int initialLine;
  final SongBase? song;
  final Uint8List? initialImage;
  final AsyncVoidCallback? seekToStart;
  final bool goWithFlow;

  const LyricsView({
    // ignore: unused_element
    super.key,
    required this.song,
    required this.goWithFlow,
    this.initialImage,
    // ignore: unused_element
    this.initialLine = 0,
    this.seekToStart,
  });

  @override
  State<LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<LyricsView> {
  late StreamDataObservable<List<LyricsLine>?> _lyrics;
  SongBase? get _song => widget.song;
  String get _tag => "Lyrics_${_song?.key()}";

  UniqueKey _key = UniqueKey();

  @override
  void initState() {
    super.initState();
    logExceptRelease(
      "Lyrics_View: ${_song?.key()} initState",
    );
    _lyrics = StreamDataObservable<List<LyricsLine>?>(
      stream: DatabaseHelper.getLyricsStreamFor(
        _song ?? const SongBase.doesNotExist(),
      ),
    ).put<StreamDataObservable<List<LyricsLine>?>>(tag: _tag);
  }

  @override
  void didUpdateWidget(LyricsView oldWidget) {
    logExceptRelease(
      "Lyrics_View: ${_song?.key()} didUpdateWidget",
    );
    super.didUpdateWidget(oldWidget);
    if (oldWidget.song != widget.song) {
      logExceptRelease("Should load new lyrics");
      _lyrics = StreamDataObservable<List<LyricsLine>?>(
        stream: DatabaseHelper.getLyricsStreamFor(
          _song ?? const SongBase.doesNotExist(),
        ),
      ).put<StreamDataObservable<List<LyricsLine>?>>(tag: _tag);
      _key = UniqueKey();
    }
  }

  @override
  void dispose() {
    logExceptRelease(
      "Lyrics_View: ${_song?.key()} dispose",
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: StreamDataObserver<StreamDataObservable<List<LyricsLine>?>>(
        key: _key,
        observable: _lyrics,
        builder: (x) {
          logExceptRelease("Builder, lyrics: ${x.data?.length}");
          return _LyricsViewWithScrollHandling(
            initialLine: widget.initialLine,
            lyrics: x.data!,
            goWithFlow: widget.goWithFlow,
            onEdit: () async {
              await addOrEditLyrics(
                song: _song,
                initialImage: widget.initialImage,
                lyrics: x.data,
                seekToStart: widget.seekToStart,
              );
            },
            onAddImage: () async {
              await addAlbumArt(
                _song ?? const SongBase.doesNotExist(),
              );
            },
            seekToStart: widget.seekToStart,
          );
        },
        dataIsEmpty: (x) {
          final bool result = x.data == null;
          //logExceptRelease("DataIsEmpty: $result");
          return result;
        },
        emptyWidgetBuilder: (x) {
          return _LyricsNotPresent(
            onAddAlbumArt: () async {
              await addAlbumArt(
                _song ?? const SongBase.doesNotExist(),
              );
            },
            onAddLyrics: () async {
              await addOrEditLyrics(
                song: _song,
                initialImage: widget.initialImage,
                lyrics: null,
                seekToStart: widget.seekToStart,
              );
            },
          );
        },
      ),
    );
  }
}

//! Content View - Lyrics View
class _LyricsViewWithScrollHandling extends StatefulWidget {
  final AsyncVoidCallback onEdit;
  final AsyncVoidCallback onAddImage;
  final int initialLine;
  final List<LyricsLine> lyrics;
  final bool goWithFlow;
  final AsyncVoidCallback? seekToStart;

  const _LyricsViewWithScrollHandling({
    // ignore: unused_element
    super.key,
    required this.initialLine,
    required this.lyrics,
    required this.onEdit,
    required this.goWithFlow,
    required this.onAddImage,
    required this.seekToStart,
  });

  @override
  State<_LyricsViewWithScrollHandling> createState() =>
      __LyricsViewWithScrollHandlingState();
}

class __LyricsViewWithScrollHandlingState
    extends State<_LyricsViewWithScrollHandling> {
  late final ItemScrollController _itemScrollController;
  late final ItemPositionsListener _itemPositionsListener;

  late final ValueNotifier<int> _currentLine;
  late List<LyricsLine> _lyrics;
  late List<String> _lines;

  Timer? _nextLineTimer;
  late final Stopwatch _stopwatch;
  Duration? _midPassDuration;
  late final ValueNotifier<bool> _isCurrentLineVisible;

  @override
  void initState() {
    super.initState();
    /*logExceptRelease(
        "Lyrics_View_With_Scroll: ${widget.lyrics.length} initState");*/
    _stopwatch = Stopwatch();
    _itemScrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();
    _isCurrentLineVisible = ValueNotifier<bool>(
      _itemPositionsListener.itemPositions.value
          .any((element) => element.index == _currentLine.value),
    );
    _itemPositionsListener.itemPositions.addListener(_linePositionListener);
    _currentLine = ValueNotifier<int>(widget.initialLine)
      ..addListener(_lineChangeListener);
    _lyrics = _generateLyrics();
    _lines = _lyrics.map<String>((e) => e.line).toList();
  }

  @override
  void dispose() {
    /*logExceptRelease(
        "Lyrics_View_With_Scroll: ${widget.lyrics.length} dispose");*/
    _currentLine.dispose();
    _itemPositionsListener.itemPositions.removeListener(_linePositionListener);
    _isCurrentLineVisible.dispose();
    _nextLineTimer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  void didUpdateWidget(_LyricsViewWithScrollHandling oldWidget) {
    /*logExceptRelease(
        "Lyrics_View_With_Scroll: ${widget.lyrics.length} didUpdateWidget");*/
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLine != widget.initialLine) {
      _startFromLine(widget.initialLine);
    }
    if (widget.goWithFlow != oldWidget.goWithFlow) {
      _setActivityState(widget.goWithFlow);
    }
    if (!listEquals(oldWidget.lyrics, widget.lyrics)) {
      _lyrics = _generateLyrics();
      _lines = _lyrics.map<String>((e) => e.line).toList();
      _currentLine.value = widget.initialLine;
      _goWithFlow();
    }
  }

  void _linePositionListener() {
    final List<ItemPosition> positions =
        _itemPositionsListener.itemPositions.value.toList();
    //logExceptRelease(positions);
    final int currentLine = _currentLine.value;
    _detectIfCurrentItemIsVisible(positions, currentLine);
    //_opacities.setOpacitiesForItemPositions(positions, currentLine);
  }

  void _detectIfCurrentItemIsVisible(
    List<ItemPosition> positions,
    int currentLine,
  ) {
    final bool result =
        positions.any((element) => element.index == currentLine);
    _isCurrentLineVisible.value = result;
  }

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

    logExceptRelease("Going to the nextline after: $delay");
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

    if (widget.goWithFlow) {
      _goWithFlow();
    }
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
  }

  void _scrollToCurrentItem() {
    final int currentLine = _currentLine.value;
    _itemScrollController.scrollTo(
      index: currentLine,
      duration: const Duration(
        milliseconds: 250,
      ),
      curve: const Interval(0, 1, curve: Curves.easeIn),
      alignment: 0.45,
    );
  }

  @override
  Widget build(BuildContext context) {
    //final MediaQueryData mediaQueryData = MediaQuery.of(context);
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
              children: [
                IconButton(
                  onPressed: Navigator.of(context).pop,
                  icon: const Icon(Icons.list_rounded),
                ),
                const Spacer(),
                ValueListenableBuilder<bool>(
                  valueListenable: _isCurrentLineVisible,
                  builder: (context, isCurrentItemVisible, button) {
                    return AnimatedShowHide(
                      showDuration: const Duration(milliseconds: 200),
                      hideDuration: const Duration(milliseconds: 200),
                      isShown: !isCurrentItemVisible && widget.goWithFlow,
                      child: button!,
                    );
                  },
                  child: IconButton(
                    icon: const Icon(Icons.vertical_align_center),
                    onPressed: _scrollToCurrentItem,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await widget.seekToStart?.call();
                    _startFromLine(0);
                  },
                  icon: const Icon(Icons.keyboard_arrow_up_rounded),
                ),
                IconButton(
                  onPressed: () async {
                    await widget.onAddImage();
                  },
                  icon: const Icon(Icons.image),
                ),
                IconButton(
                  onPressed: () async {
                    await widget.onEdit();
                  },
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<int>(
            valueListenable: _currentLine,
            builder: (context, currentLine, _) {
              return LyricsListView(
                lyrics: _lines,
                controller: _itemScrollController,
                positionsListener: _itemPositionsListener,
                onTap: (index) => () {
                  _startFromLine(index);
                },
                currentLine: currentLine,
              );
            },
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
            child: const Center(
              child: Text(
                "Tap to add Lyrics",
                textScaleFactor: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
