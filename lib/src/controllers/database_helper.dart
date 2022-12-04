part of controllers;

abstract class DatabaseHelper {
  static late LyricsAppDatabase _database;

  static Future<void> initialize(
    LyricsAppDatabase database,
  ) async {
    _database = database;
    await _database.initialize();
  }

  static Future<List<LyricsLine>?> getLyricsFor(SongBase song) async {
    return _database.lyrics.getLyricsFor(song);
  }

  static Stream<List<LyricsLine>?> getLyricsStreamFor(SongBase song) {
    return _database.lyrics.getLyricsStreamFor(song);
  }

  static Future<void> putLyricsFor(
    SongBase song,
    List<LyricsLine> lyrics,
  ) async {
    await _database.lyrics.putLyricsFor(song, lyrics);
  }

  static Future<void> deleteLyricsFor(
    SongBase song,
  ) async {
    await _database.lyrics.deleteLyricsFor(song);
  }

  static Future<Uint8List?> getAlbumArtFor(SongBase song) async {
    return await _database.albumArt.getAlbumArtFor(song);
  }

  static Stream<Uint8List?> getAlbumArtStreamFor(SongBase song) {
    return _database.albumArt.getAlbumArtStreamFor(song);
  }

  static Future<void> putAlbumArtFor(SongBase song, Uint8List albumArt) async {
    await _database.albumArt.putAlbumArtFor(song, albumArt);
  }

  static Future<void> deleteAlbumArtFor(
    SongBase song,
  ) async {
    await _database.albumArt.deleteAlbumArtFor(song);
  }

  static Future<List<SongBase>> getAllSongs() async {
    return await _database.lyrics.getAllSongs();
  }

  static Stream<List<SongBase>> getAllSongsStream() {
    return _database.lyrics.getAllSongsStream();
  }

  static FutureOr<List<SongBase>> getAllAlbumArts() {
    return _database.albumArt.getAllAlbumArts();
  }

  static Stream<List<SongBase>> getAllAlbumArtsStream() {
    return _database.albumArt.getAllAlbumArtsStream();
  }

  static Future<SongBase?> getMatchedSong(SongBase playerSong) async {
    final List<SongBase> allSongs = await _database.lyrics.getAllSongs();

    final SongBase processedPlayerSong = playerSong.processToSearchable();

    for (final SongBase song in allSongs) {
      if (song.isSearchMatchOf(processedPlayerSong)) {
        return song;
      }
    }

    return null;
  }
}

extension on SongBase {
  SongBase processToSearchable() => SongBase(
        songName: songName.trim().toLowerCase(),
        singerName: singerName.trim().toLowerCase(),
        albumName: albumName.trim().toLowerCase(),
      );

  bool isSearchMatchOf(SongBase processedSearchablePlayerSong) {
    final SongBase processed = SongBase(
      songName: songName.toLowerCase(),
      singerName: singerName.toLowerCase(),
      albumName: albumName.toLowerCase(),
    );

    final bool songNameMatch =
        processedSearchablePlayerSong.songName.contains(processed.songName);

    final bool singerNameMatch =
        processedSearchablePlayerSong.singerName.contains(processed.singerName);

    final bool albumNameMatch =
        processedSearchablePlayerSong.albumName.contains(processed.albumName);

    if (songNameMatch && singerNameMatch && albumNameMatch) {
      return true;
    } else if (songNameMatch && singerNameMatch && !albumNameMatch) {
      final bool alternateAlbumNameMatch = processedSearchablePlayerSong
          .albumName
          .contains(processedSearchablePlayerSong.singerName);
      return alternateAlbumNameMatch;
    }

    return false;
  }
}
