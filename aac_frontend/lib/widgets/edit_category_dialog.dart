import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../constants/app_strings.dart';
import '../models/category.dart';

typedef EditCategoryCallback = void Function(String name, XFile? imageFile);

class EditCategoryDialog extends StatefulWidget {
  final Category category;
  final EditCategoryCallback onEditCategory;

  const EditCategoryDialog({
    super.key,
    required this.category,
    required this.onEditCategory,
  });

  @override
  _EditCategoryDialogState createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  XFile? _pickedImage;
  Uint8List? _imageBytes; // for web image preview
  late String _currentImageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _currentImageUrl = widget.category.imageUrl;
  }


  Future<void> _processPickedImage(XFile pickedFile) async {
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

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await _processPickedImage(pickedFile);
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      await _processPickedImage(pickedFile);
    }
  }

  void _showSourceSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(AppStrings.selectImageSource),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text(AppStrings.gallery),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text(AppStrings.camera),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
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
    } else if (_currentImageUrl.isNotEmpty) {
      imagePreviewWidget = Image.network(
        AppStrings.baseUrl + _currentImageUrl,
        fit: BoxFit.fitHeight,
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
            Text(AppStrings.pickImageOrCapture),
          ],
        ),
      );
    }

    return AlertDialog(
      shape: Theme.of(context).dialogTheme.shape,
      title: const Text(AppStrings.editCategory),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: AppStrings.categoryName,
                  hintText: AppStrings.enterCategoryName,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.enterCategoryName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _showSourceSelectionDialog(context),
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
              widget.onEditCategory(
                _nameController.text,
                _pickedImage,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text(AppStrings.editCategory),
        ),
      ],
    );
  }
}