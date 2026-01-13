import 'package:aac_app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import '../models/communication_item.dart';

class CommunicationItemCard extends StatelessWidget {
  final CommunicationItem item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback? onDoubleTap;

  const CommunicationItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onLongPress,
    this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      onDoubleTap: onDoubleTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  AppStrings.imageUrl + item.imageUrl,
                  fit: BoxFit.fitHeight,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback for image loading errors
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.broken_image,
                        size: 40,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: Text(
                item.displayedWord ?? item.word,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
