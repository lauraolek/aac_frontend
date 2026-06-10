import 'dart:async';
import 'dart:io';
import 'package:aac_app/services/api_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_strings.dart';

typedef AddItemCallback =
    void Function(
      String word,
      String? wordOsastav,
      XFile? imageFile,
      int imageRotationTurns,
    );

class AddItemDialog extends StatefulWidget {
  final AddItemCallback onAddItem;
  final ApiService apiService;

  const AddItemDialog({
    super.key,
    required this.onAddItem,
    required this.apiService,
  });

  @override
  _AddItemDialogState createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _osastavController = TextEditingController();
  bool _showImageError = false;
  List<String> _suggestions = [];
  Timer? _debounce;

  XFile? _pickedImage;
  Uint8List? _imageBytes;
  int _rotationTurns = 0; // Tracks manual rotations: 0 = 0°, 1 = 90°, 2 = 180°, 3 = 270°
  final ImagePicker _picker = ImagePicker();

  void _onWordChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 600), () async {
      if (val.trim().length < 2) {
        setState(() {
          _suggestions = [];
          _osastavController.clear();
        });
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
      _showImageError = false;
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

      // Wraps visual target inside RotatedBox matching the user turns
      imagePreviewWidget = RotatedBox(
        quarterTurns: _rotationTurns,
        child: visualImage,
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
      title: const Text(AppStrings.addItem),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _wordController,
                decoration: const InputDecoration(
                  labelText: AppStrings.itemWord,
                  hintText: AppStrings.itemWordHint,
                ),
                onChanged: _onWordChanged,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.enterItemWord;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 2. SUGGESTIONS CHIPS
              if (_suggestions.isNotEmpty) ...[
                const Text(
                  AppStrings.grammarSuggestionTitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
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

              // 3. PARTITIVE OVERRIDE (Osastav)
              TextFormField(
                controller: _osastavController,
                decoration: const InputDecoration(
                  labelText: AppStrings.grammarFormLabel,
                  helperText: AppStrings.grammarFormHelper,
                ),
                validator: null,
              ),
              const SizedBox(height: 16),

              // Material + InkWell implementation for accessibility with keyboard
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() => _showImageError = false);
                    _showSourceSelectionDialog(context);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Ink(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _showImageError
                            ? Colors.red.shade900
                            : Colors.grey,
                        width: _showImageError ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imagePreviewWidget,
                    ),
                  ),
                ),
              ),
              if (_showImageError)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    AppStrings.imageRequired,
                    style: TextStyle(color: Colors.red.shade900, fontSize: 14),
                  ),
                ),

              if (_pickedImage != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Manual Rotation Button
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _rotationTurns = (_rotationTurns + 1) % 4;
                        });
                      },
                      icon: const Icon(Icons.rotate_right),
                      label: const Text(AppStrings.turnPhoto),
                    ),
                    // Remove Image Button
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _pickedImage = null;
                          _imageBytes = null;
                          _rotationTurns = 0;
                        });
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text(
                        AppStrings.removeImage,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
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
            final isFormValid = _formKey.currentState!.validate();
            final hasImage = _pickedImage != null;

            if (!hasImage) {
              setState(() => _showImageError = true);
            }

            if (isFormValid && hasImage) {
              String? osastavValue = _osastavController.text.trim();
              if (osastavValue.isEmpty) osastavValue = null;

              widget.onAddItem(
                _wordController.text.trim(),
                osastavValue,
                _pickedImage,
                _rotationTurns,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text(AppStrings.addButton),
        ),
      ],
    );
  }
}
