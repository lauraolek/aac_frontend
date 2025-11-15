class CommunicationItem {
  final int? id;
  final String imageUrl;
  String word;
  int? sequence;
  String? conjugatedWord;
  String? displayedWord;

  CommunicationItem({
    this.id,
    required this.imageUrl,
    required this.word,
    this.sequence,
    this.conjugatedWord,
    this.displayedWord
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'word': word,
    };
  }

  factory CommunicationItem.fromMap(Map<String, dynamic> map) {
    return CommunicationItem(
      id: map['id'] as int,
      imageUrl: map['imageUrl'] as String,
      word: map['word'] as String,
      conjugatedWord: map['conjugatedWord'] as String?,
      displayedWord: map['displayedWord'] as String?
    );
  }

  CommunicationItem copyWith({
    int? id,
    String? imageUrl,
    String? word,
    int? sequence,
    String? conjugatedWord,
    String? displayedWord
  }) {
    return CommunicationItem(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      word: word ?? this.word,
      sequence: sequence ?? this.sequence,
      conjugatedWord: conjugatedWord ?? this.conjugatedWord,
      displayedWord: displayedWord ?? this.displayedWord
    );
  }

  @override
  String toString() => 'CommunicationItem(id: $id, word: $word, displayed: $displayedWord)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CommunicationItem && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
