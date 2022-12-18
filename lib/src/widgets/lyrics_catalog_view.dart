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
    return SafeArea(
      child: StreamDataObserver<StreamDataObservable<List<SongBase>>>(
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
                closedElevation: 0.3,
              );
            },
            separatorBuilder: (context, index) => const Divider(
              height: 0.5,
            ),
            itemCount: songs.length,
          );
        },
        dataIsEmpty: (x) {
          return x.data?.isEmpty ?? true;
        },
        emptyWidgetBuilder: (x) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.music_note),
                SizedBox(
                  height: 10,
                ),
                Text("No lyrics for any songs were added..."),
              ],
            ),
          );
        },
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
              if (await showConfirmationDialog(context)) {
                await DatabaseHelper.deleteLyricsFor(song);
              }
            },
            icon: const Icon(Icons.delete),
          ),
          leading: AspectRatio(
            aspectRatio: 1,
            child: AlbumArtView(
              resolvedSongBase: song,
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
                    opacity: animation,
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
      reverseDuration: widget.deemDuration ?? const Duration(milliseconds: 285),
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
