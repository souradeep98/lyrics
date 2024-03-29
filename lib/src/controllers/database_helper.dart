part of '../controllers.dart';

abstract final class DatabaseHelper {
  @pragma("vm:entry-point")
  static LyricsAppDatabase? _database;

  @pragma("vm:entry-point")
  static bool get isInitialized => _database != null;

  @pragma("vm:entry-point")
  static Future<void> initialize(
    LyricsAppDatabase database,
  ) async {
    if (isInitialized) {
      return;
    }
    _logER("Initialize()");
    _database = database;
    await _database?.initialize();

    _logER("Initialized");

    /*SharedPreferencesHelper.isFirstTime(
      callbackToWaitBeforeSettingFalse: _loadContentResources,
    );*/
  }

  @pragma("vm:entry-point")
  static Future<List<LyricsLine>?> getLyricsFor(SongBase song) async {
    _logER("getLyricsFor(): $song");
    return _database?.lyrics.getLyricsFor(song);
  }

  @pragma("vm:entry-point")
  static Stream<List<LyricsLine>?> getLyricsStreamFor(SongBase song) {
    _logER("getLyricsStreamFor(): $song");
    return _database?.lyrics.getLyricsStreamFor(song) ??
        Stream<List<LyricsLine>?>.value(null);
  }

  @pragma("vm:entry-point")
  static Future<void> putLyricsFor(
    SongBase song,
    List<LyricsLine> lyrics,
  ) async {
    _logER("putLyricsFor(): $song, lyrics: ${lyrics.length} lines");
    await _database?.lyrics.putLyricsFor(song, lyrics);
  }

  @pragma("vm:entry-point")
  static Future<void> deleteLyricsFor(
    SongBase song,
  ) async {
    _logER("deleteLyricsFor(): $song");
    await _database?.lyrics.deleteLyricsFor(song);
  }

  @pragma("vm:entry-point")
  static Future<Uint8List?> getAlbumArtFor(SongBase song) async {
    _logER("getAlbumArtFor(): $song");
    return await _database?.albumArt.getAlbumArtFor(song);
  }

  @pragma("vm:entry-point")
  static Stream<Uint8List?> getAlbumArtStreamFor(SongBase song) {
    _logER("getAlbumArtStreamFor(): $song");
    return _database?.albumArt.getAlbumArtStreamFor(song) ??
        Stream<Uint8List?>.value(null);
  }

  @pragma("vm:entry-point")
  static Future<void> putAlbumArtFor(SongBase song, Uint8List albumArt) async {
    _logER("putAlbumArtFor(): $song");
    await _database?.albumArt.putAlbumArtFor(song, albumArt);
  }

  @pragma("vm:entry-point")
  static Future<void> deleteAlbumArtFor(
    SongBase song,
  ) async {
    _logER("deleteAlbumArtFor(): $song");
    await _database?.albumArt.deleteAlbumArtFor(song);
  }

  @pragma("vm:entry-point")
  static Future<List<SongBase>> getAllSongs() async {
    _logER("getAllSongs()");
    return (await _database?.lyrics.getAllSongs()) ?? [];
  }

  @pragma("vm:entry-point")
  static Stream<List<SongBase>> getAllSongsStream() {
    _logER("getAllSongsStream()");
    return _database?.lyrics.getAllSongsStream() ??
        Stream<List<SongBase>>.value([]);
  }

  @pragma("vm:entry-point")
  static FutureOr<List<SongBase>> getAllAlbumArts() async {
    _logER("getAllAlbumArts()");
    return (await _database?.albumArt.getAllAlbumArts()) ?? [];
  }

  @pragma("vm:entry-point")
  static Stream<List<SongBase>> getAllAlbumArtsStream() {
    _logER("getAllAlbumArtsStream()");
    return _database?.albumArt.getAllAlbumArtsStream() ??
        Stream<List<SongBase>>.value([]);
  }

  @pragma("vm:entry-point")
  static Future<SongBase?> getMatchedSong(
    SongBase playerSong, {
    MatchIgnoreParameters matchIgnoreParameters =
        const MatchIgnoreParameters.song(),
  }) async {
    _logER("getMatchedSong(): $playerSong");
    final List<SongBase> allSongs =
        (await _database?.lyrics.getAllSongs()) ?? [];

    final SongBase processedPlayerSong = playerSong.processToSearchable();

    for (final SongBase song in allSongs) {
      if (song.isSearchMatchOf(
        processedPlayerSong,
        ignoreSongAlbum: matchIgnoreParameters.albumName,
        ignoreSingerName: matchIgnoreParameters.singerName,
        ignoreSongName: matchIgnoreParameters.songName,
      )) {
        return song;
      }
    }

    return null;
  }

  @pragma("vm:entry-point")
  static Future<SongBase?> getMatchedAlbumArt(
    SongBase playerSong, {
    MatchIgnoreParameters matchIgnoreParameters =
        const MatchIgnoreParameters.albumArt(),
  }) async {
    _logER("getMatchedAlbumArt(): $playerSong");
    final List<SongBase> allAlbumArts =
        (await _database?.albumArt.getAllAlbumArts()) ?? [];

    final SongBase processedPlayerSong = playerSong.processToSearchable();

    for (final SongBase albumArt in allAlbumArts) {
      if (albumArt.isSearchMatchOf(
        processedPlayerSong,
        ignoreSongAlbum: matchIgnoreParameters.albumName,
        ignoreSingerName: matchIgnoreParameters.singerName,
        ignoreSongName: matchIgnoreParameters.songName,
      )) {
        return albumArt;
      }
    }

    return null;
  }

