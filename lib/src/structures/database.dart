part of structures;

abstract class LyricsAppDatabaseBase extends LogHelper {
  //const LyricsAppDatabaseBase();

  @mustCallSuper
  FutureOr<void> initialize() {
    isInitialized = true;
  }

  @mustCallSuper
  FutureOr<void> dispose() {
    isInitialized = false;
  }

  bool isInitialized = false;

  bool get isNotInitialized => !isInitialized;
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
    await super.initialize();
  }

  @mustCallSuper
  @override
  FutureOr<void> dispose() async {
    await lyrics.dispose();
    await albumArt.dispose();
    await clips.dispose();
    await super.dispose();
  }
}

abstract class LyricsDatabase extends TranslationDatabase {
  //const LyricsDatabase();

  FutureOr<List<SongBase>> getAllSongs();

  Stream<List<SongBase>> getAllSongsStream();

  FutureOr<List<LyricsLine>?> getLyricsFor(
    SongBase song, {
    bool withoutTranslation = false,
  });

  Stream<List<LyricsLine>?> getLyricsStreamFor(
    SongBase song, {
    bool withoutTranslation = false,
  });

  FutureOr<void> putLyricsFor(
    SongBase song,
    List<LyricsLine> lyrics,
  );

  Future<void> editLyricsSongDetailsFor(
    SongBase oldDetails,
    SongBase newDetails,
    List<LyricsLine>? lyrics,
  ) async {
    final List<LyricsLine>? tLyrics = lyrics ?? await getLyricsFor(oldDetails);

    if (tLyrics == null) {
      return;
    }

    await deleteLyricsFor(oldDetails);

    await putLyricsFor(newDetails, tLyrics);
  }

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

    if (translationLanguageCode == song.languageCode) {
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

    logER(
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
  //const AlbumArtDatabase();

  FutureOr<Uint8List?> getAlbumArtFor(SongBase song);

  Stream<Uint8List?> getAlbumArtStreamFor(SongBase song);

  FutureOr<void> putAlbumArtFor(SongBase song, Uint8List albumArt);

  Future<void> editAlbumArtSongDetailsFor(
    SongBase oldDetails,
    SongBase newDetails,
    Uint8List? albumArt,
  ) async {
    final Uint8List? tAlbumArt = albumArt ?? await getAlbumArtFor(oldDetails);

    if (tAlbumArt == null) {
      return;
    }

    await deleteAlbumArtFor(oldDetails);

    await putAlbumArtFor(newDetails, tAlbumArt);
  }

  FutureOr<void> deleteAlbumArtFor(SongBase song);

  FutureOr<List<SongBase>> getAllAlbumArts();

  Stream<List<SongBase>> getAllAlbumArtsStream();
}

abstract class ClipDatabase extends LyricsAppDatabaseBase {
  //const ClipDatabase();

  FutureOr<File?> getClipFor(SongBase song);

  Stream<File?> getClipStreamFor(SongBase song);

  FutureOr<void> putClipFor(SongBase song, File clip);

  Future<void> editClipSongDetailsFor(
    SongBase oldDetails,
    SongBase newDetails,
    File? clip,
  ) async {
    final File? tClip = clip ?? await getClipFor(oldDetails);

    if (tClip == null) {
      return;
    }

    await deleteClipFor(oldDetails);

    await putClipFor(newDetails, tClip);
  }

  FutureOr<void> deleteClipFor(SongBase song);

  FutureOr<List<SongBase>> getAllClips();

  Stream<List<SongBase>> getAllClipsStream();

  Future<String> getSupposedPathFor({
    required File file,
    String? prefixPath,
  }) async {
    final String extension = path.extension(file.path);
    final Uint8List bytes = await file.readAsBytes();
    final Digest x = sha512.convert(bytes);
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
    await super.initialize();
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

    final List<String>? translation = await _lyricsTranslator.getTranslation(
      source: lyrics,
      sourceLanguage: song.languageCode,
      destinationLanguage: languageCode,
    );

    if (translation == null) {
      throw "Could not get translation";
    }

    final String hash = _getHashForLyrics(lyrics);

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

  Future<void> editTranslationSongDetailsFor(
    SongBase oldDetails,
    SongBase newDetails,
  ) async {
    final String oldKey = oldDetails.songKey();

    final String? lyrics = await _translationDatabase.get(oldKey);

    if (lyrics == null) {
      return;
    }

    final String newKey = newDetails.songKey();

    await _translationDatabase.put(newKey, lyrics);

    await _translationDatabase.delete(oldKey);
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
    await super.dispose();
  }

  String _getHashForLyrics(List<String> lyrics) {
    return sha512.convert(utf8.encode(lyrics.join("\n"))).toString();
  }
}

/*
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
*/
