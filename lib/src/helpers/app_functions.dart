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
      content: Text(
        text,
      ),
      action: action,
    ),
  );
}

Future<void> addOrEditLyrics({
  //required PlayerStateData playerStateData,
  required SongBase? song,
  required Uint8List? initialImage,
  required List<LyricsLine>? lyrics,
  AsyncVoidCallback? seekToStart,
}) async {
  await GKeys.navigatorKey.currentState?.push(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 550),
      reverseTransitionDuration: const Duration(milliseconds: 450),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeScaleTransition(
          animation: animation,
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return SongDetailsForm(
          initialData: song,
          onSave: (songDetails) async {
            if (songDetails == null) {
              return;
            }

            await GKeys.navigatorKey.currentState?.push(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 550),
                reverseTransitionDuration: const Duration(milliseconds: 450),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SharedAxisTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.horizontal,
                    fillColor: Colors.transparent,
                    child: child,
                  );
                },
                pageBuilder: (context, animation, secondaryAnimation) {
                  return LyricsForm(
                    lyrics: lyrics,
                    initialAlbumArt: initialImage,
                    song: songDetails,
                    onSave: (lines) async {
                      if (lines == null) {
                        return;
                      }

                      await GKeys.navigatorKey.currentState?.push(
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 550),
                          reverseTransitionDuration:
                              const Duration(milliseconds: 450),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return SharedAxisTransition(
                              animation: animation,
                              secondaryAnimation: secondaryAnimation,
                              transitionType:
                                  SharedAxisTransitionType.horizontal,
                              fillColor: Colors.transparent,
                              child: child,
                            );
                          },
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                            return LyricsSynchronization(
                              lines: lines,
                              initialAlbumArt: initialImage,
                              song: songDetails,
                              seekToStart: seekToStart,
                              onSave: (newLyrics) async {
                                if (newLyrics == null) {
                                  return;
                                }

                                if ((lyrics != null) && (songDetails != song)) {
                                  await DatabaseHelper.deleteLyricsFor(song!);
                                }

                                await DatabaseHelper.putLyricsFor(
                                  songDetails,
                                  newLyrics,
                                );
                                GKeys.navigatorKey.currentState?.popUntil(
                                  (route) => route.isFirst,
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    ),
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

  await AppCache.initialize();

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

@pragma("vm:entry-point")
Future<void> onAppLifeCycleStateChange({required bool isForeground}) async {
  if (isForeground) {
    await NotificationManagementHelper
        .removeAllMusicActivityActiveNotification();
  } else {
    await NotificationListenerHelper.showPlayingNotifications();
  }
}
