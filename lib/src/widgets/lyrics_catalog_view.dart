part of widgets;

class LyricsCatalogView extends StatefulWidget {
  // ignore: unused_element
  const LyricsCatalogView({super.key});

  @override
  State<LyricsCatalogView> createState() => _LyricsCatalogViewState();
}

class _LyricsCatalogViewState extends State<LyricsCatalogView> {
  late StreamDataObservable<List<SongBase>> _songs;

  @override
  void initState() {
    super.initState();
    _songs = StreamDataObservable<List<SongBase>>(
      stream: DatabaseHelper.getAllSongsStream(),
    ).put<StreamDataObservable<List<SongBase>>>(tag: "All_Songs");
  }

  @override
  Widget build(BuildContext context) {
    return StreamDataObserver<StreamDataObservable<List<SongBase>>>(
      observable: _songs,
      builder: (x) {
        final List<SongBase> songs = x.data!;
        return ListView.separated(
          itemBuilder: (context, index) {
            //logExceptRelease("Building item: $index");
            final SongBase song = songs[index];
            final Widget miniView = _ItemMiniView(
              song: song,
              key: ValueKey<SongBase>(song),
            );
            final Widget extendedView = _CurrentlyPlayingExpandedView(
              song: song,
              key: ValueKey<SongBase>(song),
            );
            return OpenContainer(
              key: ValueKey<SongBase>(song),
              closedBuilder: (context, action) => miniView,
              openBuilder: (context, action) => extendedView,
              closedShape: const RoundedRectangleBorder(),
              transitionType: ContainerTransitionType.fadeThrough,
              transitionDuration: const Duration(milliseconds: 450),
              closedElevation: 0,
            );
          },
          separatorBuilder: (context, index) => const Divider(
            height: 0.5,
          ),
          itemCount: songs.length,
        );
      },
      dataIsEmpty: (x) {
        ///return true;
        return x.data?.isEmpty ?? true;
      },
      emptyWidgetBuilder: (_) => const AppEmptyWidget(),
      loadingIndicator: const AppLoadingIndicator(),
    );
  }
}

class AppEmptyWidget extends StatelessWidget {
  const AppEmptyWidget({
    // ignore: unused_element
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const Widget musicNote = Icon(
      Icons.music_note,
      size: 26,
    );
    return ColoredBox(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Align(
                    alignment: const Alignment(0.35, 0.3),
                    child: Transform.scale(
                      scale: 0.52,
                      child: Transform.rotate(
                        angle: pi / 12,
                        child: musicNote,
                      ),
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0.22, 0.71),
                    child: Transform.scale(
                      scale: 0.65,
                      child: Transform.rotate(
                        angle: 12,
                        child: musicNote,
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: musicNote,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Text("${'No lyrics for any songs were added'.tr()}..."),
            ),
          ],
        ),
      ),
    );
  }
}

class AppLoadingIndicator extends StatefulWidget {
  final bool animate;
  const AppLoadingIndicator({
    // ignore: unused_element
    super.key,
    // ignore: unused_element
    this.animate = true,
  });

  @override
  State<AppLoadingIndicator> createState() => _AppLoadingIndicatorState();
}

