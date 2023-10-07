part of '../../pages.dart';

typedef LyricsLinesOnSave = FutureOr<void> Function(
  List<LyricsLine>? newLyrics,
);

Future<void> showLyricsSynchronizationPage({
  required List<String> lines,
  required LyricsLinesOnSave onSave,
  //required Uint8List albumArt,
  required Uint8List? initialAlbumArt,
  required Future<void> Function(Duration duration) onDurationChange,
  //AsyncVoidCallback? seekToStart,
  required AsyncCallback onStartSynchronisation,
  SongBase? song,
}) async {
  await navigateToPagePush(
    LyricsSynchronization(
      lines: lines,
      onSave: onSave,
      //albumArt: albumArt,
      initialAlbumArt: initialAlbumArt,
      //seekToStart: seekToStart,
      song: song,
      onDurationChange: onDurationChange,
      onStartSynchronisation: onStartSynchronisation,
    ),
  );
}

class LyricsSynchronization extends StatefulWidget {
  final List<String> lines;
  final LyricsLinesOnSave onSave;
  //final Uint8List albumArt;
  final Uint8List? initialAlbumArt;
  //final AsyncVoidCallback? seekToStart;
  final SongBase? song;
  final Future<void> Function(Duration duration) onDurationChange;
  final AsyncCallback onStartSynchronisation;

  const LyricsSynchronization({
    super.key,
    required this.lines,
    required this.onSave,
    //required this.albumArt,
    required this.initialAlbumArt,
    required this.onDurationChange,
    //this.seekToStart,
    required this.onStartSynchronisation,
    this.song,
  });

  @override
  State<LyricsSynchronization> createState() => _LyricsSynchronizationState();
}

