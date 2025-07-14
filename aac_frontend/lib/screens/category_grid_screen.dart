import 'package:aac_app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../models/category.dart';
import '../widgets/category_card.dart';

class CategoryGridScreen extends StatelessWidget {
  final Function(Category) onNavigateToItems;

  const CategoryGridScreen({super.key, required this.onNavigateToItems});

  void _showCategoryOptions(BuildContext context, Category category) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text(AppStrings.editCategory),
                onTap: () {
                  Navigator.pop(bc);
                  // TODO
                  print('Edit ${category.name}');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(AppStrings.deleteCategory),
                onTap: () {
                  Navigator.pop(bc);
                  // TODO
                  print('Delete ${category.name}');
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_photo_alternate),
                title: const Text(AppStrings.addImageToCategory),
                onTap: () {
                  Navigator.pop(bc);
                  // TODO
                  print('Add image to ${category.name}');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: LayoutBuilder(
        // https://medium.com/@rk0936626/use-responsive-grid-in-flutter-that-adjust-itself-based-on-screen-size-65b91c049fb0
        builder: (context, constraints) {
          final int columns = (constraints.maxWidth / 200)
              .floor()
              .clamp(1, double.infinity)
              .toInt();

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: dummyCategories.length,
            itemBuilder: (context, index) {
              final category = dummyCategories[index];
              return CategoryCard(
                category: category,
                onTap: () {
                  onNavigateToItems(category);
                },
                onLongPress: () => _showCategoryOptions(context, category),
              );
            },
          );
        },
      ),
    );
  }
}
