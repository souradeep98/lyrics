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
  static Future<String> getFilePathFor(SongBase playerDetectedSong) async {
    if (!isInitialized) {
      await initialize();
    }

    final String fileName = playerDetectedSong.albumArtFileName();

    final String filePath = join(_temporaryDirectory!, "$fileName.jpg");

    return filePath;
  }

  @pragma("vm:entry-point")
  static Future<File> getSupposedFileFor(SongBase playerDetectedSong) async {
    final String filePath = await getFilePathFor(playerDetectedSong);
    return File(filePath);
  }

  @pragma("vm:entry-point")
  static Future<String> getCachedFilePathFor(PlayerData playerData) async {
    final SongBase song =
        playerData.state.resolvedSong ?? playerData.state.playerDetectedSong;

    final String filePath = await getFilePathFor(song);

    final File file = File(filePath);

    if (await file.exists()) {
      return filePath;
    } else {
      final Uint8List imageData = (await DatabaseHelper.getAlbumArtFor(song)) ??
          playerData.state.albumCoverArt;

      final List<int> jpegImage = await convertToJpeg(imageData);

      await setCacheDataFor(
        song,
        Uint8List.fromList(jpegImage),
      );
    }

    return filePath;
  }

  @pragma("vm:entry-point")
  static Future<void> deleteCachedFileFor(SongBase playerDetectedSong) async {
    final String filePath = await getFilePathFor(playerDetectedSong);

    final File file = File(filePath);

    try {
      await file.delete();
    } catch (_) {
      logExceptRelease("Could not delete cache for $filePath");
    }
  }

  @pragma("vm:entry-point")
  static Future<Uint8List?> getCachedDataFor(SongBase song) async {
    final String filePath = await getFilePathFor(song);

    final File file = File(filePath);

    if (await file.exists()) {
      return file.readAsBytes();
    }

    return null;
  }

  @pragma("vm:entry-point")
  static Future<void> setCacheDataFor(
    SongBase song,
    Uint8List data, {
    bool isJpeg = true,
    DateTime? currentTime,
  }) async {
    final String filePath = await getFilePathFor(song);

    final File file = File(filePath);

    //currentTime ??= await getUTCDateTimeFromServer();

    await file.writeAsBytes(isJpeg ? data : await convertToJpeg(data));

    if (currentTime != null) {
      await file.setLastModified(currentTime);
    }
  }

  /*@pragma("vm:entry-point")
  static Future<List<int>> _convertToJpeg(List<int> imageData) async {
    final List<int> result = await compute<List<int>, List<int>>(
      (imageData) {
        final Image? image = decodeImage(imageData);
        if (image == null) {
          throw "Could not decode image";
        }
        final List<int> jpegImage = encodeJpg(image);

        return jpegImage;
      },
      imageData,
    );

    return result;
  }*/

  @pragma("vm:entry-point")
  static Future<DateTime?> getDateTimeOfCaching(SongBase song) async {
    final String filePath = await getFilePathFor(song);

    final File file = File(filePath);

    if (await file.exists()) {
      return file.lastModified();
    }

    return null;
  }
}