class _LyricsSynchronizationState extends State<LyricsSynchronization>
    with LogHelperMixin {
  late final ItemScrollController _itemScrollController;
  late final ValueNotifier<int> _currentLine;
  late final Stopwatch _stopwatch;
  late final ValueNotifier<bool> _inProgress;

  late final List<Duration> _durations;

  late final List<LyricsLine> _lines;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _durations = [];
    _lines = _getLyrics();
    _inProgress = ValueNotifier<bool>(false)..addListener(_inProgressListener);
    _itemScrollController = ItemScrollController();
    _stopwatch = Stopwatch();
    _currentLine = ValueNotifier<int>(0);
  }

  @override
  void dispose() {
    _inProgress.dispose();
    _currentLine.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  final Tween<Offset> _bottomActionSlideOffsetTween = Tween<Offset>(
    begin: const Offset(0, 1),
    end: Offset.zero,
  );

  void _inProgressListener() {
    if (_inProgress.value) {
      _stopwatch.reset();
      _stopwatch.start();
      logER("Stopwatch started and reseted.");
    } else {
      _stopwatch.stop();
      logER("Stopwatch stopped.");
    }
  }

  Future<void> _onStart() async {
    await widget.onStartSynchronisation();
    await _itemScrollController.scrollTo(
      index: 0,
      duration: const Duration(
        milliseconds: 200,
      ),
      alignment: 0.3,
    );
    _inProgress.value = true;
  }

  Future<void> _onBack() async {
    if (_currentLine.value <= 0) {
      return;
    }
    final Duration x = _durations.removeLast();
    _totalDuration -= x;
    logER("Removed: $x");
    await widget.onDurationChange(_totalDuration);
    await _itemScrollController.scrollTo(
      index: --_currentLine.value,
      duration: const Duration(
        milliseconds: 200,
      ),
      alignment: 0.45,
    );
    _stopwatch.reset();
  }

  Future<void> _onNext(int linesLength) async {
    if (_currentLine.value >= linesLength) {
      return;
    }
    final Duration x = _stopwatch.elapsed;
    _totalDuration += x;

    _durations.add(x);
    logER("Added: $x");
    await _itemScrollController.scrollTo(
      index: ++_currentLine.value,
      duration: const Duration(
        milliseconds: 200,
      ),
      alignment: 0.45,
    );
    _stopwatch.reset();
  }

  Future<void> _onDone() async {
    _stopwatch.stop();
    _stopwatch.reset();
    if (_durations.isEmpty) {
      return;
    }
    final List<String> lines = widget.lines;
    final List<LyricsLine> result = [];
    for (int i = 0; i < lines.length; ++i) {
      final Duration duration = _durations[i];
      final LyricsLine x = LyricsLine(
        duration: duration,
        line: lines[i],
        translation: null,
        startPosition:
            (result.lastOrNull?.startPosition ?? Duration.zero) + duration,
      );
      logER(x.toString());
      result.add(x);
    }

    await widget.onSave(
      result,
    );
  }

  List<LyricsLine> _getLyrics() {
    return [
      const LyricsLine.empty(),
      ...widget.lines.map(
        (e) => LyricsLine(
          line: e,
          duration: Duration.zero,
          translation: null,
          startPosition: Duration.zero,
        ),
      ),
      const LyricsLine.empty(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AllWhite(
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            AlbumArtView(
              songbase: widget.song,
              initialImage: widget.initialAlbumArt,
              resolvedAlbumArt: widget.song,
              dimValue: 0.65,
              loadClip: true,
            ),
            Material(
              type: MaterialType.transparency,
              child: SafeArea(
                child: Column(
                  children: [
                    MultiValueListenableBuilder<String>(
                      valueListenables: {
                        "inProgress": _inProgress,
                        "currentLine": _currentLine,
                      },
                      builder: (context, values, object) {
                        final bool isShown = !(values["inProgress"] as bool);
                        return AnimatedShowHide(
                          showDuration: const Duration(milliseconds: 250),
                          hideDuration: const Duration(milliseconds: 250),
                          showCurve: Curves.ease,
                          hideCurve: Curves.ease,
                          isShown: isShown,
                          child: object! as Widget,
                        );
                      },
                      object: Stack(
                        children: [
                          const Align(
                            child: BackButton(),
                            alignment: Alignment.topLeft,
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                "Synchronization".translate(context),
                                textScaleFactor: 1.4,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    //! Content
                    Expanded(
                      child: ValueListenableBuilder<int>(
                        valueListenable: _currentLine,
                        builder: (context, currentLine, _) {
                          logER("CurrentLine: $currentLine");
                          return LyricsListView(
                            lyrics: _lines,
                            controller: _itemScrollController,
                            currentLine: currentLine,
                            opacityThreshold: 0.05,
                            showBackground: true,
                          );
                        },
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    //! Controls
                    ValueListenableBuilder<bool>(
                      valueListenable: _inProgress,
                      builder: (context, inProgress, controls) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 275),
                          child: inProgress
                              ? controls!
                              : TextButton(
                                  onPressed: _onStart,
                                  child: Text(
                                    "Start".translate(context),
                                    style: const TextStyle(
                                      fontSize: 40,
                                      color: Colors.white,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInCirc,
                              ),
                              child: SlideTransition(
                                position: _bottomActionSlideOffsetTween
                                    .animate(animation),
                                child: child,
                              ),
                            );
                          },
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _onBack,
                            icon: const Icon(Icons.keyboard_arrow_up_rounded),
                            enableFeedback: false,
                            tooltip: "Previous line".translate(context),
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                          ValueListenableBuilder<int>(
                            valueListenable: _currentLine,
                            builder: (context, currentLine, doneButton) {
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 80),
                                child: (currentLine == (_lines.length - 1))
                                    ? doneButton!
                                    : IconButton(
                                        key: const ValueKey<String>(
                                          "NextButton",
                                        ),
                                        iconSize: 40,
                                        onPressed: () {
                                          _onNext(_lines.length);
                                        },
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                        ),
                                        enableFeedback: false,
                                        tooltip: "Next line".translate(context),
                                      ),
                              );
                            },
                            child: IconButton(
                              key: const ValueKey<String>("DoneButton"),
                              iconSize: 40,
                              onPressed: _onDone,
                              icon: const Icon(
                                Icons.done_rounded,
                              ),
                              tooltip: "Done".translate(context),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
