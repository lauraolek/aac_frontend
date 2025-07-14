class CommunicationItem {
  final String id;
  final String imageUrl;
  final String word;

  CommunicationItem({
    required this.id,
    required this.imageUrl,
    required this.word,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CommunicationItem && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
