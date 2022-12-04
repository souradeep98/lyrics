part of widgets;

//! Currently Playing
class CurrentlyPlaying extends StatefulWidget {
  const CurrentlyPlaying({
    // ignore: unused_element
    super.key,
  });

  @override
  State<CurrentlyPlaying> createState() => _CurrentlyPlayingState();
}

class _CurrentlyPlayingState extends State<CurrentlyPlaying> {
  late final BulkNotifier<double> _scrollSynchronizer;

  @override
  void initState() {
    super.initState();
    _scrollSynchronizer = BulkNotifier<double>(0);
  }

  @override
  Widget build(BuildContext context) {
    final Widget miniView = _CurrentlyPlayingMiniView(
      scrollSynchronizer: _scrollSynchronizer,
    );
    final Widget extendedView = _CurrentlyPlayingExpandedView(
      scrollSynchronizer: _scrollSynchronizer,
    );

    return OpenContainer<int>(
      closedBuilder: (context, onClose) => miniView,
      openBuilder: (context, returnValue) => extendedView,
      closedShape: const RoundedRectangleBorder(),
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: const Duration(milliseconds: 450),
    );
  }
}

//! Mini view of currently playing
class _CurrentlyPlayingMiniView extends StatefulWidget {
  final BulkNotifier<double>? scrollSynchronizer;

  const _CurrentlyPlayingMiniView({
    // ignore: unused_element
    super.key,
    this.scrollSynchronizer,
  });

  @override
  State<_CurrentlyPlayingMiniView> createState() =>
      _CurrentlyPlayingMiniViewState();
}

class _CurrentlyPlayingMiniViewState extends State<_CurrentlyPlayingMiniView> {
  late final PageController _pageController;
  static const String _synchronizerKey = "MiniView";

  @override
  void initState() {
    super.initState();
    //logExceptRelease("$_synchronizerKey initState");
    _pageController = PageController(
      initialPage: widget.scrollSynchronizer?.value.toInt() ?? 0,
    );
    if (widget.scrollSynchronizer != null) {
      widget.scrollSynchronizer
          ?.addListener(_synchronizerKey, _synchronizerListener);
      _pageController.addListener(_controllerListener);
    }
  }

  @override
  void dispose() {
    //logExceptRelease("$_synchronizerKey dispose");
    widget.scrollSynchronizer?.removeListener(_synchronizerKey);
    _pageController.dispose();
    super.dispose();
  }

  void _controllerListener() {
    final double? page = _pageController.page;
    if (page == null) {
      return;
    }
    late final double value;
    if ((page - page.truncateToDouble()) > 0.5) {
      value = (page + 1).truncateToDouble();
    } else {
      value = page.truncateToDouble();
    }
    logExceptRelease("$_synchronizerKey setting $value");
    widget.scrollSynchronizer?.setValue(_synchronizerKey, value);
  }

