part of structures;

class OfflineDatabase extends LyricsAppDatabase {
  final _OfflineLyricsDatabase _lyricsDatabase = _OfflineLyricsDatabase();
  final _OfflineAlbumArtDatabase _albumArtDatabase = _OfflineAlbumArtDatabase();
  final _OfflineClipDatabase _clipDatabase = _OfflineClipDatabase();

  @override
  LyricsDatabase get lyrics => _lyricsDatabase;

  @override
  AlbumArtDatabase get albumArt => _albumArtDatabase;

  @override
  ClipDatabase get clips => _clipDatabase;

  @override
  Future<void> initialize() async {
    await initializeHive();
    await super.initialize();
  }
}

class _OfflineLyricsDatabase extends LyricsDatabase {
  late final LazyBox<String> _lyricsDatabase;

  @override
  Future<void> initialize() async {
    _lyricsDatabase = await Hive.openLazyBox("lyrics");
    await super.initialize();
  }

  @override
  FutureOr<List<SongBase>> getAllSongs() {
    return _lyricsDatabase.keys
        .cast<String>()
        .map<Map<String, dynamic>>((e) => jsonDecode(e) as Map<String, dynamic>)
        .where((element) => !element.containsKey("data"))
        .map<SongBase>((e) => SongBase.fromJson(e))
        .toList();
  }

  @override
  Stream<List<SongBase>> getAllSongsStream() {
    final ListenableToStream<List<SongBase>> listenableToStream =
        ListenableToStream<List<SongBase>>(
      listenable: _lyricsDatabase.listenable(),
      getData: () async {
        return getAllSongs();
      },
    );

    return listenableToStream.stream;
  }

  @override
  Future<List<LyricsLine>?> getLyricsFor(SongBase song) async {
    final String key = song.songKey();
    logExceptRelease("Getting lyrics for $key");
    final String? jsonResult = await _lyricsDatabase.get(key);
    if (jsonResult == null) {
      return null;
    }
    final List<LyricsLine> lyricsOnly = LyricsLine.listFromRawJson(jsonResult);

    if (song.languageCode == null) {
      return lyricsOnly;
    }

    final String? translationLanguageCode = getTranslationLanguage();

    if (translationLanguageCode == null) {
      return lyricsOnly;
    }

    final List<String>? translation = await getTranslation(
      song,
      lyricsOnly.map<String>((e) => e.line).toList(),
      translationLanguageCode,
    );

    if (translation == null) {
      return lyricsOnly;
    }

    logExceptRelease(
      "LyricsLength: ${lyricsOnly.length}, TranslationLength: ${translation.length}",
    );

    final List<LyricsLine> result = [
      for (int i = 0; i < lyricsOnly.length; ++i)
        lyricsOnly[i].withTranslation(translation[i]),
    ];

    logExceptRelease("Lyrics for $key: ${result.length} lines");
    return result;
  }

  ValueListenable<LazyBox<String>> getSongListenable(SongBase song) {
    return _lyricsDatabase.listenable(keys: [song.songKey()]);
  }

  @override
  Stream<List<LyricsLine>?> getLyricsStreamFor(SongBase song) {
    final ListenableToStream<List<LyricsLine>?> listenableToStream =
        ListenableToStream<List<LyricsLine>?>(
      listenable: getSongListenable(song),
      getData: () async {
        return getLyricsFor(song);
      },
    );

    return listenableToStream.stream;
  }

  @override
  Future<void> putLyricsFor(SongBase song, List<LyricsLine> lyrics) async {
    final String songRawJson = song.songKey();
    final String lyricsRawJson = LyricsLine.listToRawJson(lyrics);

    await _lyricsDatabase.put(songRawJson, lyricsRawJson);
  }

  @override
  Future<void> deleteLyricsFor(SongBase song) async {
    await _lyricsDatabase.delete(song.songKey());
  }

  @override
  Future<void> dispose() async {
    await _lyricsDatabase.close();
    await super.dispose();
  }
}

class _OfflineAlbumArtDatabase extends AlbumArtDatabase {
  late final LazyBox<String> _albumArtDatabase;

  @override
  Future<void> initialize() async {
    _albumArtDatabase = await Hive.openLazyBox("album-art");
  }

  @override
  Future<Uint8List?> getAlbumArtFor(SongBase song) async {
    final String key = song.albumArtKey();

    logExceptRelease("Getting album art for $key");

    final String? resultJson = await _albumArtDatabase.get(key);
    if (resultJson == null) {
      return null;
    }

    logExceptRelease("Album art is present");

    final Uint8List result =
        Uint8List.fromList((jsonDecode(resultJson) as List).cast<int>());

    return result;
  }

