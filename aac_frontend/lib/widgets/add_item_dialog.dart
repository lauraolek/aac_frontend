import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_strings.dart';

typedef AddItemCallback = void Function(String word, XFile? imageFile);

class AddItemDialog extends StatefulWidget {
  final AddItemCallback onAddItem;

  const AddItemDialog({
    super.key,
    required this.onAddItem,
  });

  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  XFile? _pickedImage;
  Uint8List? _imageBytes;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Uint8List? bytes;
      if (kIsWeb) {
        bytes = await pickedFile.readAsBytes();
      }

      setState(() {
        _pickedImage = pickedFile;
        _imageBytes = bytes;
      });
    }
  }

  @override
  void dispose() {
    _wordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget imagePreviewWidget;
    if (_pickedImage != null) {
      if (kIsWeb) {
        imagePreviewWidget = Image.memory(
          _imageBytes!,
          fit: BoxFit.fitHeight,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
            );
          },
        );
      } else {
        imagePreviewWidget = Image.file(
          File(_pickedImage!.path),
          fit: BoxFit.fitHeight,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
            );
          },
        );
      }
    } else {
      imagePreviewWidget = const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
            SizedBox(height: 8),
            Text(AppStrings.pickImage),
          ],
        ),
      );
    }

    return AlertDialog(
      title: const Text(AppStrings.addItem),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _wordController,
                decoration: const InputDecoration(labelText: AppStrings.itemWord),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.enterItemWord;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imagePreviewWidget,
                  ),
                ),
              ),
              if (_pickedImage != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _pickedImage = null;
                      _imageBytes = null;
                    });
                  },
                  child: const Text(AppStrings.removeImage),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancelButton),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onAddItem(_wordController.text, _pickedImage);
              Navigator.of(context).pop();
            }
          },
          child: const Text(AppStrings.addButton),
        ),
      ],
    );
  }
}
