part of controllers;

abstract class AlbumArtCache {
  @pragma("vm:entry-point")
  static String? _temporaryDirectory;

  @pragma("vm:entry-point")
  static bool get isInitialized => _temporaryDirectory != null;

  @pragma("vm:entry-point")
  static Future<void> initialize() async {
    _temporaryDirectory = (await getTemporaryDirectory()).path;
  }

  @pragma("vm:entry-point")
  static Future<String> getCachedFilePathFor(PlayerData playerData) async {
    if (!isInitialized) {
      await initialize();
    }

    final Completer<String> resultCompleter = Completer<String>();

    final String fileName = playerData.state.playerDetectedSong.fileName();

    final String filePath = join(_temporaryDirectory!, "$fileName.jpg");

    final File file = File(filePath);

    if (await file.exists()) {
      resultCompleter.complete(filePath);
    } else {
      final SongBase song = playerData.state.playerDetectedSong;

      final Uint8List imageData = (await DatabaseHelper.getAlbumArtFor(song)) ??
          playerData.state.albumCoverArt;

      late final Isolate isolate;

      isolate = await Isolate.spawn<Uint8List>(
        (data) async {
          final Image? image = decodeImage(data);
          if (image == null) {
            resultCompleter.completeError("Could not decode image");
            return;
          }

          final List<int> jpegImage = encodeJpg(image);

          await file.writeAsBytes(jpegImage);

          resultCompleter.complete(filePath);

          isolate.kill();
        },
        imageData,
      );
    }

    return resultCompleter.future;
  }

  @pragma("vm:entry-point")
  static Future<void> deleteCachedFileFor(SongBase playerDetectedSong) async {
    if (!isInitialized) {
      await initialize();
    }

    final String fileName = playerDetectedSong.fileName();

    final String filePath = join(_temporaryDirectory!, "$fileName.jpg");

    final File file = File(filePath);

    try {
      await file.delete();
    } catch (_) {
      logExceptRelease("Could not delete cache for $fileName");
    }
  }

  /*static Future<Uint8List> getCachedDataFor(SongBase song) async {
    if (!isInitialized) {
      await initialize();
    }


  }*/
}
