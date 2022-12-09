part of structures;

class OfflineDatabase extends LyricsAppDatabase {
  final _OfflineLyricsDatabase _lyricsDatabase = _OfflineLyricsDatabase();
  final _OfflineAlbumArtDatabase _albumArtDatabase = _OfflineAlbumArtDatabase();

  @override
  LyricsDatabase get lyrics => _lyricsDatabase;

  @override
  AlbumArtDatabase get albumArt => _albumArtDatabase;

  @override
  Future<void> initialize() async {
    await Hive.initFlutter();
    await super.initialize();
  }
}

class _OfflineLyricsDatabase extends LyricsDatabase {
  late final LazyBox<String> _lyricsDatabase;

  @override
  Future<void> initialize() async {
    _lyricsDatabase = await Hive.openLazyBox("lyrics");

    if (_lyricsDatabase.isEmpty) {
      for (final MapEntry<String, String> entry
          in _RawLyricsEntries.entries.entries) {
        await _writeRaw(entry.key, entry.value);
      }
    }
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
        return getLyricsFor(song);
      },
    );

    return listenableToStream.stream;
  }

  @override
  Future<void> putLyricsFor(SongBase song, List<LyricsLine> lyrics) async {
    final String songRawJson = song.key();
    final String lyricsRawJson = LyricsLine.listToRawJson(lyrics);

    await _lyricsDatabase.put(songRawJson, lyricsRawJson);
  }

  Future<void> _writeRaw(String key, String value) async {
    if (kReleaseMode) {
      return;
    }
    await _lyricsDatabase.put(key, value);
  }

  @override
  Future<void> deleteLyricsFor(SongBase song) async {
    await _lyricsDatabase.delete(song.key());
  }

  @override
  Future<void> dispose() async {
    await _lyricsDatabase.close();
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
        return getAlbumArtFor(song);
      },
    );

    return listenableToStream.stream;
  }

  @override
  Future<void> putAlbumArtFor(SongBase song, Uint8List albumArt) async {
    final String key = song.key();
    final String albumArtString = jsonEncode(albumArt.toList());

    await _albumArtDatabase.put(key, albumArtString);
  }

  @override
  Future<void> deleteAlbumArtFor(SongBase song) async {
    await _albumArtDatabase.delete(song.key());
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


abstract class _RawLyricsEntries {
  static const Map<String, String> entries = {
    '''{"songName":"Wenn Du da bist","singerName":"Sarah Connor","albumName":"Muttersprache"}''':
        '''[{"duration":"0:00:11.703882","line":"Ich liege wach"},{"duration":"0:00:01.826747","line":"weil ich nicht schlafen will."},{"duration":"0:00:03.589172","line":"Ich schau dich an"},{"duration":"0:00:01.575522","line":"der Sturm wird plötzlich still."},{"duration":"0:00:03.738256","line":"Ich atme ruhig"},{"duration":"0:00:01.692789","line":"damit ich dich nicht weck."},{"duration":"0:00:03.622179","line":"Liegst einfach da"},{"duration":"0:00:01.553517","line":"und alles ist perfekt..."},{"duration":"0:00:07.710299","line":"Ist perfekt..."},{"duration":"0:00:04.121316","line":""},{"duration":"0:00:00.837774","line":"Wenn du da bist"},{"duration":"0:00:02.994895","line":"hab ich alles was ich brauch."},{"duration":"0:00:02.799259","line":"Wenn du da bist"},{"duration":"0:00:02.604758","line":"hört mein Kopf zu kämpfen auf."},{"duration":"0:00:02.681432","line":"Wenn du da bist"},{"duration":"0:00:02.788457","line":"Ist alles andere so weit weg."},{"duration":"0:00:02.713089","line":"Bleib hier, bleib hier, bitte bleib,"},{"duration":"0:00:05.195252","line":"Bei mir..."},{"duration":"0:00:04.743999","line":""},{"duration":"0:00:00.869304","line":"Die Zeit vor dir"},{"duration":"0:00:02.579674","line":"war viel zu laut und schnell."},{"duration":"0:00:03.715916","line":"Wolkenlos"},{"duration":"0:00:01.839890","line":"und doch nie richtig hell."},{"duration":"0:00:03.586631","line":"In deinen Armen,"},{"duration":"0:00:01.688887","line":"gibts nicht mehr was mich quält."},{"duration":"0:00:03.596282","line":"Ohne dich,"},{"duration":"0:00:01.750556","line":"merk ich wie viel mir fehlt..."},{"duration":"0:00:06.900862","line":"Wie viel mir fehlt..."},{"duration":"0:00:03.825336","line":""},{"duration":"0:00:02.047702","line":"Wenn du da bist"},{"duration":"0:00:02.806874","line":"hab ich alles was ich brauch."},{"duration":"0:00:02.782376","line":"Wenn du da bist"},{"duration":"0:00:02.707806","line":"hört mein Kopf zu kämpfen auf."},{"duration":"0:00:02.625574","line":"Wenn du da bist"},{"duration":"0:00:02.514251","line":"ist alles andere so weit weg."},{"duration":"0:00:02.801705","line":"Bleib hier, bleib hier, bitte bleib..."},{"duration":"0:00:05.225429","line":"Bei mir..."},{"duration":"0:00:03.544794","line":""},{"duration":"0:00:00.407013","line":"Hab den Moment so oft geträumt"},{"duration":"0:00:05.356390","line":"Mir das Gefühl genau vorgestellt"},{"duration":"0:00:04.010688","line":"Jetzt bist du hier"},{"duration":"0:00:02.807243","line":"Bei mir,"},{"duration":"0:00:02.645441","line":"Bitte bleib..."},{"duration":"0:00:02.812506","line":""},{"duration":"0:00:00.215401","line":"Wenn du da bist"},{"duration":"0:00:02.545013","line":"hab ich alles was ich brauch."},{"duration":"0:00:02.305765","line":"Wenn du da bist"},{"duration":"0:00:02.827292","line":"hört mein Kopf zu kämpfen auf."},{"duration":"0:00:02.500594","line":"Wenn du da bist"},{"duration":"0:00:02.895661","line":"ist alles andere so weit weg."},{"duration":"0:00:02.388217","line":"Bleib hier, bleib hier, bitte bleib..."},{"duration":"0:00:05.360885","line":""},{"duration":"0:00:00.259963","line":"Wenn du da bist"},{"duration":"0:00:02.554791","line":"hab ich alles was ich brauch."},{"duration":"0:00:02.719071","line":"Wenn du da bist"},{"duration":"0:00:02.464779","line":"hört mein Kopf zu kämpfen auf."},{"duration":"0:00:02.771059","line":"Wenn du da bist"},{"duration":"0:00:02.665404","line":"ist alles andere so weit weg..."},{"duration":"0:00:02.678297","line":"Bleib hier, bleib hier,"},{"duration":"0:00:02.861595","line":"Bitte bleib..."},{"duration":"0:00:02.434403","line":"Bei mir."},{"duration":"0:00:07.135830","line":""}]'''
  };
}
