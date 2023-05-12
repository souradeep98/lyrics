part of '../../pages.dart';

typedef LyricsLinesOnSave = FutureOr<void> Function(
  List<LyricsLine>? newLyrics,
);

Future<void> showLyricsSynchronizationPage({
  required List<String> lines,
  required LyricsLinesOnSave onSave,
  //required Uint8List albumArt,
  required Uint8List? initialAlbumArt,
  AsyncVoidCallback? seekToStart,
  SongBase? song,
}) async {
  await navigateToPagePush(
    LyricsSynchronization(
      lines: lines,
      onSave: onSave,
      //albumArt: albumArt,
      initialAlbumArt: initialAlbumArt,
      seekToStart: seekToStart,
      song: song,
    ),
  );
}

class LyricsSynchronization extends StatefulWidget {
  final List<String> lines;
  final LyricsLinesOnSave onSave;
  //final Uint8List albumArt;
  final Uint8List? initialAlbumArt;
  final AsyncVoidCallback? seekToStart;
  final SongBase? song;

  const LyricsSynchronization({
    super.key,
    required this.lines,
    required this.onSave,
    //required this.albumArt,
    required this.initialAlbumArt,
    this.seekToStart,
    this.song,
  });

  @override
  State<LyricsSynchronization> createState() => _LyricsSynchronizationState();
}

class _LyricsSynchronizationState extends State<LyricsSynchronization> with LogHelperMixin {
  late final ItemScrollController _itemScrollController;
  late final ValueNotifier<int> _currentLine;
  late final Stopwatch _stopwatch;
  late final ValueNotifier<bool> _inProgress;

  late final List<Duration> _durations;

  @override
  void initState() {
    super.initState();
    _durations = [];
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

  void _onBack() {
    _stopwatch.reset();
    if (_currentLine.value <= 0) {
      return;
    }
    final Duration x = _durations.removeLast();
    logER("Removed: $x");
    _itemScrollController.scrollTo(
      index: --_currentLine.value,
      duration: const Duration(
        milliseconds: 200,
      ),
      alignment: 0.45,
    );
  }

  void _onNext(int linesLength) {
    if (_currentLine.value >= linesLength) {
      return;
    }
    final Duration x = _stopwatch.elapsed;
    _stopwatch.reset();
    _durations.add(x);
    logER("Added: $x");
    _itemScrollController.scrollTo(
      index: ++_currentLine.value,
      duration: const Duration(
        milliseconds: 200,
      ),
      alignment: 0.45,
    );
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
      final LyricsLine x = LyricsLine(
        duration: _durations[i],
        line: lines[i],
        translation: null,
      );
      logER(x.toString());
      result.add(x);
    }

    await widget.onSave(
      result,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<LyricsLine> lines = [
      const LyricsLine.empty(),
      ...widget.lines.map(
        (e) => LyricsLine(
          line: e,
          duration: Duration.zero,
          translation: null,
        ),
      ),
      const LyricsLine.empty(),
    ];
    return AllWhite(
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            AlbumArtView(
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
                                "Synchronization".translate(),
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
                            lyrics: lines,
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
                                  onPressed: () async {
                                    await widget.seekToStart?.call();
                                    _inProgress.value = true;
                                  },
                                  child: Text(
                                    "Start".translate(),
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
                            tooltip: "Previous line".translate(),
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                          ValueListenableBuilder<int>(
                            valueListenable: _currentLine,
                            builder: (context, currentLine, doneButton) {
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 80),
                                child: (currentLine == (lines.length - 1))
                                    ? doneButton!
                                    : IconButton(
                                        key: const ValueKey<String>(
                                          "NextButton",
                                        ),
                                        iconSize: 40,
                                        onPressed: () {
                                          _onNext(lines.length);
                                        },
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                        ),
                                        enableFeedback: false,
                                        tooltip: "Next line".translate(),
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
                              tooltip: "Done".translate(),
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
