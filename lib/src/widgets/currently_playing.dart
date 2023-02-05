part of widgets;

//! Currently Playing
class CurrentlyPlaying extends StatefulWidget {
  const CurrentlyPlaying({
    // ignore: unused_element
    super.key,
  });

  static const Duration transitionDuration = Duration(milliseconds: 450);
  static const Duration fadeRevealDelayDuration = Duration(milliseconds: 200);

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
      transitionDuration: CurrentlyPlaying.transitionDuration,
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
    //logExceptRelease("$_synchronizerKey setting $value");
    widget.scrollSynchronizer?.setValue(_synchronizerKey, value);
  }

  void _synchronizerListener(Object? key, double value) {
    //logExceptRelease("$_synchronizerKey got $value");
    _pageController.jumpToPage(value.toInt());
  }

  @override
  Widget build(BuildContext context) {
    final Widget nowPlaying = Text(
      "Now playing:".tr(),
      style: const TextStyle(color: Colors.black),
      //textScaleFactor: 0.9,
    );

    const double radius = 4.5;

    return ColoredBox(
      color: Colors.white,
      child: PlayerNotificationListener(
        builder: (context, detectedPlayers, _) {
          return AnimatedShowHide(
            showDuration: const Duration(milliseconds: 550),
            hideDuration: const Duration(milliseconds: 150),
            isShown: detectedPlayers.isNotEmpty,
            child: detectedPlayers.isEmpty
                ? const SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 15,
                          top: 12,
                          bottom: 6,
                          right: 15,
                        ),
                        child: Row(
                          children: [
                            Expanded(child: nowPlaying),
                            AnimatedShowHide(
                              isShown: detectedPlayers.length > 1,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Center(
                                  child: SmoothPageIndicator(
                                    controller: _pageController,
                                    count: detectedPlayers.length,
                                    effect: const SlideEffect(
                                      paintStyle: PaintingStyle.stroke,
                                      dotColor: Colors.black,
                                      activeDotColor: Colors.black,
                                      radius: radius,
                                      dotHeight: radius,
                                      dotWidth: radius,
                                      offset: radius,
                                      spacing: radius * 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 60,
                        child: PageView.builder(
                          controller: _pageController,
                          itemBuilder: (context, index) {
                            final ResolvedPlayerData detectedPlayer =
                                detectedPlayers[index];
                            final PlayerData playerData =
                                detectedPlayer.playerData;
                            final PlayerStateData stateData = playerData.state;
                            //final SongBase? resolvedSong = stateData.resolvedSong;
                            final SongBase? resolvedAlbumArt =
                                stateData.resolvedAlbumArt;
                            final SongBase playerDetectedSong =
                                stateData.playerDetectedSong;

                            return IntrinsicHeight(
                              child: ListTile(
                                dense: true,
                                leading: AspectRatio(
                                  aspectRatio: 1,
                                  child: AlbumArtView(
                                    resolvedAlbumArt: resolvedAlbumArt,
                                    initialImage: stateData.albumCoverArt,
                                  ),
                                ),
                                title: MarqueeText(
                                  text: Text(
                                    playerDetectedSong.songName,
                                    textScaleFactor: 1.1,
                                  ),
                                ),
                                subtitle: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MarqueeText(
                                      text: Text(
                                        "${playerDetectedSong.singerName} - ${playerDetectedSong.albumName}",
                                        textScaleFactor: 1.1,
                                      ),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
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
                                            playerData.iconFullAsset(
                                              LogoColorType.black,
                                            ),
                                            height: 18,
                                            //scale: 1.5,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 5.5,
                                          ),
                                          child: PlayingIndicator(
                                            play: stateData.state ==
                                                ActivityState.playing,
                                          ),
                                        ),
                                      ],
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
                        height: 14,
                      ),
                    ],
                  ),
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
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(kWhiteSystemUiOverlayStyle);
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(kDefaultSystemUiOverlayStyle);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return AllWhite(
      child: SizedBox.fromSize(
        size: size,
        child: PlayerNotificationListener(
          builder: (context, detectedPlayers, _) {
            return _ExtendedViewInternal(
              resolvedPlayers: detectedPlayers,
              song: widget.song,
              scrollSynchronizer: widget.scrollSynchronizer,
              size: size,
            );
          },
        ),
      ),
    );
  }
}

class _ExtendedViewInternal extends StatefulWidget {
  final Size size;
  final List<ResolvedPlayerData> resolvedPlayers;
  final SongBase? song;
  final BulkNotifier<double>? scrollSynchronizer;

  const _ExtendedViewInternal({
    // ignore: unused_element
    super.key,
    required this.resolvedPlayers,
    required this.song,
    required this.scrollSynchronizer,
    required this.size,
  });

  @override
  State<_ExtendedViewInternal> createState() => _ExtendedViewInternalState();
}

class _ExtendedViewInternalState extends State<_ExtendedViewInternal>
    with SingleTickerProviderStateMixin {
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
  static const String _synchronizerKey = "ExtendedView";
  late final PageController _pageController;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _playerIndicatorFadeAnimation;
  late bool _shouldIncludeSong;
  late int _initialPage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    );

    _playerIndicatorFadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.ease,
    );

    _initialPage = _getInitialPage();
    logExceptRelease("initial page: $_initialPage");

    _pageController = PageController(
      initialPage: _initialPage,
    );
    if (widget.scrollSynchronizer != null) {
      widget.scrollSynchronizer
          ?.addListener(_synchronizerKey, _synchronizerListener);
      _pageController.addListener(_pageControllerListener);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(
        CurrentlyPlaying.fadeRevealDelayDuration,
        () {
          _animationController.forward();
        },
      );
    });
  }

  @override
  void dispose() {
    widget.scrollSynchronizer?.removeListener(_synchronizerKey);
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_ExtendedViewInternal oldWidget) {
    super.didUpdateWidget(oldWidget);
    _pageController.removeListener(_pageControllerListener);
    oldWidget.scrollSynchronizer?.removeListener(_synchronizerKey);
    if (widget.scrollSynchronizer != null) {
      widget.scrollSynchronizer
          ?.addListener(_synchronizerKey, _synchronizerListener);
      _pageController.addListener(_pageControllerListener);
    }
    _checkShouldIncludeSong();
  }

  int _getInitialPage() {
    final SongBase? song = widget.song;

    if (song != null) {
      final int songIsAtPlayerIndex = widget.resolvedPlayers.indexWhere(
        (element) => element.playerData.state.resolvedSong == song,
      );

      final bool playingInAPlayer = songIsAtPlayerIndex != -1;

      if (playingInAPlayer) {
        logExceptRelease("Playing in a music player");
        /*widget.scrollSynchronizer
            ?.setValueForAll(songIsAtPlayerIndex.toDouble());*/
        _shouldIncludeSong = false;
        return songIsAtPlayerIndex;
      }
      _shouldIncludeSong = true;
      return 0;
    }

    _shouldIncludeSong = false;
    return widget.scrollSynchronizer?.value.toInt() ?? 0;
  }

  void _checkShouldIncludeSong() {
    final SongBase? song = widget.song;

    if (song == null) {
      _shouldIncludeSong = false;
      return;
    }

    final int songIsAtPlayerIndex = widget.resolvedPlayers.indexWhere(
      (element) => element.playerData.state.resolvedSong == song,
    );

    final bool notPlayingInAPlayer = songIsAtPlayerIndex == -1;

    _shouldIncludeSong = notPlayingInAPlayer;

    if (notPlayingInAPlayer) {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 750),
        curve: Curves.ease,
      );
    } else {
      _pageController.animateToPage(
        songIsAtPlayerIndex,
        duration: const Duration(milliseconds: 750),
        curve: Curves.ease,
      );
    }
  }

  void _pageControllerListener() {
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
    //logExceptRelease("$_synchronizerKey setting $value");
    widget.scrollSynchronizer?.setValue(_synchronizerKey, value);
  }

  void _synchronizerListener(Object? key, double value) {
    //logExceptRelease("$_synchronizerKey got $value");
    _pageController.jumpToPage(value.toInt());
  }

  final Map<String, dynamic> _miniCache = {};
  T _getCachedValue<T>(String key, T? value, T defaultValue) {
    if ((value == null) && (_miniCache[key] == null)) {
      return defaultValue;
    }

    _miniCache[key] = value;
    return value ?? defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    final List<Object> showables = [
      if (_shouldIncludeSong) widget.song!,
      ...widget.resolvedPlayers,
    ];

    if (showables.isEmpty) {
      return const SizedBox();
    }

    final List<PlayerData?> playerDataList = showables.map<PlayerData?>(
      (e) {
        if (e is ResolvedPlayerData) {
          return e.playerData;
        }
        return null;
      },
    ).toList();

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        NoOverscrollGlow(
          child: PageView.builder(
            allowImplicitScrolling: true,
            padEnds: false,
            itemCount: showables.length,
            controller: _pageController,
            itemBuilder: (context, index) {
              final Object showable = showables[index];

              late final ResolvedPlayerData? resolvedPlayer;
              late final PlayerData? playerData;
              late final PlayerStateData? stateData;
              late final SongBase? resolvedSong;
              late final SongBase? playerDetectedSong;
              late final SongBase showableSong;
              late final SongBase workableSong;

              if (showable is ResolvedPlayerData) {
                resolvedPlayer = showable;
                playerData = playerDataList[index];
                stateData = playerData?.state;
                resolvedSong = stateData?.resolvedSong;
                playerDetectedSong = stateData?.playerDetectedSong;
                showableSong = playerDetectedSong!;
                workableSong = resolvedSong ?? playerDetectedSong;
              } else if (showable is SongBase) {
                resolvedPlayer = null;
                playerData = null;
                stateData = null;
                resolvedSong = null;
                playerDetectedSong = null;
                showableSong = showable;
                workableSong = showable;
              }

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Album Art
                  AlbumArtView(
                    initialImage: stateData?.albumCoverArt,
                    resolvedAlbumArt:
                        playerData?.state.resolvedAlbumArt ?? workableSong,
                    dimValue: 0.65,
                    loadClip: true,
                  ),

                  // Top layer: Lyrics, Metadata, Controls
                  PageRevealTransition(
                    pageIndex: index,
                    pageController: _pageController,
                    initialPage: _initialPage,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Material(
                        type: MaterialType.transparency,
                        child: Column(
                          children: [
                            // Lyrics
                            Expanded(
                              child: LyricsView(
                                //playerStateData: stateData,
                                song: workableSong,
                                goWithFlow: (stateData == null) ||
                                    (stateData.state == ActivityState.playing),
                                initialImage: stateData?.albumCoverArt,
                                seekToStart: resolvedPlayer?.skipToStart,
                              ),
                            ),

                            // Metadata, controls...
                            Container(
                              width: widget.size.width,
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
                                  MarqueeText(
                                    text: Text(
                                      showableSong.songName,
                                      //playerDetectedSong?.songName,
                                      textScaleFactor: 2.25,
                                      style: GoogleFonts.volkhov(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 16,
                                  ),

                                  // Controls
                                  AnimatedShowHide(
                                    showCurve: Curves.easeIn,
                                    hideCurve: Curves.easeOutCubic,
                                    isShown: (resolvedPlayer != null) &&
                                        (stateData != null),
                                    child: ControlButtons(
                                      state: _getCachedValue<ActivityState>(
                                        "activity_state",
                                        stateData?.state,
                                        ActivityState.playing,
                                      ),
                                      onPlayPause: resolvedPlayer?.setState,
                                      onNext: resolvedPlayer?.next,
                                      onPrevious: resolvedPlayer?.previous,
                                      previousIconSize: 30,
                                      nextIconSize: 30,
                                      playPauseIconSize: 40,
                                    ),
                                    transitionBuilder:
                                        (context, animation, child) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SizeTransition(
                                          sizeFactor: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                  ),

                                  // Player state
                                  AnimatedShowHide(
                                    isShown: stateData != null,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 375,
                                        ),
                                        reverseDuration: const Duration(
                                          milliseconds: 175,
                                        ),
                                        switchInCurve: Curves.easeInCubic,
                                        switchOutCurve: Curves.easeOutCubic,
                                        child: Text(
                                          _getCachedValue<ActivityState?>(
                                                "activity_state",
                                                stateData?.state,
                                                null,
                                              )?.prettyName ??
                                              "",
                                          key: ValueKey<String>(
                                            _getCachedValue<ActivityState?>(
                                                  "activity_state",
                                                  stateData?.state,
                                                  null,
                                                )?.prettyName ??
                                                "",
                                          ),
                                        ),
                                      ),
                                    ),
                                    transitionBuilder:
                                        (context, animation, child) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                  ),

                                  // Singer name
                                  MarqueeText(
                                    text: Text(
                                      showableSong.singerName,
                                      textScaleFactor: 1.25,
                                      style: GoogleFonts.nunito(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 10,
                                  ),

                                  // Album name
                                  MarqueeText(
                                    text: Text(
                                      showableSong.albumName,
                                      textScaleFactor: 1.1,
                                      style: GoogleFonts.merriweather(
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
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
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // Player indicator
        FadeTransition(
          opacity: _playerIndicatorFadeAnimation,
          child: SizedBox(
            height: 30,
            width: widget.size.width,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Align(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: showables.length,
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
                      initialItem: _initialPage,
                      itemBuilder: (context, index) {
                        final PlayerData? playerData = playerDataList[index];
                        /*logExceptRelease(
                                  "Building logo: ${playerData.iconFullAssetName}",
                                );*/

                        if (playerData == null) {
                          return empty;
                        }

                        final String logoAssetName =
                            playerData.iconFullAsset(LogoColorType.white);
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Tooltip(
                              key: ValueKey<String>(
                                logoAssetName,
                              ),
                              message:
                                  "${"Open".tr()} ${playerData.playerName}",
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
                                  opacity: const AlwaysStoppedAnimation<double>(
                                    0.85,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: PlayingIndicator(
                                play: playerData.state.state ==
                                    ActivityState.playing,
                              ),
                            )
                          ],
                        );
                      },
                      itemCount: playerDataList.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
