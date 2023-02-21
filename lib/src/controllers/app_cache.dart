part of controllers;

abstract class AlbumArtCache {
  @pragma("vm:entry-point")
  static String? _temporaryDirectory;

  @pragma("vm:entry-point")
  static String? _supportDirectory;

  @pragma("vm:entry-point")
  static LazyBox<String>? _entryDatabase;

  @pragma("vm:entry-point")
  static bool get isInitialized =>
      (_temporaryDirectory != null) &&
      (_supportDirectory != null) &&
      (_entryDatabase != null);

  @pragma("vm:entry-point")
  static Future<void> initialize() async {
    if (isInitialized) {
      return;
    }

    _temporaryDirectory =
        join((await getTemporaryDirectory()).path, "albumArtCache");
    _supportDirectory =
        join((await getApplicationSupportDirectory()).path, "albumArtCache");
    await initializeHive();
    _entryDatabase = await Hive.openLazyBox("albumArtCache");
  }

  /*@pragma("vm:entry-point")
  static Future<String> getFilePathFor(
    SongBase playerDetectedSong, {
    String extension = "jpg",
  }) async {
    if (!isInitialized) {
      await initialize();
    }

    final String fileName = playerDetectedSong.albumArtFileName();

    final String filePath = join(_temporaryDirectory!, "$fileName.$extension");

    return filePath;
  }

  @pragma("vm:entry-point")
  static Future<File> getSupposedFileFor(
    SongBase playerDetectedSong, {
    String extension = "jpg",
  }) async {
    final String filePath = await getFilePathFor(
      playerDetectedSong,
      extension: extension,
    );
    return File(filePath);
  }*/

  @pragma("vm:entry-point")
  static Future<String?> getCachedAlbumArtFilePathForPlayerData(
    PlayerData playerData, {
    bool setIfAbsent = true,
  }) async {
    /*final SongBase song =
        playerData.state.resolvedSong ?? playerData.state.playerDetectedSong;

    final String? filePath =
        await _getCachedAlbumArtFilePathIfAvailableFor(song);

    if (!setIfAbsent) {
      return filePath;
    }

    if ((filePath != null) && (await File(filePath).exists())) {
      return filePath;
    }

    final Uint8List imageData = (await DatabaseHelper.getAlbumArtFor(song)) ??
        playerData.state.albumCoverArt;

    final String result = await setAlbumArtCacheDataFor(
      song,
      imageData,
    );

    return result;*/
    final SongBase song =
        playerData.state.resolvedSong ?? playerData.state.playerDetectedSong;
    final Uint8List? dbImageData = await DatabaseHelper.getAlbumArtFor(song);
    final Uint8List imageData = dbImageData ??
        playerData.state.albumCoverArt;

    return _getCachedAlbumArtFilePathInternal(
      songBase: song,
      dataToPutIfAbsent: imageData,
      setToTemporary: dbImageData == null,
    );
  }

  @pragma("vm:entry-point")
  static Future<String?> getCachedAlbumArtFilePathForSongBase(
    SongBase songBase, {
    bool tryToSetIfAbsent = false,
  }) async {
    /*final String? filePath =
        await _getCachedAlbumArtFilePathIfAvailableFor(songBase);

    if (!tryToSetIfAbsent) {
      return filePath;
    }

    if ((filePath != null) && (await File(filePath).exists())) {
      return filePath;
    }

    final Uint8List? imageData = await DatabaseHelper.getAlbumArtFor(songBase);

    if (imageData == null) {
      return null;
    }

    final String result = await setAlbumArtCacheDataFor(
      songBase,
      imageData,
    );

    return result;*/

    final Uint8List? imageData = await DatabaseHelper.getAlbumArtFor(songBase);

    return _getCachedAlbumArtFilePathInternal(
      songBase: songBase,
      dataToPutIfAbsent: imageData,
      setToTemporary: false,
    );
  }

  @pragma("vm:entry-point")
  static Future<String?> _getCachedAlbumArtFilePathInternal({
    required SongBase songBase,
    Uint8List? dataToPutIfAbsent,
    bool setToTemporary = true,
  }) async {
    final String? filePath =
        await _getCachedAlbumArtFilePathIfAvailableFor(songBase);

    if (dataToPutIfAbsent == null) {
      return filePath;
    }

    if ((filePath != null) && (await File(filePath).exists())) {
      return filePath;
    }

    final String result = await setAlbumArtCacheDataFor(
      songBase,
      dataToPutIfAbsent,
      setToTemporary: setToTemporary,
    );

    return result;
  }

  @pragma("vm:entry-point")
  static Future<Uint8List?> getCachedAlbumArtDataFor(SongBase song) async {
    final String? filePath =
        await _getCachedAlbumArtFilePathIfAvailableFor(song);

    if (filePath == null) {
      return null;
    }

    final File file = File(filePath);

    if (await file.exists()) {
      return file.readAsBytes();
    }

    return null;
  }

  /// Returns the path of the set file after caching.
  @pragma("vm:entry-point")
  static Future<String> setAlbumArtCacheDataFor(
    SongBase song,
    Uint8List data, {
    bool isJpeg = false,
    bool setToTemporary = true,
  }) async {
    await deleteCachedAlbumArtFileFor(song, deleteEntry: false);

    final Uint8List imageData = isJpeg ? data : await convertToJpeg(data);

    final String filePath = _getSupposedFilePathForData(
      imageData,
      temporaryDirectory: setToTemporary,
    );

    final File file = File(filePath);

    await file.writeAsBytes(imageData);

    final String key = song.songKey();

    await _entryDatabase!.put(key, filePath);

    return filePath;
  }

  @pragma("vm:entry-point")
  static Future<void> deleteCachedAlbumArtFileFor(
    SongBase playerDetectedSong, {
    bool deleteEntry = true,
  }) async {
    final String key = playerDetectedSong.songKey();

    final String? filePath = await _entryDatabase!.get(key);

    if (filePath == null) {
      return;
    }

    final File file = File(filePath);

    try {
      await file.delete();
      if (deleteEntry) {
        await _entryDatabase!.delete(key);
      }
    } catch (_) {
      logExceptRelease("Could not delete cache for $filePath");
    }
  }

  // Utility
  @pragma("vm:entry-point")
  static String _getSupposedFilePathForData(
    Uint8List data, {
    String extension = "jpg",
    bool temporaryDirectory = true,
  }) {
    return getHashPathForData(
      data: data,
      extension: extension,
      prefixPath: temporaryDirectory ? _temporaryDirectory : _supportDirectory,
    );
  }

  static Future<String?> _getCachedAlbumArtFilePathIfAvailableFor(
    SongBase song,
  ) async {
    final String key = song.songKey();
    return _entryDatabase!.get(key);
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

  /*@pragma("vm:entry-point")
  static Future<DateTime?> getDateTimeOfAlbumArtCaching(SongBase song) async {
    final String filePath = await getFilePathFor(song);

    final File file = File(filePath);

    if (await file.exists()) {
      return file.lastModified();
    }

    return null;
  }*/
}
