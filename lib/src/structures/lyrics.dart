part of '../structures.dart';

class LyricsLine {
  final Duration duration;
  final String line;
  final String? translation;

  const LyricsLine({
    required this.duration,
    required this.line,
    required this.translation,
  });

  const LyricsLine.empty({this.duration = Duration.zero})
      : line = '',
        translation = null;

  Map<String, dynamic> toJson() {
    return {
      'duration': duration.toString(),
      'line': line,
    };
  }

  factory LyricsLine.fromJson(Map<String, dynamic> map) {
    return LyricsLine(
      duration: parseTime(map['duration'] as String),
      line: map['line'] as String,
      translation: map['translation'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LyricsLine &&
        other.duration == duration &&
        other.line == line &&
        other.translation == translation;
  }

  @override
  int get hashCode => duration.hashCode ^ line.hashCode ^ translation.hashCode;

  @pragma("vm:entry-point")
  static List<LyricsLine> listFromRawJson(String rawJson) =>
      (jsonDecode(rawJson) as List)
          .map<LyricsLine>(
            (e) => LyricsLine.fromJson(e as Map<String, dynamic>),
          )
          .toList();

  @pragma("vm:entry-point")
  static String listToRawJson(List<LyricsLine> lyrics) =>
      jsonEncode(lyrics.map<Map<String, dynamic>>((e) => e.toJson()).toList());

  @override
  String toString() => 'LyricsLine: [$duration] - $line - ($translation)';

  LyricsLine copyWith({
    Duration? duration,
    String? line,
    String? translation,
  }) {
    return LyricsLine(
      duration: duration ?? this.duration,
      line: line ?? this.line,
      translation: translation ?? this.translation,
    );
  }

  LyricsLine withTranslation(
    String translation,
  ) {
    return LyricsLine(
      duration: duration,
      line: line,
      translation: translation,
    );
  }
}
