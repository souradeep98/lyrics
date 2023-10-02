part of '../controllers.dart';

abstract final class GetXControllerManager {
  static final Map<SongBase, StreamDataObservable<List<LyricsLine>?>>
      _lyricsControllers = {};
  static final Map<SongBase, StreamDataObservable<Uint8List?>>
      _albumArtControllers = {};
  static final Map<SongBase, StreamDataObservable<File?>> _clipControllers = {};

  static StreamDataObservable<List<LyricsLine>?> getLyricsController(
    SongBase? song,
  ) {
    final SongBase resolvedSong = song ?? const SongBase.doesNotExist();

    _lyricsControllers[resolvedSong] ??=
        StreamDataObservable<List<LyricsLine>?>(
      stream: DatabaseHelper.getLyricsStreamFor(
        resolvedSong,
      ),
    ).put<StreamDataObservable<List<LyricsLine>?>>(
      tag: "Lyrics - ${resolvedSong.songSignature()}",
    );

    if (_lyricsControllers.length == 1) {
      _addSharedPreferencesListener();
    }

    return _lyricsControllers[resolvedSong]!;
  }

  static Future<void> removeLyricsController(SongBase? song) async {
    final SongBase resolvedSong = song ?? const SongBase.doesNotExist();
    final removedObject = _lyricsControllers.remove(resolvedSong);
    if (_lyricsControllers.isEmpty) {
      _removeSharedPreferencesListener();
    }
    await removedObject?.delete<StreamDataObservable<List<LyricsLine>?>>();
  }

  static void _addSharedPreferencesListener() {
    SharedPreferencesHelper.addListener(
      _sharedPreferencesListener,
      key: SharedPreferencesHelper.keys.lyricsTranslationLanguage,
    );
  }

  static void _removeSharedPreferencesListener() {
    SharedPreferencesHelper.removeListener(
      _sharedPreferencesListener,
      key: SharedPreferencesHelper.keys.lyricsTranslationLanguage,
    );
  }

  static void _sharedPreferencesListener(dynamic value) {
    for (final MapEntry<SongBase, StreamDataObservable<List<LyricsLine>?>> entry
        in _lyricsControllers.entries) {
      entry.value.updateData(() async {
        return DatabaseHelper.getLyricsFor(
          entry.key,
        );
      });
    }
  }

  static void reloadLyricsController(SongBase? song) {
    final SongBase resolvedSong = song ?? const SongBase.doesNotExist();
    _lyricsControllers[resolvedSong]?.updateData(() async {
      return DatabaseHelper.getLyricsFor(
        resolvedSong,
      );
    });
  }

  static StreamDataObservable<Uint8List?> getAlbumArtController(
    SongBase? song,
  ) {
    final SongBase resolvedSong = song ?? const SongBase.doesNotExist();

    return _albumArtControllers[resolvedSong] ??=
        StreamDataObservable<Uint8List?>(
      stream: DatabaseHelper.getAlbumArtStreamFor(resolvedSong),
      initialDataGenerator: () => DatabaseHelper.getAlbumArtFor(resolvedSong),
    ).put<StreamDataObservable<Uint8List?>>(
      tag: "AlbumArt - ${resolvedSong.songSignature()}",
    );
  }

  static Future<void> removeAlbumArtController(SongBase? song) async {
    final SongBase resolvedSong = song ?? const SongBase.doesNotExist();
    final removedObject = _albumArtControllers.remove(resolvedSong);
    await removedObject?.delete<StreamDataObservable<Uint8List?>>();
  }

  static StreamDataObservable<File?> getClipController(SongBase? song) {
    final SongBase resolvedSong = song ?? const SongBase.doesNotExist();

    return _clipControllers[resolvedSong] ??= StreamDataObservable<File?>(
      stream: DatabaseHelper.getClipStreamFor(resolvedSong),
    ).put<StreamDataObservable<File?>>(
      tag: "Clip - ${resolvedSong.songSignature()}",
    );
  }

  static Future<void> removeClipController(SongBase? song) async {
    final SongBase resolvedSong = song ?? const SongBase.doesNotExist();
    final removedObject = _clipControllers.remove(resolvedSong);
    await removedObject?.delete<StreamDataObservable<File?>>();
  }
}
