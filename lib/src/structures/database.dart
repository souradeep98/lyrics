part of structures;

abstract class LyricsAppDatabaseBase {
  const LyricsAppDatabaseBase();

  FutureOr<void> initialize();
  FutureOr<void> dispose();
}

abstract class LyricsAppDatabase extends LyricsAppDatabaseBase {
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

abstract class LyricsDatabase extends TranslationDatabase {
  //const LyricsDatabase();

  FutureOr<List<SongBase>> getAllSongs();

  Stream<List<SongBase>> getAllSongsStream();

  FutureOr<List<LyricsLine>?> getLyricsFor(SongBase song);

  Stream<List<LyricsLine>?> getLyricsStreamFor(SongBase song);

  FutureOr<void> putLyricsFor(
    SongBase song,
    List<LyricsLine> lyrics,
  );

  FutureOr<void> deleteLyricsFor(SongBase song);

  Future<List<LyricsLine>> _getTranslationForLyrics(
    SongBase song,
    List<LyricsLine> lyricsOnly,
  ) async {
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

    return result;
  }
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

  Future<String> getSupposedPathFor({
    required File file,
    String? prefixPath,
  }) async {
    final String extension = path.extension(file.path);
    final Uint8List bytes = await file.readAsBytes();
    final Digest x = sha1.convert(bytes);
    final String hash = x.toString();
    final String filename = hash;
    if (prefixPath != null) {
      return path.join(prefixPath, "$filename$extension");
    }
    return "$filename$extension";
  }
}

class TranslationDatabase extends LyricsAppDatabaseBase {
  late final LyricsTranslator _lyricsTranslator;
  late final LazyBox<String> _translationDatabase;

  @mustCallSuper
  @override
  Future<void> initialize() async {
    _lyricsTranslator = LyricsTranslator();
    await _lyricsTranslator.initialize();
    _translationDatabase = await Hive.openLazyBox("lyrics_translation");
  }

  Future<List<String>?> getTranslation(
    SongBase song,
    List<String> lyrics,
    String translationLanguageCode,
  ) async {
    final SongBase translateSongBase = song.copyWith(
      languageCode: translationLanguageCode,
    );

    final String key = translateSongBase.songKey();

    final String? dbResult = await _translationDatabase.get(key);

    if (dbResult == null) {
      return setTranslation(song, lyrics, translationLanguageCode);
    }

    final TranslationData dbTranslationData =
        TranslationData.fromJson(dbResult);

    final String hash = _getHashForLyrics(lyrics);

    if (dbTranslationData.hash != hash) {
      return setTranslation(song, lyrics, translationLanguageCode);
    }

    return dbTranslationData.translation;
  }

  Future<List<String>> setTranslation(
    SongBase song,
    List<String> lyrics,
    String languageCode,
  ) async {
    final SongBase translateSongBase = song.copyWith(
      languageCode: languageCode,
    );

    final String key = translateSongBase.songKey();

    final String hash = _getHashForLyrics(lyrics);

    final List<String>? translation = await _lyricsTranslator.getTranslation(
      source: lyrics,
      sourceLanguage: song.languageCode,
      destinationLanguage: languageCode,
    );

    if (translation == null) {
      throw "Could not get translation";
    }

    final TranslationData translationData = TranslationData(
      hash: hash,
      translation: translation,
    );

    await _translationDatabase.put(
      key,
      translationData.toJson(),
    );

    return translation;
  }

  Future<void> deleteTranslation(
    SongBase song,
    String languageCode,
  ) async {
    final SongBase translateSongBase = song.copyWith(
      languageCode: languageCode,
    );

    final String key = translateSongBase.songKey();

    await _translationDatabase.delete(key);
  }

  @mustCallSuper
  @override
  Future<void> dispose() async {
    await _translationDatabase.close();
  }

  String _getHashForLyrics(List<String> lyrics) {
    return sha1.convert(utf8.encode(lyrics.join("\n"))).toString();
  }
}

class TranslationData {
  final String hash;
  final List<String> translation;

  const TranslationData({
    required this.hash,
    required this.translation,
  });

  TranslationData copyWith({
    String? hash,
    List<String>? translation,
  }) {
    return TranslationData(
      hash: hash ?? this.hash,
      translation: translation ?? this.translation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TranslationData &&
        other.hash == hash &&
        listEquals(other.translation, translation);
  }

  @override
  int get hashCode => hash.hashCode ^ translation.hashCode;

  Map<String, dynamic> toMap() {
    return {
      'hash': hash,
      'translation': translation,
    };
  }

  factory TranslationData.fromMap(Map<String, dynamic> map) {
    return TranslationData(
      hash: map['hash'] as String,
      translation: (map['translation'] as List).cast<String>(),
    );
  }

  String toJson() => json.encode(toMap());

  factory TranslationData.fromJson(String source) =>
      TranslationData.fromMap(json.decode(source) as Map<String, dynamic>);
}

enum ResourceLocationType {
  url,
  file,
  filepath,
  data;
}

/*typedef URLMedia = Media<String>;
typedef FileMedia = Media<File>;
typedef FilePathMedia = Media<String>;
typedef DataMedia = Media<Uint8List>;*/

class DataMedia extends Media<Uint8List> {
  const DataMedia({required super.data})
      : super(type: ResourceLocationType.data);
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
  const URLMedia({required super.data}) : super(type: ResourceLocationType.url);
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

    return other is Media<T> && other.type == type && other.data == data;
  }

  @override
  int get hashCode => type.hashCode ^ data.hashCode;
}
