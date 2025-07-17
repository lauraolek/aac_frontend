import 'category.dart';

class ChildProfile {
  final int id;
  final String name;
  final List<Category> categories;

  ChildProfile({
    required this.id,
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

  factory ChildProfile.fromMap(Map<String, dynamic> map) {
    return ChildProfile(
      id: map['id'] as int,
      name: map['name'] as String,
      categories:
          (map['categories'] as List<dynamic>?)
              ?.map((item) => Category.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  ChildProfile copyWith({
    int? id,
    String? name,
    List<Category>? categories,
  }) {
    return ChildProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      categories: categories ?? this.categories,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ChildProfile && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
