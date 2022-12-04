part of structures;

class SongBase {
  final String songName;
  final String singerName;
  final String albumName;

  const SongBase({
    required this.songName,
    required this.singerName,
    required this.albumName,
  });

  @override
  @mustCallSuper
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SongBase &&
        other.songName == songName &&
        other.singerName == singerName &&
        other.albumName == albumName;
  }

  @override
  @mustCallSuper
  int get hashCode =>
      songName.hashCode ^ singerName.hashCode ^ albumName.hashCode;

  @mustCallSuper
  Map<String, dynamic> toJson() {
    return {
      'songName': songName,
      'singerName': singerName,
      'albumName': albumName,
    };
  }

  factory SongBase.fromJson(Map<String, dynamic> map) {
    return SongBase(
      songName: map['songName'] as String,
      singerName: map['singerName'] as String,
      albumName: map['albumName'] as String,
    );
  }

  factory SongBase.fromRawJson(String json) =>
      SongBase.fromJson(jsonDecode(json) as Map<String, dynamic>);

  String toRawJson() => jsonEncode(toJson());

  SongBase toBase() => SongBase(
        songName: songName,
        singerName: singerName,
        albumName: albumName,
      );

  String key() => toBase().toRawJson();

  SongBase copyWith({
    String? songName,
    String? singerName,
    String? albumName,
  }) {
    return SongBase(
      songName: songName ?? this.songName,
      singerName: singerName ?? this.singerName,
      albumName: albumName ?? this.albumName,
    );
  }

  const SongBase.doesNotExist() : songName = "", singerName = "", albumName = "";
}

class Song extends SongBase {
  final List<LyricsLine> lyrics;

  const Song({
    required super.songName,
    required super.singerName,
    required super.albumName,
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
      songName: map['songName'] as String,
      singerName: map['singerName'] as String,
      albumName: map['albumName'] as String,
      lyrics: (map['lyrics'] as List)
          .map<LyricsLine>(
            (x) => LyricsLine.fromJson(x as Map<String, dynamic>),
          )
          .toList(),
    );
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
