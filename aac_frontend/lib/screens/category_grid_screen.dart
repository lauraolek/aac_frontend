import 'package:aac_app/widgets/edit_category_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../widgets/category_card.dart';
import '../constants/app_strings.dart';
import '../providers/profile_provider.dart';
import '../widgets/add_category_dialog.dart';

class CategoryGridScreen extends StatelessWidget {
  final Function(Category) onNavigateToItems;

  const CategoryGridScreen({super.key, required this.onNavigateToItems});
  
  void _showCategoryOptions(BuildContext context, Category category) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

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
                  showDialog(
                    context: context,
                    builder: (dialogContext) => EditCategoryDialog(
                      category: category,
                      onEditCategory: (newName, newImageFile) async {
                        await profileProvider.editCategory(
                          category.id!,
                          newName,
                          newImageFile: newImageFile,
                          currentImageUrl: category.imageUrl,
                        );
                      },
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(AppStrings.deleteCategory),
                onTap: () {
                  Navigator.pop(bc);
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text(AppStrings.deleteCategory),
                      content: Text(AppStrings.deleteCategoryConfirmation(category.name)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text(AppStrings.cancelButton),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await profileProvider.deleteCategory(category.id!);
                            Navigator.pop(dialogContext);
                          },
                          child: const Text(AppStrings.deleteButton),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        ),
                      ],
                    ),
                  );
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
    final profileProvider = Provider.of<ProfileProvider>(context);
    final List<Category> categories = profileProvider.activeChild?.categories ?? [];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: 
        categories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.folder_open, size: 80, color: Colors.blueGrey),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AddCategoryDialog(
                                onAddCategory: (name, imageFile) async {
                                  await profileProvider.addCategory(name, pickedImage: imageFile);
                                },
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text(AppStrings.addCategory),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  )
                : 
        LayoutBuilder(
          // https://medium.com/@rk0936626/use-responsive-grid-in-flutter-that-adjust-itself-based-on-screen-size-65b91c049fb0
                    builder: (context, constraints) {
                      final int columns = (constraints.maxWidth / 200).floor().clamp(1, double.infinity).toInt();
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
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
      ),
      floatingActionButton: profileProvider.activeChild != null && categories.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AddCategoryDialog(
                    onAddCategory: (name, imageFile) async {
                      await profileProvider.addCategory(name, pickedImage: imageFile);
                    },
                  ),
                );
              },
              child: const Icon(Icons.add),
              backgroundColor: Colors.green,
            )
          : null,
    );
  }
}