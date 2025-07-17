import 'package:flutter/material.dart';
import '../models/child_profile.dart';
import '../models/communication_item.dart';
import '../services/api_service.dart';

class ProfileProvider with ChangeNotifier {
  final ApiService _apiService;
  List<ChildProfile> _childProfiles = [];
  ChildProfile? _activeChild;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  ProfileProvider(this._apiService) {
    _fetchChildProfiles();
  }

  List<ChildProfile> get childProfiles => List.unmodifiable(_childProfiles);
  ChildProfile? get activeChild => _activeChild;

  Future<void> _fetchChildProfiles() async {
    _isLoading = true;
    notifyListeners(); // to show loading indicator

    print('ProfileProvider: Fetching child profiles...');
    _childProfiles = await _apiService.fetchChildProfiles();
    print('ProfileProvider: Fetched ${_childProfiles.length} profiles.');

    // if no active child and profiles exist, set the first one as active
    if (_activeChild == null && _childProfiles.isNotEmpty) {
      _activeChild = _childProfiles.first;
      print('ProfileProvider: Set active child to ${_activeChild!.name}');
    } else if (_activeChild != null && !_childProfiles.any((profile) => profile.id == _activeChild!.id)) {
      // if active child was deleted, reset it
      _activeChild = _childProfiles.isNotEmpty ? _childProfiles.first : null;
      print('ProfileProvider: Active child reset after deletion.');
    } else if (_activeChild != null) {
      // if active child still exists, ensure it's updated with latest data
      _activeChild = _childProfiles.firstWhere(
        (profile) => profile.id == _activeChild!.id,
        orElse: () => _activeChild!, // fallback, should not happen if logic is correct
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addChild(ChildProfile profile) async {
    print('ProfileProvider: Adding child ${profile.name}...');
    await _apiService.addChildProfile(profile);
    await _fetchChildProfiles();
    print('ProfileProvider: Child ${profile.name} added and state refreshed.');
  }

  Future<void> deleteChild(int childId) async {
    print('ProfileProvider: Deleting child $childId...');
    await _apiService.deleteChildProfile(childId);
    await _fetchChildProfiles();
    print('ProfileProvider: Child $childId deleted and state refreshed.');
  }

  void setActiveChild(ChildProfile? profile) {
    _activeChild = profile;
    notifyListeners();
    print('ProfileProvider: Active child set to ${profile?.name ?? 'null'}.');
  }

  // --- Category Management for Active Child (via API service) ---

  Future<void> addCategory(String categoryName, {dynamic pickedImage}) async {
    if (_activeChild != null) {
      String imageUrl;
      if (pickedImage != null) {
        // TODO: upload imageFile/imageBytes to a storage service and get the public URL
        print('ProfileProvider: Simulating image upload for category "$categoryName".');
        imageUrl = 'https://placehold.co/150x150/00FF00/FFFFFF?text=Custom+${categoryName.substring(0, 1).toUpperCase()}';
      } else {
        imageUrl = 'https://placehold.co/150x150/CCCCCC/000000?text=Category';
      }

      print('ProfileProvider: Adding category $categoryName for child ${_activeChild!.name}...');
      await _apiService.addCategory(_activeChild!.id, categoryName, imageUrl);
      await _fetchChildProfiles();
      print('ProfileProvider: Category $categoryName added for child ${_activeChild!.name} and state refreshed.');
    } else {
      print('ProfileProvider: No active child to add category to.');
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    if (_activeChild != null) {
      print('ProfileProvider: Deleting category $categoryId for child ${_activeChild!.name}...');
      await _apiService.deleteCategory(_activeChild!.id, categoryId);
      await _fetchChildProfiles();
      print('ProfileProvider: Category $categoryId deleted for child ${_activeChild!.name} and state refreshed.');
    } else {
      print('ProfileProvider: No active child to delete category from.');
    }
  }

  Future<void> editCategory(int categoryId, String newName, String newImageUrl) async {
    if (_activeChild != null) {
      print('ProfileProvider: Editing category $categoryId for child ${_activeChild!.name}...');
      await _apiService.editCategory(_activeChild!.id, categoryId, newName, newImageUrl);
      await _fetchChildProfiles();
      print('ProfileProvider: Category $categoryId edited for child ${_activeChild!.name} and state refreshed.');
    } else {
      print('ProfileProvider: No active child to edit category for.');
    }
  }

  // --- Item Management for Active Child's Categories (via API service) ---

  Future<void> addItemToCategory(int categoryId, String word, {dynamic pickedImage}) async {
    if (_activeChild != null) {
      String imageUrl;
      if (pickedImage != null) {
        // TODO: upload imageFile/imageBytes to a storage service and get the public URL
        print('ProfileProvider: Simulating image upload for item "$word".');
        imageUrl = 'https://placehold.co/100x100/0000FF/FFFFFF?text=Custom+${word.substring(0, 1).toUpperCase()}';
      } else {
        imageUrl = 'https://placehold.co/100x100/CCCCCC/000000?text=Item';
      }
      // TODO: edit this
      final newItemId = DateTime.now().millisecondsSinceEpoch;
      final newItem = CommunicationItem(id: newItemId, word: word, imageUrl: imageUrl);

      print('ProfileProvider: Adding item ${newItem.word} to category $categoryId for child ${_activeChild!.name}...');
      await _apiService.addItemToCategory(_activeChild!.id, categoryId, newItem);
      await _fetchChildProfiles();
      print('ProfileProvider: Item ${newItem.word} added to category $categoryId and state refreshed.');
    } else {
      print('ProfileProvider: No active child to add item to.');
    }
  }

  Future<void> deleteItemFromCategory(int categoryId, int itemId) async {
    if (_activeChild != null) {
      print('ProfileProvider: Deleting item $itemId from category $categoryId for child ${_activeChild!.name}...');
      await _apiService.deleteItemFromCategory(_activeChild!.id, categoryId, itemId);
      await _fetchChildProfiles();
      print('ProfileProvider: Item $itemId deleted from category $categoryId and state refreshed.');
    } else {
      print('ProfileProvider: No active child to delete item from.');
    }
  }

  Future<void> editItemInCategory(int categoryId, int itemId, String newWord, String newImageUrl) async {
    if (_activeChild != null) {
      print('ProfileProvider: Editing item $itemId in category $categoryId for child ${_activeChild!.name}...');
      await _apiService.editItemInCategory(_activeChild!.id, categoryId, itemId, newWord, newImageUrl);
      await _fetchChildProfiles();
      print('ProfileProvider: Item $itemId edited in category $categoryId and state refreshed.');
    } else {
      print('ProfileProvider: No active child to edit item for.');
    }
  }
}