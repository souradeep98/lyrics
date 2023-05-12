part of '../structures.dart';

class SongBase {
  final String? songName;
  final String singerName;
  final String? albumName;
  final String? languageCode;

  const SongBase({
    required this.songName,
    required this.singerName,
    required this.albumName,
    required this.languageCode,
  });

  @override
  @mustCallSuper
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SongBase &&
        other.songName == songName &&
        other.singerName == singerName &&
        other.albumName == albumName &&
        other.languageCode == languageCode;
  }

  @override
  @mustCallSuper
  int get hashCode {
    return songName.hashCode ^
        singerName.hashCode ^
        albumName.hashCode ^
        languageCode.hashCode;
  }

  @mustCallSuper
  Map<String, dynamic> toJson() {
    return {
      if (songName != null) 'songName': songName,
      'singerName': singerName,
      if (albumName != null) 'albumName': albumName,
      if (languageCode != null) 'languageCode': languageCode,
    };
  }

  factory SongBase.fromJson(Map<String, dynamic> map) {
    return SongBase(
      songName: map['songName'] as String?,
      singerName: map['singerName'] as String,
      albumName: map['albumName'] as String?,
      languageCode: map['languageCode'] as String?,
    );
  }

  factory SongBase.fromRawJson(String json) =>
      SongBase.fromJson(jsonDecode(json) as Map<String, dynamic>);

  String toRawJson() => jsonEncode(toJson());

  SongBase toBase() => SongBase(
        songName: songName,
        singerName: singerName,
        albumName: albumName,
        languageCode: languageCode,
      );

  String key() => toBase().toRawJson();

  String songKey() => toBase().toRawJson();

  String albumArtKey({bool includeSongName = false}) {
    if (includeSongName) {
      return songKey();
    }

    final Map<String, dynamic> json = <String, String>{
      if (albumName == null) 'songName': songName!,
      'singerName': singerName,
      if (albumName != null) 'albumName': albumName!,
      if (languageCode != null) 'languageCode': languageCode!,
    };
    return jsonEncode(json);
  }

  String fileName() {
    final List<String> elements = [
      if (songName != null) songName!,
      singerName,
      if (albumName != null) albumName!,
    ];
    return elements.join("_");
  }

  String albumArtFileName({bool includeSongName = false}) {
    if (includeSongName) {
      return fileName();
    }

    final List<String> elements = [
      if (songName != null) songName!,
      singerName,
      if (albumName != null) albumName!,
    ];
    return elements.join("_");
  }

  SongBase copyWith({
    String? songName,
    String? singerName,
    String? albumName,
    String? languageCode,
  }) {
    return SongBase(
      songName: songName ?? this.songName,
      singerName: singerName ?? this.singerName,
      albumName: albumName ?? this.albumName,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  const SongBase.doesNotExist()
      : songName = "",
        singerName = "",
        albumName = "",
        languageCode = "";

  @override
  String toString() {
    return 'SongBase(songName: $songName, singerName: $singerName, albumName: $albumName, languageCode: $languageCode)';
  }
}

class Song extends SongBase {
  final List<LyricsLine> lyrics;

  const Song({
    required super.songName,
    required super.singerName,
    required super.albumName,
    required super.languageCode,
    required this.lyrics,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'lyrics': lyrics.map<Map<String, dynamic>>((x) => x.toJson()).toList(),
    };
  }

  factory Song.fromJson(Map<String, dynamic> map) {
    return Song(
      songName: map['songName'] as String?,
      singerName: map['singerName'] as String,
      albumName: map['albumName'] as String?,
      languageCode: map['languageCode'] as String?,
      lyrics: (map['lyrics'] as List)
          .map<LyricsLine>(
            (x) => LyricsLine.fromJson(x as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  factory Song.fromRawJson(String rawJson) {
    final Map<String, dynamic> json =
        jsonDecode(rawJson) as Map<String, dynamic>;
    return Song.fromJson(json);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is Song) {
      return super == other && listEquals(other.lyrics, lyrics);
    }

    if (other is SongBase) {
      return super == other;
    }

    return false;
  }

  @override
  int get hashCode {
    return lyrics.hashCode ^ super.hashCode;
  }
}
