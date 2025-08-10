class CommunicationItem {
  final int? id;
  final String imageUrl;
  final String word;

  CommunicationItem({
    this.id,
    required this.imageUrl,
    required this.word,
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
    );
  }

    CommunicationItem copyWith({
    int? id,
    String? imageUrl,
    String? word,
  }) {
    return CommunicationItem(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      word: word ?? this.word,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CommunicationItem && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
