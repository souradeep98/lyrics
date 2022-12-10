part of structures;

class LyricsLine {
  final Duration duration;
  final String line;

  const LyricsLine({
    required this.duration,
    required this.line,
  });

  const LyricsLine.empty({this.duration = Duration.zero}) : line = '';

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
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LyricsLine &&
        other.duration == duration &&
        other.line == line;
  }

  @override
  int get hashCode => duration.hashCode ^ line.hashCode;

  
  @pragma("vm:entry-point")
  static List<LyricsLine> listFromRawJson(String rawJson) =>
      (jsonDecode(rawJson) as List).map<LyricsLine>(
        (e) => LyricsLine.fromJson(e as Map<String, dynamic>),
      ).toList();

  
  @pragma("vm:entry-point")
  static String listToRawJson(List<LyricsLine> lyrics) =>
      jsonEncode(lyrics.map<Map<String, dynamic>>((e) => e.toJson()).toList());

  @override
  String toString() => 'LyricsLine: [$duration] - $line';
}
