import 'communication_item.dart';

class Category {
  final String id;
  final String name;
  final String imageUrl;
  final List<CommunicationItem> items;

  Category({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.items,
  });
}