  void _synchronizerListener(Object? key, double value) {
    logExceptRelease("$_synchronizerKey got $value");
    _pageController.jumpToPage(value.toInt());
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: PlayerNotificationListener(
        builder: (context, detectedPlayers, _) {
          if (detectedPlayers.isEmpty) {
            return const SizedBox();
          }
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Now playing:",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  SizedBox(
                    height: 80,
                    child: PageView.builder(
                      controller: _pageController,
                      itemBuilder: (context, index) {
                        final ResolvedPlayerData detectedPlayer =
                            detectedPlayers[index];
                        final PlayerData playerData = detectedPlayer.playerData;
                        final PlayerStateData stateData = playerData.state;
                        final SongBase? resolvedSong = stateData.resolvedSong;
                        final SongBase playerDetectedSOng =
                            stateData.playerDetectedSong;

                        return IntrinsicHeight(
                          child: ListTile(
                            leading: AspectRatio(
                              aspectRatio: 1,
                              child: AlbumArtView(
                                resolvedSongBase: resolvedSong,
                                playerStateData: stateData,
                              ),
                            ),
                            title: Text(playerDetectedSOng.songName),
                            subtitle: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IgnorePointer(
                                  child: Marquee(
                                    animationDuration:
                                        const Duration(seconds: 3),
                                    backDuration:
                                        const Duration(milliseconds: 30),
                                    child: Text(
                                      "${playerDetectedSOng.singerName} - ${playerDetectedSOng.albumName}",
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    if (Platform.isAndroid) {
                                      await LaunchApp.openApp(
                                        androidPackageName:
                                            playerData.packageName,
                                        openStore: false,
                                      );
                                    }
                                  },
                                  child: Image.asset(
                                    playerData
                                        .iconFullAsset(LogoColorType.black),
                                    height: 18,
                                    //scale: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            trailing: PlayPauseButton(
                              onPlayPause: detectedPlayer.setState,
                              state: stateData.state,
                              color: Colors.black,
                            ),
                          ),
                        );
                      },
                      itemCount: detectedPlayers.length,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                ],
              ),
              SizedBox(
                height: 12,
                child: Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: detectedPlayers.length,
                    effect: const SlideEffect(
                      paintStyle: PaintingStyle.stroke,
                      dotColor: Colors.black,
                      activeDotColor: Colors.black,
                      radius: 6,
                      dotHeight: 6,
                      dotWidth: 6,
                      offset: 6,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

//! Extended view of currently playing
class _CurrentlyPlayingExpandedView extends StatefulWidget {
  final SongBase? song;
  final BulkNotifier<double>? scrollSynchronizer;
  // ignore: unused_element
  const _CurrentlyPlayingExpandedView({
    // ignore: unused_element
    super.key,
    this.song,
    this.scrollSynchronizer,
  });

  @override
  State<_CurrentlyPlayingExpandedView> createState() =>
      _CurrentlyPlayingExpandedViewState();
}

class _CurrentlyPlayingExpandedViewState
    extends State<_CurrentlyPlayingExpandedView> {
  final BoxDecoration _overlayDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        Colors.black.withOpacity(0.001),
        Colors.black.withOpacity(0.01),
        Colors.black.withOpacity(0.1),
        Colors.black.withOpacity(0.2),
        Colors.black.withOpacity(0.3),
        Colors.black.withOpacity(0.4),
        Colors.black.withOpacity(0.5),
        Colors.black.withOpacity(0.6),
        Colors.black.withOpacity(0.7),
        Colors.black.withOpacity(0.8),
      ],
    ),
  );

  late final PageController _pageController;
  static const String _synchronizerKey = "ExtendedView";

  @override
  void initState() {
    super.initState();
    //logExceptRelease("$_synchronizerKey initState");
    _pageController = PageController(
      initialPage: widget.scrollSynchronizer?.value.toInt() ?? 0,
    );
    if (widget.scrollSynchronizer != null) {
      widget.scrollSynchronizer
          ?.addListener(_synchronizerKey, _synchronizerListener);
      _pageController.addListener(_controllerListener);
    }
    SystemChrome.setSystemUIOverlayStyle(kWhiteSystemUiOverlayStyle);
  }

  @override
  void dispose() {
    //logExceptRelease("$_synchronizerKey dispose");
    SystemChrome.setSystemUIOverlayStyle(kDefaultSystemUiOverlayStyle);
    widget.scrollSynchronizer?.removeListener(_synchronizerKey);
    _pageController.dispose();
    super.dispose();
  }

  void _controllerListener() {
    final double? page = _pageController.page;
    if (page == null) {
      return;
    }
    late final double value;
    if ((page - page.truncateToDouble()) > 0.5) {
      value = (page + 1).truncateToDouble();
    } else {
      value = page.truncateToDouble();
    }
    logExceptRelease("$_synchronizerKey setting $value");
    widget.scrollSynchronizer?.setValue(_synchronizerKey, value);
  }

  void _synchronizerListener(Object? key, double value) {
    logExceptRelease("$_synchronizerKey got $value");
    _pageController.jumpToPage(value.toInt());
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return AllWhite(
      child: SizedBox.fromSize(
        size: size,
        child: PlayerNotificationListener(
          builder: (context, detectedPlayers, overlay) {
            if (detectedPlayers.isEmpty) {
              return const SizedBox();
            }

            final List<PlayerData> playerDataList = detectedPlayers
                .map<PlayerData>(
                  (e) => e.playerData,
                )
                .toList();

            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                NoOverscrollGlow(
                  child: PageView.builder(
                    padEnds: false,
                    itemCount: detectedPlayers.length,
                    controller: _pageController,
                    itemBuilder: (context, index) {
                      final ResolvedPlayerData detectedPlayer =
                          detectedPlayers[index];
                      final PlayerData playerData = playerDataList[index];
                      final PlayerStateData stateData = playerData.state;
                      final SongBase? resolvedSong = stateData.resolvedSong;
                      final SongBase playerDetectedSong = stateData.playerDetectedSong;

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          // Album Art
                          AlbumArtView(
                            playerStateData: stateData,
                            resolvedSongBase: resolvedSong,
                          ),

                          // Overlay
                          overlay!,

                          // Top layer: Lyrics, Metadata, Controls
                          Material(
                            type: MaterialType.transparency,
                            child: Column(
                              children: [
                                // Lyrics
                                Expanded(
                                  child: LyricsView(
                                    playerStateData: stateData,
                                    seekToStart: detectedPlayer.skipToStart,
                                  ),
                                ),

                                // Metadata, controls...
                                Container(
                                  width: size.width,
                                  decoration: _overlayDecoration,
                                  padding: const EdgeInsets.only(
                                    top: 40,
                                    left: 30,
                                    right: 30,
                                    bottom: 20,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Song name
                                      Text(
                                        playerDetectedSong.songName,
                                        textScaleFactor: 2.25,
                                        style: GoogleFonts.volkhov(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),

                                      const SizedBox(
                                        height: 10,
                                      ),

                                      // Controls
                                      //AnimatedShowHide(isShown: isShown, child: child)
                                      ControlButtons(
                                        state: stateData.state,
                                        onPlayPause: detectedPlayer.setState,
                                        onNext: detectedPlayer.next,
                                        onPrevious: detectedPlayer.previous,
                                        previousIconSize: 30,
                                        nextIconSize: 30,
                                        playPauseIconSize: 40,
                                      ),

                                      // Player state
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Text(
                                          stateData.state.prettyName,
                                        ),
                                      ),

                                      // Singer name
                                      Text(
                                        playerDetectedSong.singerName,
                                        textScaleFactor: 1.25,
                                        style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),

                                      const SizedBox(
                                        height: 10,
                                      ),

                                      // Album name
                                      Text(
                                        playerDetectedSong.albumName,
                                        textScaleFactor: 1.1,
                                        style: GoogleFonts.merriweather(
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),

                                      const SizedBox(
                                        height: 20 + 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Player indicator
                SizedBox(
                  height: 30,
                  width: size.width,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Align(
                        child: SmoothPageIndicator(
                          controller: _pageController,
                          count: detectedPlayers.length,
                          effect: const SlideEffect(
                            paintStyle: PaintingStyle.stroke,
                            dotColor: Colors.white,
                            activeDotColor: Colors.white,
                            radius: 6,
                            dotHeight: 6,
                            dotWidth: 6,
                            offset: 6,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 100,
                          child: _CurrentPlayerLogogView(
                            pageController: _pageController,
                            initialItem:
                                widget.scrollSynchronizer?.value.toInt(),
                            itemBuilder: (context, index) {
                              final PlayerData playerData =
                                  playerDataList[index];
                              /*logExceptRelease(
                                "Building logo: ${playerData.iconFullAssetName}",
                              );*/
                              final String logoAssetName =
                                  playerData.iconFullAsset(LogoColorType.white);
                              return Tooltip(
                                key: ValueKey<String>(
                                  logoAssetName,
                                ),
                                message: "Open ${playerData.playerName}",
                                child: GestureDetector(
                                  onTap: () async {
                                    if (Platform.isAndroid) {
                                      await LaunchApp.openApp(
                                        androidPackageName:
                                            playerData.packageName,
                                        openStore: false,
                                      );
                                    }
                                  },
                                  child: Image.asset(
                                    logoAssetName,
                                    height: 16,
                                    opacity:
                                        const AlwaysStoppedAnimation<double>(
                                      0.85,
                                    ),
                                  ),
                                ),
                              );
                            },
                            itemCount: playerDataList.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          child: ColoredBox(
            color: Colors.black.withOpacity(0.2),
            child: SizedBox.fromSize(
              size: size,
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrentPlayerLogogView extends StatefulWidget {
  final double? height;
  final double? width;
  final PageController pageController;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final int itemCount;
  final int? initialItem;

  const _CurrentPlayerLogogView({
    // ignore: unused_element
    super.key,
    required this.pageController,
    required this.itemBuilder,
    required this.itemCount,
    // ignore: unused_element
    this.height,
    // ignore: unused_element
    this.width = 100,
    this.initialItem,
  });

  @override
  State<_CurrentPlayerLogogView> createState() =>
      __CurrentPlayerLogogViewState();
}

class __CurrentPlayerLogogViewState extends State<_CurrentPlayerLogogView>
    with SingleTickerProviderStateMixin {
  late final ValueNotifier<int> _currentShowingItem;
  late final AnimationController _animationController;
  late double _previousOffset;

  static const double _sway = 1;

  final Tween<Offset> _offToLeftTween = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(-_sway, 0),
  );
  final Tween<Offset> _incomingFromRightTween = Tween<Offset>(
    begin: const Offset(_sway, 0),
    end: Offset.zero,
  );

  final Tween<Offset> _incomingFromLeftTween = Tween<Offset>(
    begin: const Offset(-_sway, 0),
    end: Offset.zero,
  );
  final Tween<Offset> _offToRightTween = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(_sway, 0),
  );

  Tween<Offset>? _activeSlideTween;

  Offset get _offset =>
      _activeSlideTween?.evaluate(_animationController) ?? Offset.zero;

  final TweenSequence<double> _opacitySequence = TweenSequence<double>([
    TweenSequenceItem<double>(tween: Tween(begin: 1, end: 0), weight: 1),
    TweenSequenceItem<double>(tween: Tween(begin: 0, end: 1), weight: 1),
  ]);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, value: 1);
    _currentShowingItem = ValueNotifier<int>(
      widget.initialItem ?? widget.pageController.page?.toInt() ?? 0,
    );
    _previousOffset = widget.pageController.page ?? 0;
    widget.pageController.addListener(_pageControllerListener);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _currentShowingItem.dispose();
    widget.pageController.removeListener(_pageControllerListener);
    super.dispose();
  }

  @override
  void didUpdateWidget(_CurrentPlayerLogogView oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.pageController.removeListener(_pageControllerListener);
    widget.pageController.addListener(_pageControllerListener);
  }

  void _pageControllerListener() {
    final double? currentPageDouble = widget.pageController.page;
    //logExceptRelease(" ");
    //logExceptRelease("CurrentPageDouble: $currentPageDouble");

    if (currentPageDouble == null) {
      return;
    }

    final double currentShowingItem = _previousOffset;

    //logExceptRelease("CurrentShowingItem: $currentShowingItem");

    if (currentPageDouble > currentShowingItem) {
      //logExceptRelease("Scrolling to right");
      // scrolling to right
      final double outance =
          currentPageDouble - currentPageDouble.floorToDouble();
      //logExceptRelease("Outance: $outance");
      if (outance < 0.5) {
        // less than half way
        //logExceptRelease("< Halfway");
        _activeSlideTween = _offToLeftTween;
      } /*else if (outance == 0.5) {
        // exactly half way
        //logExceptRelease("Halfway");
      }*/
      else {
        // more than half way
        //logExceptRelease("> Halfway");
        _currentShowingItem.value = currentPageDouble.ceil();
        _activeSlideTween = _incomingFromRightTween;
      }
      _animationController.value = outance;
    } else if (currentPageDouble < currentShowingItem) {
      //logExceptRelease("Scrolling to left");
      // scrolling to left
      final double outance =
          1 - (currentPageDouble - currentPageDouble.floorToDouble());
      //logExceptRelease("Outance: $outance");
      if (outance < 0.5) {
        // less than half way
        //logExceptRelease("< Halfway");
        _activeSlideTween = _offToRightTween;
      } /*else if (outance == 0.5) {
        // exactly half way
        //logExceptRelease("Halfway");
      }*/
      else {
        // more than half way
        //logExceptRelease("> Halfway");
        _currentShowingItem.value = currentPageDouble.floor();
        _activeSlideTween = _incomingFromLeftTween;
      }
      _animationController.value = outance;
    }

    _previousOffset = currentPageDouble;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: FadeTransition(
        opacity: _opacitySequence.animate(
          _animationController,
        ),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FractionalTranslation(
              translation: _offset,
              child: child,
            );
          },
          child: ValueListenableBuilder<int>(
            valueListenable: _currentShowingItem,
            builder: (context, currentShowingItem, child) {
              return widget.itemBuilder(context, currentShowingItem);
            },
          ),
        ),
      ),
    );
  }
}
