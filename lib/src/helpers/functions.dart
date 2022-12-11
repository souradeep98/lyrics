part of helpers;

Future<T?> navigateToPagePush<T>(
  Widget page, {
  RouteSettings? settings,
  bool maintainState = true,
  bool fullscreenDialog = false,
}) async {
  return GKeys.navigatorKey.currentState?.push<T>(
    MaterialPageRoute(
      builder: (context) => page,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
    ),
  );
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showTextSnack(
  String text, {
  SnackBarAction? action,
}) {
  return GKeys.scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Text(text),
      action: action,
    ),
  );
}

Future<void> addOrEditLyrics({
  required PlayerStateData playerStateData,
  required List<LyricsLine>? lyrics,
  AsyncVoidCallback? seekToStart,
}) async {
  await showSongDetailsForm(
    playerStateData: playerStateData,
    onSave: (songDetails) async {
      if (songDetails == null) {
        return;
      }

      await showLyricsForm(
        playerStateData: playerStateData,
        lyrics: lyrics,
        onSave: (_, x) async {
          if (x == null) {
            return;
          }

          await showLyricsSynchronizationPage(
            playerStateData: playerStateData,
            lines: x,
            seekToStart: seekToStart,
            onSave: (playerState, x) async {
              if (x == null) {
                return;
              }

              if ((lyrics != null) &&
                  (songDetails != playerState.resolvedSong)) {
                await DatabaseHelper.deleteLyricsFor(playerState.resolvedSong!);
              }

              await DatabaseHelper.putLyricsFor(
                songDetails,
                x,
              );
              GKeys.navigatorKey.currentState?.popUntil(
                (route) => route.isFirst,
              );
              return null;
            },
          );
          return null;
        },
        //albumArt: song.albumCoverArt,
      );
    },
  );
}

Future<void> addAlbumArt(SongBase song) async {
  final FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result == null) {
    return;
  }

  final File file = File(result.files.single.path!);

  final Uint8List albumArt = await file.readAsBytes();

  await DatabaseHelper.putAlbumArtFor(song, albumArt);
}

@pragma("vm:entry-point")
Future<bool> get _shouldRequestNotificationPermission async {
  return isSupportedNotificationListening &&
      !((await NotificationsListener.hasPermission) ?? false) &&
      !SharedPreferencesHelper.isNotificationPermissionDenied();
}

@pragma("vm:entry-point")
bool _isInitialized = false;

@pragma("vm:entry-point")
Future<void> initializeControllers() async {
  if (_isInitialized) {
    return;
  }
  _isInitialized = true;

  await SharedPreferencesHelper.initialize();

  if (await _shouldRequestNotificationPermission) {
    final BuildContext? context = GKeys.navigatorKey.currentContext;
    if (context != null) {
      // ignore: use_build_context_synchronously
      await showPermissionRequest(context);
    }
  }

  await NotificationManagementHelper.initialize();

  final bool hasNotificationPermission =
      await NotificationManagementHelper.hasPermission();

  if (!hasNotificationPermission) {
    final BuildContext? context = GKeys.navigatorKey.currentContext;
    if (context != null) {
      await NotificationManagementHelper.requestPermission();
    }
  }

  await Future.wait([
    NotificationListenerHelper.initialize(),
    DatabaseHelper.initialize(OfflineDatabase()),
  ]);
}