  @pragma("vm:entry-point")
  static Future<File?> getClipFor(SongBase song) async {
    _logER("getClipFor(): $song");
    return await _database?.clips.getClipFor(song);
  }

  @pragma("vm:entry-point")
  static Stream<File?> getClipStreamFor(SongBase song) {
    _logER("getClipStreamFor(): $song");
    return _database?.clips.getClipStreamFor(song) ?? Stream<File?>.value(null);
  }

  @pragma("vm:entry-point")
  static Future<void> putClipFor(SongBase song, File clip) async {
    _logER("putClipFor(): $song, ${clip.path}");
    await _database?.clips.putClipFor(song, clip);
  }

  @pragma("vm:entry-point")
  static Future<void> deleteClipFor(SongBase song) async {
    _logER("deleteClipFor(): $song");
    await _database?.clips.deleteClipFor(song);
  }

  @pragma("vm:entry-point")
  static Future<List<SongBase>> getAllClips() async {
    _logER("getAllClips()");
    return (await _database?.clips.getAllClips()) ?? [];
  }

  @pragma("vm:entry-point")
  static Stream<List<SongBase>> getAllClipsStream() {
    _logER("getAllClipsStream()");
    return _database?.clips.getAllClipsStream() ??
        Stream<List<SongBase>>.value([]);
  }

  @pragma("vm:entry-point")
  static Future<void> editSongDetailsFor(
    SongBase oldDetails,
    SongBase newDetails,
  ) async {
    _logER("editSongDetailsFor(): old: $oldDetails, new: $newDetails");
    Future<void> wrapper(FutureOr futureOr) async {
      await futureOr;
    }

    await Future.wait([
      wrapper(
        _database?.lyrics
            .editLyricsSongDetailsFor(oldDetails, newDetails, null),
      ),
      wrapper(
        _database?.lyrics.editTranslationSongDetailsFor(oldDetails, newDetails),
      ),
      wrapper(
        _database?.albumArt
            .editAlbumArtSongDetailsFor(oldDetails, newDetails, null),
      ),
      wrapper(
        _database?.clips.editClipSongDetailsFor(oldDetails, newDetails, null),
      ),
      wrapper(
        AlbumArtCache.editCachedAlbumArtFileDetails(
          oldDetails: oldDetails,
          newDetails: newDetails,
        ),
      ),
    ]);
  }

  @pragma("vm:entry-point")
  static Future<void> _loadContentResources() async {
    _logER("_loadContentResources()");
    for (final MapEntry<String, String> entry
        in ContentResources.lyrics.entries) {
      try {
        final SongBase songBase = SongBase.fromJson(entry.key);
        final String rawJson = await rootBundle.loadString(entry.value);
        final Song song = Song.fromRawJson(rawJson);
        await _database?.lyrics.putLyricsFor(songBase, song.lyrics);
      } catch (_) {}
    }

    for (final MapEntry<String, String> entry
        in ContentResources.albumArts.entries) {
      try {
        final SongBase song = SongBase.fromJson(entry.key);
        final ByteData byteData = await rootBundle.load(entry.value);
        final Uint8List albumArt = byteData.buffer
            .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
        await _database?.albumArt.putAlbumArtFor(song, albumArt);
      } catch (_) {}
    }
  }

  static void _logER(
    Object? message, {
    int? sequenceNumber,
    int level = 0,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logExceptRelease(
      message,
      time: DateTime.now(),
      sequenceNumber: sequenceNumber,
      level: level,
      name: "DatabaseHelper",
      zone: Zone.current,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

extension on SongBase {
  @pragma("vm:entry-point")
  SongBase processToSearchable() => SongBase(
        songName: songName?.trim().toLowerCase(),
        singerName: singerName.trim().toLowerCase(),
        albumName: albumName?.trim().toLowerCase(),
        languageCode: "",
      );

  @pragma("vm:entry-point")
  bool isSearchMatchOf(
    SongBase processedSearchablePlayerSong, {
    bool ignoreSongName = false,
    bool ignoreSongAlbum = false,
    bool ignoreSingerName = false,
  }) {
    final SongBase processed = SongBase(
      songName: ignoreSongName ? "" : songName?.toLowerCase(),
      singerName: ignoreSingerName ? "" : singerName.toLowerCase(),
      albumName: ignoreSongAlbum ? "" : albumName?.toLowerCase(),
      languageCode: "",
    );

    final bool songNameMatch = ignoreSongName ||
        (processedSearchablePlayerSong.songName
                ?.contains(processed.songName ?? "") ??
            true);

    final bool singerNameMatch = ignoreSingerName ||
        processedSearchablePlayerSong.singerName.contains(processed.singerName);

    final bool albumNameMatch = ignoreSongAlbum ||
        (processedSearchablePlayerSong.albumName
                ?.contains(processed.albumName ?? "") ??
            false);

    if (songNameMatch && singerNameMatch && albumNameMatch) {
      return true;
    } else if (songNameMatch && singerNameMatch && !albumNameMatch) {
      final bool alternateAlbumNameMatch = processedSearchablePlayerSong
              .albumName
              ?.contains(processedSearchablePlayerSong.singerName) ??
          true;
      return alternateAlbumNameMatch;
    }

    return false;
  }
}
