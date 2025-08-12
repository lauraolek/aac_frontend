import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'dart:io';
import '../constants/app_strings.dart';
import '../models/communication_item.dart';

typedef EditItemCallback = void Function(String word, XFile? imageFile);

class EditItemDialog extends StatefulWidget {
  final CommunicationItem item;
  final EditItemCallback onEditItem;

  const EditItemDialog({
    super.key,
    required this.item,
    required this.onEditItem,
  });

  @override
  _EditItemDialogState createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _wordController;
  XFile? _pickedImage;
  Uint8List? _imageBytes; // for web image preview
  late String _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _wordController = TextEditingController(text: widget.item.word);
    _currentImageUrl = widget.item.imageUrl;
  }

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
        _currentImageUrl = '';
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
          fit: BoxFit.cover,
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
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
            );
          },
        );
      }
    } else if (_currentImageUrl.isNotEmpty) {
      imagePreviewWidget = Image.network(
        AppStrings.baseUrl + _currentImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
          );
        },
      );
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
      shape: Theme.of(context).dialogTheme.shape,
      title: const Text(AppStrings.editItem),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _wordController,
                decoration: InputDecoration(
                  labelText: AppStrings.itemWord,
                  hintText: AppStrings.enterItemWord,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
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
              if (_pickedImage != null || _currentImageUrl.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _pickedImage = null;
                      _imageBytes = null;
                      _currentImageUrl = '';
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
              widget.onEditItem(
                _wordController.text,
                _pickedImage,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text(AppStrings.editItem),
        ),
      ],
    );
  }
}
