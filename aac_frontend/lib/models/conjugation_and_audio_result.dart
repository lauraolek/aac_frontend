import 'package:aac_app/models/communication_item.dart';

class ConjugationAndAudioResult {
  final List<CommunicationItem> conjugatedWords;
  final String audioBase64;

  ConjugationAndAudioResult({
    required this.conjugatedWords,
    required this.audioBase64,
  });

  factory ConjugationAndAudioResult.fromJson(Map<String, dynamic> json) {
    final words = (json['conjugatedWords'] as List<dynamic>?)
        ?.map((e) => CommunicationItem.fromMap(e))
        .toList() ?? [];

    return ConjugationAndAudioResult(
      conjugatedWords: words,
      audioBase64: json['audioBytes'],
    );
  }
}