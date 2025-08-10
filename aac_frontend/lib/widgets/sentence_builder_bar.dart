import 'package:aac_app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/communication_provider.dart';
import '../widgets/communication_item_card.dart';

class SentenceBuilderBar extends StatefulWidget {
  const SentenceBuilderBar({super.key});

  @override
  State<SentenceBuilderBar> createState() => _SentenceBuilderBarState();
}

class _SentenceBuilderBarState extends State<SentenceBuilderBar> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showClearConfirmationDialog(
    BuildContext context,
    CommunicationProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(AppStrings.clearAllItemsDialogTitle),
          content: const Text(AppStrings.clearAllItemsDialogContent),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                AppStrings.cancelButton,
                style: TextStyle(color: Colors.blueGrey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                provider.clearAllItems();
                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                AppStrings.clearAllButton,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunicationProvider>(
      builder: (context, communicationProvider, child) {
        return Container(
          height: 175,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border(
              top: BorderSide(color: Colors.blue.shade200, width: 2),
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, -4), // Shadow on top
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: _scrollController,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    itemCount: communicationProvider.selectedItems.length,
                    itemBuilder: (context, index) {
                      final item = communicationProvider.selectedItems[index];
                      return Padding(
                        padding: const EdgeInsets.all(4),
                        child: SizedBox(
                          width: 100,
                          height: 125,
                          child: CommunicationItemCard(
                            item: item,
                            onTap: () {
                              // TODO
                            },
                            onLongPress: () {},
                            onDoubleTap: () {
                              communicationProvider.removeItem(item.id!);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: communicationProvider.undoLastItem,
                      icon: const Icon(Icons.undo),
                      label: const Text(AppStrings.undoButton),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade400,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showClearConfirmationDialog(
                        context,
                        communicationProvider,
                      ),
                      icon: const Icon(Icons.delete_forever),
                      label: const Text(AppStrings.clearAllButton),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: communicationProvider.speakSentence,
                      icon: const Icon(Icons.volume_up),
                      label: const Text(AppStrings.speakButton),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
