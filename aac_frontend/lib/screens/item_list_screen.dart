import 'package:aac_app/constants/app_strings.dart';
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
                  // TODO
                  print('Edit "${item.word}"');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(AppStrings.deleteItem),
                onTap: () {
                  Navigator.pop(bc);
                  // TODO
                  print('Delete "${item.word}"');
                },
              ),
              ListTile(
                leading: const Icon(Icons.drive_file_move),
                title: const Text(AppStrings.moveItem),
                onTap: () {
                  Navigator.pop(bc);
                  // TODO
                  print('Move "${item.word}"');
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

    return Scaffold(
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
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: category.items.length,
              itemBuilder: (context, index) {
                final item = category.items[index];
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
    );
  }
}
