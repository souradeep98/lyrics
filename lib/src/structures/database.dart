part of structures;

abstract class LyricsAppDatabaseBase {
  const LyricsAppDatabaseBase();

  FutureOr<void> initialize();
  FutureOr<void> dispose();
}

abstract class LyricsAppDatabase extends LyricsAppDatabaseBase {
  const LyricsAppDatabase();

  LyricsDatabase get lyrics;
  AlbumArtDatabase get albumArt;

  @mustCallSuper
  @override
  FutureOr<void> initialize() async {
    await lyrics.initialize();
    await albumArt.initialize();
  }

  @mustCallSuper
  @override
  FutureOr<void> dispose() async {
    await lyrics.dispose();
    await albumArt.dispose();
  }
}

abstract class LyricsDatabase extends LyricsAppDatabaseBase {
  const LyricsDatabase();

  FutureOr<List<SongBase>> getAllSongs();

  Stream<List<SongBase>> getAllSongsStream();

  FutureOr<List<LyricsLine>?> getLyricsFor(SongBase song);

  Stream<List<LyricsLine>?> getLyricsStreamFor(SongBase song);

  FutureOr<void> putLyricsFor(
    SongBase song,
    List<LyricsLine> lyrics,
  );

  FutureOr<void> deleteLyricsFor(SongBase song);
}

abstract class AlbumArtDatabase extends LyricsAppDatabaseBase {
  const AlbumArtDatabase();

  FutureOr<Uint8List?> getAlbumArtFor(SongBase song);

  Stream<Uint8List?> getAlbumArtStreamFor(SongBase song);

  FutureOr<void> putAlbumArtFor(SongBase song, Uint8List albumArt);

  FutureOr<void> deleteAlbumArtFor(SongBase song);

  FutureOr<List<SongBase>> getAllAlbumArts();

  Stream<List<SongBase>> getAllAlbumArtsStream();
}