class _AppLoadingIndicatorState extends State<AppLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _firstChildAnimation;
  late final Animation<double> _secondChildAnimation;
  late final Animation<double> _thirdChildAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
      reverseDuration: const Duration(milliseconds: 125),
      value: widget.animate ? null : 1,
    );

    _firstChildAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.5,
        0.8,
        curve: Curves.easeIn,
      ),
      reverseCurve: Curves.easeIn,
    );
    _secondChildAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.3,
        0.6,
        curve: Curves.easeIn,
      ),
      reverseCurve: Curves.easeIn,
    );
    _thirdChildAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.2,
        0.5,
        curve: Curves.easeIn,
      ),
      reverseCurve: Curves.easeIn,
    );

    if (widget.animate) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _play();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AppLoadingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && (!oldWidget.animate)) {
      _play();
    }
  }

  Future<void> _play() async {
    while (widget.animate) {
      await _animationController.forward();
      await _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    const Widget musicNote = Icon(
      Icons.music_note,
      size: 26,
    );
    return ColoredBox(
      color: Colors.white,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: const Alignment(0.25, -0.2),
            child: FadeTransition(
              opacity: _firstChildAnimation,
              child: Transform.scale(
                scale: 0.55,
                child: Transform.rotate(
                  angle: pi / 12,
                  child: musicNote,
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0.08, -0.1),
            child: FadeTransition(
              opacity: _secondChildAnimation,
              child: Transform.scale(
                scale: 0.72,
                child: Transform.rotate(
                  angle: 12,
                  child: musicNote,
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(-0.1, 0),
            child: FadeTransition(
              opacity: _thirdChildAnimation,
              child: musicNote,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemMiniView extends StatelessWidget {
  final SongBase song;

  const _ItemMiniView({
    // ignore: unused_element
    super.key,
    required this.song,
  });

  Future<void> _onDelete(BuildContext context) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Are you sure?"),
        actions: [
          IconButton(
            onPressed: Navigator.of(context).pop,
            icon: const Icon(Icons.close_rounded),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            icon: const Icon(Icons.done),
          ),
        ],
      ),
    );
    if (result ?? false) {
      await DatabaseHelper.deleteLyricsFor(song);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Widget separator = SizedBox(
      width: 6,
    );
    return PlayerNotificationListener(
      builder: (context, players, _) {
        final List<ResolvedPlayerData> openInPlayers = players
            .where((element) => element.playerData.state.resolvedSong == song)
            .toList();

        //logExceptRelease(openInPlayers.map((e) => e.player.playerName));

        final bool isPlaying = openInPlayers.any(
          (element) => element.playerData.state.state == ActivityState.playing,
        );

        return ListTile(
          trailing: IconButton(
            onPressed: () async {
              await _onDelete(context);
            },
            icon: const Icon(Icons.more_vert_rounded),
          ),
          leading: AspectRatio(
            aspectRatio: 1,
            child: AlbumArtView(
              resolvedAlbumArt: song,
            ),
          ),
          title: Text(song.songName),
          subtitle: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (openInPlayers.isEmpty)
                Text("${song.singerName} - ${song.albumName}")
              else
                Marquee(
                  animationDuration: const Duration(seconds: 3),
                  backDuration: const Duration(milliseconds: 30),
                  child: Text(
                    "${song.singerName} - ${song.albumName}",
                  ),
                ),
              AnimatedShowHide(
                isShown: openInPlayers.isNotEmpty,
                showDuration: const Duration(milliseconds: 350),
                hideDuration: const Duration(milliseconds: 350),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3.0),
                      child: PlayingIndicator(
                        play: isPlaying,
                      ),
                      /*child: _PlayingPlayerIndicator(
                        isPlaying: isPlaying,
                        builder: (context, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: PlayingIndicator(
                              play: isPlaying,
                            ),
                          );
                        },
                      ),*/
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: NoOverscrollGlow(
                        child: SizedBox(
                          height: 18,
                          child: ListView.separated(
                            itemBuilder: (context, index) {
                              final PlayerData playerData =
                                  openInPlayers[index].playerData;
                              return _PlayingPlayerIndicator(
                                builder: (context, animation) {
                                  return Image.asset(
                                    playerData.iconAsset(LogoColorType.black),
                                    height: 18,
                                    //scale: 1.5,
                                    opacity: animation,
                                  );
                                },
                                isPlaying: playerData.state.state ==
                                    ActivityState.playing,
                              );
                            },
                            separatorBuilder: (context, index) => separator,
                            itemCount: openInPlayers.length,
                            scrollDirection: Axis.horizontal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                transitionBuilder: (context, animation, child) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: const Interval(0.5, 1),
                    ),
                    child: SizeTransition(
                      sizeFactor: animation,
                      child: child,
                    ),
                  );
                },
              ),
            ],
          ),
          selected: isPlaying,
        );
      },
    );
  }
}

class _PlayingPlayerIndicator extends StatefulWidget {
  final Widget Function(BuildContext context, Animation<double> animation)
      builder;
  final Duration? revealDuration;
  final Duration? deemDuration;
  final Curve revealCurve;
  final Curve deemCurve;
  final bool isPlaying;
  final double maxVisibility;
  final double minVisibility;

  const _PlayingPlayerIndicator({
    // ignore: unused_element
    super.key,
    required this.builder,
    required this.isPlaying,
    // ignore: unused_element
    this.revealDuration,
    // ignore: unused_element
    this.deemDuration,
    // ignore: unused_element
    this.revealCurve = Curves.ease,
    // ignore: unused_element
    this.deemCurve = Curves.ease,
    // ignore: unused_element
    this.minVisibility = 0.3,
    // ignore: unused_element
    this.maxVisibility = 1,
  });

  @override
  State<_PlayingPlayerIndicator> createState() =>
      _PlayingPlayerIndicatorState();
}

class _PlayingPlayerIndicatorState extends State<_PlayingPlayerIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.revealDuration ?? const Duration(milliseconds: 785),
      reverseDuration: widget.deemDuration ?? const Duration(milliseconds: 785),
      value: widget.isPlaying ? widget.maxVisibility : widget.minVisibility,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_PlayingPlayerIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _animationController.animateTo(
          widget.maxVisibility,
          curve: widget.revealCurve,
        );
      } else {
        _animationController.animateBack(
          widget.minVisibility,
          curve: widget.revealCurve,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _animationController,
    );
  }
}

