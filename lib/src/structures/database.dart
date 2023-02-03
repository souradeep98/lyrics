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
  ClipDatabase get clips;

  @mustCallSuper
  @override
  FutureOr<void> initialize() async {
    await lyrics.initialize();
    await albumArt.initialize();
    await clips.initialize();
  }

  @mustCallSuper
  @override
  FutureOr<void> dispose() async {
    await lyrics.dispose();
    await albumArt.dispose();
    await clips.dispose();
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

abstract class ClipDatabase extends LyricsAppDatabaseBase {
  const ClipDatabase();

  FutureOr<Media?> getClipFor(SongBase song);

  Stream<Media?> getClipStreamFor(SongBase song);

  FutureOr<void> putClipFor(SongBase song, File clip);

  FutureOr<void> deleteClipFor(SongBase song);

  FutureOr<List<SongBase>> getAllClips();

  Stream<List<SongBase>> getAllClipsStream();
}

enum ResourceLocationType {
  url, file, filepath, data;
}

/*typedef URLMedia = Media<String>;
typedef FileMedia = Media<File>;
typedef FilePathMedia = Media<String>;
typedef DataMedia = Media<Uint8List>;*/

class DataMedia extends Media<Uint8List> {
  const DataMedia({required super.data}) : super(type: ResourceLocationType.data);
}

class FilePathMedia extends Media<String> {
  const FilePathMedia({required super.data})
      : super(type: ResourceLocationType.filepath);
}

class FileMedia extends Media<File> {
  const FileMedia({required super.data})
      : super(type: ResourceLocationType.file);
}

class URLMedia extends Media<File> {
  const URLMedia({required super.data})
      : super(type: ResourceLocationType.url);
}

abstract class Media<T> {
  final ResourceLocationType type;
  final T data;
  
  const Media({
    required this.type,
    required this.data,
  });

  @override
  String toString() => 'Media(type: $type, data: $data)';

 @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Media<T> &&
      other.type == type &&
      other.data == data;
  }

  @override
  int get hashCode => type.hashCode ^ data.hashCode;
}
