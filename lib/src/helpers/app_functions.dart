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
  required SongBase? initialSong,
  required Uint8List? initialImage,
  required List<LyricsLine>? initialLyrics,
  AsyncVoidCallback? seekToStart,
}) async {
  await GKeys.navigatorKey.currentState?.push(
    PageTransitions.fadeScale(
      pageBuilder: (context, animation, secondaryAnimation) {
        //! Song Details Form
        return SongDetailsForm(
          initialAlbumArt: initialImage,
          initialData: initialSong,
          onSave: (newSongDetails) async {
            if (newSongDetails == null) {
              return;
            }

            if ((initialSong != null) &&
                (newSongDetails != initialSong) &&
                (initialLyrics != null)) {
              await DatabaseHelper.editSongDetailsFor(
                initialSong,
                newSongDetails,
              );
            }

            await GKeys.navigatorKey.currentState?.push(
              PageTransitions.sharedAxis(
                fillColor: Colors.transparent,
                pageBuilder: (context, animation, secondaryAnimation) {
                  //! Lyrics Form
                  return LyricsForm(
                    lyrics: initialLyrics,
                    initialAlbumArt: initialImage,
                    song: newSongDetails,
                    onSave: (newLines) async {
                      if (newLines == null) {
                        return;
                      }

                      logExceptRelease(
                        "InitialLyricsLength: ${initialLyrics?.length}, newLyricsLength: ${newLines.length}",
                        name: "addOrEditLyrics()",
                      );

                      if ((initialLyrics != null) &&
                          (initialLyrics.length == newLines.length) &&
                          !listEquals<String>(
                            initialLyrics.map((e) => e.line).toList(),
                            newLines,
                          )) {
                        final List<LyricsLine> newLyrics = [
                          for (int i = 0; i < initialLyrics.length; ++i)
                            initialLyrics[i].copyWith(line: newLines[i]),
                        ];
                        await DatabaseHelper.putLyricsFor(
                          newSongDetails,
                          newLyrics,
                        );
                      }

                      await GKeys.navigatorKey.currentState?.push(
                        PageTransitions.sharedAxis(
                          fillColor: Colors.transparent,
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                            //! Lyrics Synchronization
                            return LyricsSynchronization(
                              lines: newLines,
                              initialAlbumArt: initialImage,
                              song: newSongDetails,
                              seekToStart: seekToStart,
                              onSave: (newLyrics) async {
                                if (newLyrics == null) {
                                  return;
                                }

                                /*if ((lyrics != null) && (songDetails != song)) {
                                  await DatabaseHelper.deleteLyricsFor(song!);
                                }*/

                                await DatabaseHelper.putLyricsFor(
                                  newSongDetails,
                                  newLyrics,
                                );

                                await GKeys.navigatorKey.currentState?.push(
                                  PageTransitions.sharedAxis(
                                    fillColor: Colors.transparent,
                                    pageBuilder: (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                    ) {
                                      //! Album Art and Clip Form
                                      return AlbumArtAndClipForm(
                                        initialAlbumArt: initialImage,
                                        song: newSongDetails,
                                        onContinue: () {
                                          GKeys.navigatorKey.currentState
                                              ?.popUntil(
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
          },
        );
      },
    ),
  );
}

Future<void> addOrEditAlbumArtOrClip({
  required SongBase song,
  required Uint8List? initialImage,
}) async {
  await GKeys.navigatorKey.currentState?.push(
    PageTransitions.fadeScale(
      pageBuilder: (context, animation, secondaryAnimation) {
        return AlbumArtAndClipForm(
          song: song,
          initialAlbumArt: initialImage,
          onContinue: () {
            GKeys.navigatorKey.currentState?.pop();
          },
        );
      },
    ),
  );
}

Future<void> addAlbumArt(SongBase song) async {
  final FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.image,
  );

  if (result == null) {
    return;
  }

  final File file = File(result.files.single.path!);

  final Uint8List albumArt = await file.readAsBytes();

  await DatabaseHelper.putAlbumArtFor(song, albumArt);
}

Future<void> addClip(SongBase song) async {
  final FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.video,
  );

  if (result == null) {
    return;
  }

  final File file = File(result.files.single.path!);

  await DatabaseHelper.putClipFor(song, file);
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
Future<void> initializeControllers({
  String? callerRouteName,
}) async {
  if (_isInitialized) {
    return;
  }
  _isInitialized = true;

  await SharedPreferencesHelper.initialize();

  if (await _shouldRequestNotificationPermission) {
    final BuildContext? context = GKeys.navigatorKey.currentContext;
    if (context != null) {
      // ignore: use_build_context_synchronously
      await showPermissionRequestDialog(
        context,
        callerRouteName: callerRouteName,
      );
    }
  }

  await AlbumArtCache.initialize();

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

@pragma("vm:entry-point")
String? getTranslationLanguage() {
  final String key = SharedPreferencesHelper.keys.lyricsTranslationLanguage;
  final String? translationLanguage =
      SharedPreferencesHelper.getValue<String>(key);
  // GKeys.navigatorKey.currentContext?.locale

  if (translationLanguage == null) {
    return null;
  }

  if (translationLanguage == "device") {
    return Platform.localeName.split("_").first;
  }

  return translationLanguage;
}
