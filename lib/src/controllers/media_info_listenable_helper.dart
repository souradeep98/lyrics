part of '../controllers.dart';

abstract final class MediaInfoListenableHelper {
  @pragma("vm:entry-point")
  static final MapValueNotifier<String, ResolvedPlayerData> _values =
      MapValueNotifier<String, ResolvedPlayerData>({});

  @pragma("vm:entry-point")
  static Map<String, ResolvedPlayerData> get sessions => _values.value;

  @pragma("vm:entry-point")
  static StreamSubscription<List<ResolvedPlayerData>>? _streamSubscription;

  @pragma("vm:entry-point")
  static final Stream<List<ResolvedPlayerData>> _stream = PlatformChannelManager
      .mediaSessions
      .getMediaSessionsStream()
      .cast<List>()
      .map<List<DetectedPlayerData>>((event) {
    final List<DetectedPlayerData?> detectedPlayerData =
        event.map<DetectedPlayerData?>(
      (e) {
        //logExceptRelease(event);
        final Map<String, dynamic> map =
            (e as Map<Object?, Object?>).cast<String, dynamic>();

        final RecognisedPlayer? player =
            RecognisedPlayers.getPlayer(map["packageName"] as String);

        if (player == null) {
          return null;
        }

        return DetectedPlayerData(
          player: player,
          mediaInfo: PlayerMediaInfo.fromMap(
            map,
            songBaseGetterFromMap: player.songBaseGetterFromMap,
          ),
        );
      },
    ).toList();

    final List<DetectedPlayerData> result = detectedPlayerData
        .where((element) => element != null)
        .cast<DetectedPlayerData>()
        .toList();

    logExceptRelease(result);

    return result;
  }).asyncMap<List<ResolvedPlayerData>>((event) {
    return Future.wait<ResolvedPlayerData>(
      event.map<Future<ResolvedPlayerData>>((e) => e.resolve()).toList(),
    );
  });

  @pragma("vm:entry-point")
  static Future<void> initialize() async {
    logExceptRelease("Initializing MediaInfoListenableHelper");
    await PlatformChannelManager.mediaSessions.initialize(
      dartSideInitializerCallback: initializeControllers,
    );

    _streamSubscription = _stream.listen(_listener);
  }

  @pragma("vm:entry-point")
  static FutureOr<void> _listener(List<ResolvedPlayerData>? event) async {
    logExceptRelease(
      "MediaInfo Listener called, isNullEvent: ${event == null}",
    );
    //await initializeControllers();

    final List<ResolvedPlayerData> sessions = event ?? [];

    /*final List<DetectedPlayerData> detectedPlayerData = sessions
        .map<DetectedPlayerData?>(
          (e) {
            final Map<String, dynamic> map = e as Map<String, dynamic>;

            final RecognisedPlayer? player =
                RecognisedPlayers.getPlayer(map["packageName"] as String);

            if (player == null) {
              return null;
            }

            return DetectedPlayerData(
              player: player,
              mediaInfo: PlayerMediaInfo.fromMap(map),
            );
          },
        )
        .where((element) => element != null)
        .cast<DetectedPlayerData>()
        .toList();

    final List<ResolvedPlayerData> resolvedPlayers =
        await Future.wait<ResolvedPlayerData>(
      detectedPlayerData
          .map<Future<ResolvedPlayerData>>((e) => e.resolve())
          .toList(),
    );*/

    _values.value = Map<String, ResolvedPlayerData>.fromEntries(
      sessions.map(
        (e) => MapEntry<String, ResolvedPlayerData>(e.player.packageName, e),
      ),
    );
  }

  @pragma("vm:entry-point")
  static void addListener(VoidCallback listener) {
    _values.addListener(listener);
  }

  @pragma("vm:entry-point")
  static void removeListener(VoidCallback listener) {
    _values.removeListener(listener);
  }
}
