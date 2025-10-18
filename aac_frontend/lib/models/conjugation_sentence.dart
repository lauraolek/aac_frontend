class ConjugationSentence {
  final String sentence;

  ConjugationSentence({required this.sentence});


  Map<String, dynamic> toMap() {
    return {
      'sentence': sentence,
    };
  }
  
  factory ConjugationSentence.fromMap(Map<String, dynamic> map) {
    return ConjugationSentence(sentence: map['sentence'] as String);
  }
}