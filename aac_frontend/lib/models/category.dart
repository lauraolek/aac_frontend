import 'communication_item.dart';

class Category {
  final int id;
  final String name;
  final String imageUrl;
  final List<CommunicationItem> items;

  Category({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String,
      items:
          (map['items'] as List<dynamic>?)
              ?.map(
                (item) =>
                    CommunicationItem.fromMap(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Category copyWith({
    int? id,
    String? name,
    String? imageUrl,
    List<CommunicationItem>? items,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      items: items ?? this.items,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Category && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
