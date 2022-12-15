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

    final SongBase song =
        playerData.state.resolvedSong ?? playerData.state.playerDetectedSong;

    final String fileName = song.fileName();

    final String filePath = join(_temporaryDirectory!, "$fileName.jpg");

    final File file = File(filePath);

    if (await file.exists()) {
      return filePath;
    } else {
      final Uint8List imageData = (await DatabaseHelper.getAlbumArtFor(song)) ??
          playerData.state.albumCoverArt;

      final List<int> jpegImage = await _convertToJpeg(imageData);

      await setCacheDataFor(
        song,
        Uint8List.fromList(jpegImage),
      );
    }

    return filePath;
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

  @pragma("vm:entry-point")
  static Future<Uint8List?> getCachedDataFor(SongBase song) async {
    if (!isInitialized) {
      await initialize();
    }

    final String fileName = song.fileName();

    final String filePath = join(_temporaryDirectory!, "$fileName.jpg");

    final File file = File(filePath);

    if (await file.exists()) {
      return file.readAsBytes();
    }

    return null;
  }

  @pragma("vm:entry-point")
  static Future<void> setCacheDataFor(SongBase song, Uint8List data, {DateTime? currentTime}) async {
    if (!isInitialized) {
      await initialize();
    }

    final String fileName = song.fileName();

    final String filePath = join(_temporaryDirectory!, "$fileName.jpg");

    final File file = File(filePath);

    final List<int> jpegImage = await _convertToJpeg(data);

    currentTime ??= await getUTCDateTimeFromServer();

    await file.writeAsBytes(jpegImage);
    await file.setLastModified(currentTime);
  }

  @pragma("vm:entry-point")
  static Future<List<int>> _convertToJpeg(List<int> imageData) async {
    final Completer<List<int>> resultCompleter = Completer<List<int>>();

    late final Isolate isolate;

    isolate = await Isolate.spawn<List<int>>(
      (data) async {
        final Image? image = decodeImage(data);
        if (image == null) {
          resultCompleter.completeError("Could not decode image");
          return;
        }

        final List<int> jpegImage = encodeJpg(image);

        resultCompleter.complete(jpegImage);

        isolate.kill();
      },
      imageData,
    );

    return resultCompleter.future;
  }

  @pragma("vm:entry-point")
  static Future<DateTime?> getDateTimeOfCaching(SongBase song) async {
    if (!isInitialized) {
      await initialize();
    }

    final String fileName = song.fileName();

    final String filePath = join(_temporaryDirectory!, "$fileName.jpg");

    final File file = File(filePath);

    if (await file.exists()) {
      return file.lastModified();
    }

    return null;
  }
}
