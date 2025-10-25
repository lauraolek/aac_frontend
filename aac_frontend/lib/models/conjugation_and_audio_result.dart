class ConjugationAndAudioResult {
  final List<String> conjugatedWords;
  final String audioBase64;

  ConjugationAndAudioResult({
    required this.conjugatedWords,
    required this.audioBase64,
  });

  factory ConjugationAndAudioResult.fromJson(Map<String, dynamic> json) {
    final words = (json['conjugatedWords'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ?? [];

    return ConjugationAndAudioResult(
      conjugatedWords: words,
      audioBase64: json['audioBytes'],
    );
  }
}