  ValueListenable<LazyBox<String>> getAlbumArtListenable(
    SongBase song,
  ) {
    return _albumArtDatabase.listenable(keys: [song.albumArtKey()]);
  }

  @override
  Stream<Uint8List?> getAlbumArtStreamFor(SongBase song) {
    final ListenableToStream<Uint8List?> listenableToStream =
        ListenableToStream<Uint8List?>(
      listenable: getAlbumArtListenable(song),
      getData: () async {
        return getAlbumArtFor(song);
      },
    );

    return listenableToStream.stream;
  }

  @override
  Future<void> putAlbumArtFor(SongBase song, Uint8List albumArt) async {
    final String key = song.albumArtKey();
    final String albumArtString = jsonEncode(albumArt.toList());

    await _albumArtDatabase.put(key, albumArtString);
  }

  @override
  Future<void> deleteAlbumArtFor(SongBase song) async {
    await _albumArtDatabase.delete(song.albumArtKey());
  }

  @override
  FutureOr<List<SongBase>> getAllAlbumArts() async {
    return _albumArtDatabase.keys
        .cast<String>()
        .map<Map<String, dynamic>>((e) => jsonDecode(e) as Map<String, dynamic>)
        .where((element) => !element.containsKey("data"))
        .map<SongBase>((e) => SongBase.fromJson(e))
        .toList();
  }

  @override
  Stream<List<SongBase>> getAllAlbumArtsStream() {
    final ListenableToStream<List<SongBase>> listenableToStream =
        ListenableToStream<List<SongBase>>(
      listenable: _albumArtDatabase.listenable(),
      getData: () async {
        return getAllAlbumArts();
      },
    );

    return listenableToStream.stream;
  }

  @override
  Future<void> dispose() async {
    await _albumArtDatabase.close();
  }
}

class _OfflineClipDatabase extends ClipDatabase {
  late final LazyBox<String> _clipDatabase;
  late final String _supportDirectory;

  @override
  Future<void> initialize() async {
    _clipDatabase = await Hive.openLazyBox("clips");
    _supportDirectory =
        path.join((await getApplicationSupportDirectory()).path, "clips");
  }

  @override
  Future<FileMedia?> getClipFor(SongBase song) async {
    final String key = song.songKey();

    final String? result = await _clipDatabase.get(key);

    if (result == null) {
      return null;
    }

    final File file = File(result);

    if (!(await file.exists())) {
      await deleteClipFor(song);
      return null;
    }

    return FileMedia(data: file);
  }

  ValueListenable<LazyBox<String>> getClipListenable(
    SongBase song,
  ) {
    return _clipDatabase.listenable(keys: [song.songKey()]);
  }

  @override
  Stream<FileMedia?> getClipStreamFor(SongBase song) {
    final ListenableToStream<FileMedia?> listenableToStream =
        ListenableToStream<FileMedia?>(
      listenable: getClipListenable(song),
      getData: () async {
        return getClipFor(song);
      },
    );
    return listenableToStream.stream;
  }

  @override
  Future<void> putClipFor(SongBase song, File clip) async {
    final String supposedFileName = await getSupposedPathFor(
      file: clip,
      prefixPath: _supportDirectory,
    );
    final String key = song.songKey();
    await clip.copy(supposedFileName);
    await _clipDatabase.put(key, supposedFileName);
  }

  @override
  Future<void> deleteClipFor(SongBase song) async {
    final FileMedia? fileMedia = await getClipFor(song);
    await fileMedia?.data.delete();
  }

  @override
  FutureOr<List<SongBase>> getAllClips() {
    return _clipDatabase.keys
        .cast<String>()
        .map<Map<String, dynamic>>((e) => jsonDecode(e) as Map<String, dynamic>)
        .where((element) => !element.containsKey("data"))
        .map<SongBase>((e) => SongBase.fromJson(e))
        .toList();
  }

  @override
  Stream<List<SongBase>> getAllClipsStream() {
    final ListenableToStream<List<SongBase>> listenableToStream =
        ListenableToStream<List<SongBase>>(
      listenable: _clipDatabase.listenable(),
      getData: () async {
        return getAllClips();
      },
    );

    return listenableToStream.stream;
  }

  @override
  Future<void> dispose() async {
    await _clipDatabase.close();
  }
}
