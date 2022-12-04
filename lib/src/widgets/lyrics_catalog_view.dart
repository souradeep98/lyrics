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
        //emptyMessage: "No lyrics for any songs were added...",
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
    return PlayerNotificationListener(
      builder: (context, players, _) {
        late final ResolvedPlayerData? detectedPlayer;
        //late final String? assetName;
        late final PlayerData? playerData;
        try {
          detectedPlayer = players.firstWhere(
            (element) => element.playerData.state.resolvedSong == song,
          );
          playerData = detectedPlayer.playerData;
          //assetName = playerData.iconFullAssetName;
        } catch (_) {
          detectedPlayer = null;
          //assetName = null;
          playerData = null;
        }
        final bool isSelected = detectedPlayer != null;

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
          //subtitle: Text("${song.singerName} - ${song.albumName}"),
          subtitle: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: playerData != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Marquee(
                        animationDuration: const Duration(seconds: 3),
                        backDuration: const Duration(milliseconds: 30),
                        child: Text(
                          "${song.singerName} - ${song.albumName}",
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            playerData.iconFullAsset(LogoColorType.black),
                            height: 18,
                            //scale: 1.5,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: PlayingIndicator(
                              play: playerData.state.state ==
                                  ActivityState.playing,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Text(
                    "${song.singerName} - ${song.albumName}",
                  ),
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.centerLeft,
                children: <Widget>[
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
          ),
          selected: isSelected,
        );
      },
    );
  }
}
