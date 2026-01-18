import 'category.dart';

class Profile {
  final int? id;
  final String name;
  List<Category> categories;

  Profile({
    this.id,
    required this.name,
    required this.categories,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'categories': categories.map((cat) => cat.toMap()).toList(),
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as int,
      name: map['name'] as String,
      categories:
          (map['categories'] as List<dynamic>?)
              ?.map((item) => Category.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Profile copyWith({
    int? id,
    String? name,
    List<Category>? categories,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      categories: categories ?? this.categories,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Profile && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
