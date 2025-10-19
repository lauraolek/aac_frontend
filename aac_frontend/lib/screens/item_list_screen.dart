import 'package:aac_app/constants/app_strings.dart';
import 'package:aac_app/providers/profile_provider.dart';
import 'package:aac_app/widgets/add_item_dialog.dart';
import 'package:aac_app/widgets/edit_item_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/communication_item.dart';
import '../providers/communication_provider.dart';
import '../widgets/communication_item_card.dart';

class ItemListScreen extends StatelessWidget {
  final Category category;
  final VoidCallback onNavigateBack;

  const ItemListScreen({
    super.key,
    required this.category,
    required this.onNavigateBack,
  });

  void _showItemOptions(BuildContext context, CommunicationItem item) {
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
                title: const Text(AppStrings.editItem),
                onTap: () {
                  Navigator.pop(bc);
                  showDialog(
                    context: context,
                    builder: (dialogContext) => EditItemDialog(
                      item: item,
                      onEditItem: (newWord, newImageFile) async {
                        await profileProvider.editItemInCategory(
                          category.id!,
                          item.id!,
                          newWord,
                          newImageFile: newImageFile,
                          currentImageUrl: item.imageUrl,
                        );
                      },
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(AppStrings.deleteItem),
                onTap: () {
                  Navigator.pop(bc);
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text(AppStrings.deleteItem),
                      content: Text(AppStrings.deleteItemConfirmation(item.word)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text(AppStrings.cancelButton),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await profileProvider.deleteItemFromCategory(category.id!, item.id!);
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
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final communicationProvider = Provider.of<CommunicationProvider>(
      context,
      listen: false,
    );
    final profileProvider = Provider.of<ProfileProvider>(context);

    final currentCategoryInProfile = profileProvider.activeChild?.categories.firstWhere(
      (cat) => cat.id == category.id,
      orElse: () => category, // fallback if category was deleted or child changed
    );
    final List<CommunicationItem> items = currentCategoryInProfile?.items ?? [];


    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          onNavigateBack();
        }
      },
      child: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: LayoutBuilder(
          // https://medium.com/@rk0936626/use-responsive-grid-in-flutter-that-adjust-itself-based-on-screen-size-65b91c049fb0
          builder: (context, constraints) {
            final int columns = (constraints.maxWidth / 150)
                .floor()
                .clamp(1, double.infinity)
                .toInt();

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                childAspectRatio: 0.8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return CommunicationItemCard(
                  item: item,
                  onTap: () {
                    communicationProvider.addItem(item);
                  },
                  onLongPress: () => _showItemOptions(context, item),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AddItemDialog(
                onAddItem: (word, imageFile) async {
                  await profileProvider.addItemToCategory(category.id!, word, pickedImage: imageFile);
                },
              ),
            );
          },
          child: const Icon(Icons.add),
          backgroundColor: Colors.green,
        ),
    ),
    );
  }
}
