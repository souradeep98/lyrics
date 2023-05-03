part of structures;


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
