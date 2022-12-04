part of structures;

class OfflineDatabase extends LyricsAppDatabase {
  final _LyricsDatabase _lyricsDatabase = _LyricsDatabase();
  final _AlbumArtDatabase _albumArtDatabase = _AlbumArtDatabase();

  @override
  LyricsDatabase get lyrics => _lyricsDatabase;

  @override
  AlbumArtDatabase get albumArt => _albumArtDatabase;

  @override
  FutureOr<void> initialize() async {
    await Hive.initFlutter();
    await super.initialize();
  }
}

class _LyricsDatabase extends LyricsDatabase {
  late final LazyBox<String> _lyricsDatabase;

  @override
  FutureOr<void> initialize() async {
    _lyricsDatabase = await Hive.openLazyBox("lyrics");
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
  FutureOr<List<LyricsLine>?> getLyricsFor(SongBase song) async {
    final String key = song.key();
    logExceptRelease("Getting lyrics for $key");
    final String? jsonResult = await _lyricsDatabase.get(key);
    if (jsonResult == null) {
      return null;
    }
    final List<LyricsLine> result = LyricsLine.listFromRawJson(jsonResult);
    logExceptRelease("Lyrics for $key: ${result.length} lines");
    return result;
  }

  ValueListenable<LazyBox<String>> getSongListenable(SongBase song) {
    return _lyricsDatabase.listenable(keys: [song.key()]);
  }

  @override
  Stream<List<LyricsLine>?> getLyricsStreamFor(SongBase song) {
    final ListenableToStream<List<LyricsLine>?> listenableToStream =
        ListenableToStream<List<LyricsLine>?>(
      listenable: getSongListenable(song),
      getData: () async {
        return await getLyricsFor(song);
      },
    );

    return listenableToStream.stream;
  }

  @override
  FutureOr<void> putLyricsFor(SongBase song, List<LyricsLine> lyrics) async {
    final String songRawJson = song.key();
    final String lyricsRawJson = LyricsLine.listToRawJson(lyrics);

    await _lyricsDatabase.put(songRawJson, lyricsRawJson);
  }

  @override
  FutureOr<void> deleteLyricsFor(SongBase song) async {
    await _lyricsDatabase.delete(song.key());
  }

  @override
  FutureOr<void> dispose() async {
    await _lyricsDatabase.close();
  }
}

class _AlbumArtDatabase extends AlbumArtDatabase {
  late final LazyBox<String> _albumArtDatabase;

  @override
  FutureOr<void> initialize() async {
    _albumArtDatabase = await Hive.openLazyBox("album-art");
  }

  @override
  FutureOr<Uint8List?> getAlbumArtFor(SongBase song) async {
    final String key = song.key();

    //logExceptRelease("Getting album art for $key");

    final String? resultJson = await _albumArtDatabase.get(key);
    if (resultJson == null) {
      return null;
    }

    //logExceptRelease("Album art is present");

    final Uint8List result =
        Uint8List.fromList((jsonDecode(resultJson) as List).cast<int>());

    return result;
  }

  ValueListenable<LazyBox<String>> getAlbumArtListenable(
    SongBase song,
  ) {
    return _albumArtDatabase.listenable(keys: [song.key()]);
  }

  @override
  Stream<Uint8List?> getAlbumArtStreamFor(SongBase song) {
    final ListenableToStream<Uint8List?> listenableToStream =
        ListenableToStream<Uint8List?>(
      listenable: getAlbumArtListenable(song),
      getData: () async {
        return await getAlbumArtFor(song);
      },
    );

    return listenableToStream.stream;
  }

  @override
  FutureOr<void> putAlbumArtFor(SongBase song, Uint8List albumArt) async {
    final String key = song.key();
    final String albumArtString = jsonEncode(albumArt.toList());

    await _albumArtDatabase.put(key, albumArtString);
  }

  @override
  FutureOr<void> deleteAlbumArtFor(SongBase song) async {
    await _albumArtDatabase.delete(song.key());
  }

  @override
  Future<List<SongBase>> getAllAlbumArts() async {
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
  FutureOr<void> dispose() async {
    await _albumArtDatabase.close();
  }
}
