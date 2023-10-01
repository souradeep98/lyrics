part of '../structures.dart';

class LyricsLine {
  final Duration duration;
  final String line;
  final Duration startPosition;
  final String? translation;

  const LyricsLine({
    required this.duration,
    required this.line,
    required this.translation,
    required this.startPosition,
  });

  const LyricsLine.empty({
    this.duration = Duration.zero,
    this.startPosition = Duration.zero,
  })  : line = '',
        translation = null;

  Map<String, dynamic> toJson() {
    return {
      'duration': duration.toString(),
      'line': line,
    };
  }

  factory LyricsLine.fromJson(
    Map<String, dynamic> map,
    Duration lastStartPosition,
  ) {
    final Duration duration = parseTime(map['duration'] as String);
    return LyricsLine(
      duration: duration,
      line: map['line'] as String,
      translation: map['translation'] as String?,
      startPosition: lastStartPosition + duration,
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
  static List<LyricsLine> listFromRawJson(String rawJson) {
    final List<Map<String, dynamic>> maps =
        (jsonDecode(rawJson) as List).cast<Map<String, dynamic>>();

    return listFromListOfMaps(maps);
  }

  @pragma("vm:entry-point")
  static List<LyricsLine> listFromListOfMaps(List<Map<String, dynamic>> maps) {
    final List<LyricsLine> result = [];

    for (final Map<String, dynamic> map in maps) {
      result.add(
        LyricsLine.fromJson(
          map,
          result.lastOrNull?.startPosition ?? Duration.zero,
        ),
      );
    }

    return result;
  }

  @pragma("vm:entry-point")
  static String listToRawJson(List<LyricsLine> lyrics) =>
      jsonEncode(lyrics.map<Map<String, dynamic>>((e) => e.toJson()).toList());

  @override
  String toString() => 'LyricsLine: [$startPosition] - $line - ($translation) [+$duration]';

  LyricsLine copyWith({
    Duration? duration,
    Duration? startPosition,
    String? line,
    String? translation,
  }) {
    return LyricsLine(
      duration: duration ?? this.duration,
      line: line ?? this.line,
      translation: translation ?? this.translation,
      startPosition: startPosition ?? this.startPosition,
    );
  }

  LyricsLine withTranslation(
    String translation,
  ) {
    return LyricsLine(
      duration: duration,
      line: line,
      translation: translation,
      startPosition: startPosition,
    );
  }
}
