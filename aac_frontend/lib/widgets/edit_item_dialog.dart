import 'dart:async';

import 'package:aac_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'dart:io';
import '../constants/app_strings.dart';
import '../models/communication_item.dart';

typedef EditItemCallback =
    void Function(
      String word,
      String? wordOsastav,
      XFile? imageFile,
      int rotationTurns,
    );

class EditItemDialog extends StatefulWidget {
  final CommunicationItem item;
  final ApiService apiService;
  final EditItemCallback onEditItem;

  const EditItemDialog({
    super.key,
    required this.item,
    required this.apiService,
    required this.onEditItem,
  });

  @override
  _EditItemDialogState createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _wordController;
  late TextEditingController _osastavController;
  List<String> _suggestions = [];
  Timer? _debounce;

  int _rotationTurns = 0;
  XFile? _pickedImage;
  Uint8List? _imageBytes; // for web image preview
  late String _currentImageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _wordController = TextEditingController(text: widget.item.word);
    _osastavController = TextEditingController(
      text: widget.item.wordOsastav ?? '',
    );
    _currentImageUrl = widget.item.imageUrl;
    _rotationTurns = 0;
  }

  void _onWordChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 600), () async {
      if (val.length < 2) {
        setState(() => _suggestions = []);
        return;
      }

      final results = await widget.apiService.getPartitiveSuggestions(val);

      if (mounted) {
        setState(() {
          _suggestions = results;
          if (_suggestions.isNotEmpty) {
            _osastavController.text = _suggestions.first;
          } else {
            _osastavController.clear();
          }
        });
      }
    });
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
      _rotationTurns = 0;
    });
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      await _processPickedImage(pickedFile);
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 85,
    );
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
    _wordController.dispose();
    _osastavController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget imagePreviewWidget;
    if (_pickedImage != null) {
      Widget visualImage;
      if (kIsWeb) {
        visualImage = Image.memory(
          _imageBytes!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(
                Icons.broken_image,
                size: 50,
                color: Colors.grey,
              ),
            );
          },
        );
      } else {
        visualImage = Image.file(
          File(_pickedImage!.path),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(
                Icons.broken_image,
                size: 50,
                color: Colors.grey,
              ),
            );
          },
        );
      }
      imagePreviewWidget = RotatedBox(
        quarterTurns: _rotationTurns,
        child: visualImage,
      );
    } else if (_currentImageUrl.isNotEmpty) {
      imagePreviewWidget = RotatedBox(
        quarterTurns: _rotationTurns,
        child: Image.network(
          _currentImageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(
                Icons.broken_image,
                size: 50,
                color: Colors.grey,
              ),
            );
          },
        ),
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
                onChanged: _onWordChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.enterItemWord;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // 2. SUGGESTIONS CHIPS
              if (_suggestions.isNotEmpty) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppStrings.grammarSuggestionTitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8.0,
                  children: _suggestions
                      .map(
                        (sug) => ChoiceChip(
                          label: Text(sug),
                          selected: _osastavController.text == sug,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _osastavController.text = sug);
                            }
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],

              // 3. GRAMMAR FORM (Osastav/-da)
              TextFormField(
                controller: _osastavController,
                decoration: InputDecoration(
                  labelText: AppStrings.grammarFormLabel,
                  helperText: AppStrings.grammarFormHelper,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: null,
              ),
              const SizedBox(height: 16),

              // 4. IMAGE PREVIEW
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _rotationTurns = (_rotationTurns + 1) % 4;
                        });
                      },
                      icon: const Icon(Icons.rotate_right),
                      label: const Text(AppStrings.turnPhoto),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _pickedImage = null;
                          _imageBytes = null;
                          _currentImageUrl = '';
                          _rotationTurns = 0;
                        });
                      },
                      child: const Text(AppStrings.removeImage),
                    ),
                  ],
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
              String? osastavValue = _osastavController.text.trim();
              if (osastavValue.isEmpty) osastavValue = null;

              widget.onEditItem(
                _wordController.text,
                osastavValue,
                _pickedImage,
                _rotationTurns,
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
