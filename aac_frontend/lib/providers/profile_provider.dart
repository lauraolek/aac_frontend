import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/child_profile.dart';
import '../services/api_service.dart';

class ProfileProvider with ChangeNotifier {
  ApiService _apiService;
  List<ChildProfile> _childProfiles = [];
  ChildProfile? _activeChild;
  bool _isLoading = false;
  String? _authToken;

  bool get isLoading => _isLoading;
  List<ChildProfile> get childProfiles => List.unmodifiable(_childProfiles);
  ChildProfile? get activeChild => _activeChild;
  bool get isAuthenticated => _authToken != null;

  ProfileProvider(this._apiService) {
    _loadAuthToken();
  }

  set apiService(ApiService apiService) {
    _apiService = apiService;
    notifyListeners();
  }

  Future<void> _loadAuthToken() async {
    _isLoading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('jwt_token');
    if (_authToken != null) {
      _apiService.setAuthToken(_authToken!);
      await _fetchChildProfiles();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    _authToken = token;
    _apiService.setAuthToken(token);
    notifyListeners();
  }

    Future<bool> register(String password, String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.registerUser(password, email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Registration failed: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.loginUser(email, password);
      await _saveAuthToken(response['token']);
      await _fetchChildProfiles();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Login failed: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _authToken = null;
    _apiService.clearAuthToken();
    _childProfiles = [];
    _activeChild = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchChildProfiles() async {
    if (!isAuthenticated) {
      print('ProfileProvider: Not logged in. Cannot fetch profiles.');
      _childProfiles = [];
      _activeChild = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('ProfileProvider: Fetching child profiles...');
      _childProfiles = await _apiService.fetchChildProfiles();
      print('ProfileProvider: Fetched ${_childProfiles.length} profiles.');

      if (_activeChild == null && _childProfiles.isNotEmpty) {
        _activeChild = _childProfiles.first;
        print('ProfileProvider: Set active child to ${_activeChild!.name}');
      } else if (_activeChild != null && !_childProfiles.any((profile) => profile.id == _activeChild!.id)) {
        _activeChild = _childProfiles.isNotEmpty ? _childProfiles.first : null;
        print('ProfileProvider: Active child reset after deletion/not found.');
      } else if (_activeChild != null) {
        _activeChild = _childProfiles.firstWhere(
          (profile) => profile.id == _activeChild!.id,
          orElse: () => _activeChild!,
        );
      }
    } catch (e) {
      print('ProfileProvider Error: Failed to fetch child profiles: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addChild(ChildProfile profile) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newProfile = await _apiService.addChildProfile(profile);
      _childProfiles.add(newProfile);
      setActiveChild(newProfile);
      await _fetchChildProfiles();
      print('ProfileProvider: Child ${profile.name} added and state refreshed.');
    } catch (e) {
      print('ProfileProvider Error: Failed to add child: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteChild(int childId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.deleteChildProfile(childId);
      await _fetchChildProfiles();
      print('ProfileProvider: Child $childId deleted and state refreshed.');
    } catch (e) {
      print('ProfileProvider Error: Failed to delete child: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setActiveChild(ChildProfile? profile) {
    if (_activeChild?.id != profile?.id) {
      _activeChild = profile;
      notifyListeners();
      print('ProfileProvider: Active child set to ${profile?.name ?? 'null'}.');
    }
  }

  // --- Category Management for Active Child (via API service) ---

Future<void> addCategory(String categoryName, {XFile? pickedImage}) async {
    if (_activeChild == null) {
      print('ProfileProvider: Not logged in or no active child to add category to.');
      return;
    }

    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.addCategory(_activeChild!.id!, categoryName, imageFile: pickedImage);
      await _fetchChildProfiles();
      print('ProfileProvider: Category $categoryName added for child ${_activeChild!.name} and state refreshed.');
    } catch (e) {
      print('ProfileProvider Error: Failed to add category: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    if (_activeChild == null) {
      print('ProfileProvider: Not logged in or no active child to delete category from.');
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.deleteCategory(_activeChild!.id!, categoryId);
      await _fetchChildProfiles();
      print('ProfileProvider: Category $categoryId deleted for child ${_activeChild!.name} and state refreshed.');
    } catch (e) {
      print('ProfileProvider Error: Failed to delete category: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editCategory(int categoryId, String newName, {XFile? newImageFile, String? currentImageUrl}) async {
    if (_activeChild == null) {
      print('ProfileProvider: Not logged in, or no active child to edit category for.');
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.editCategory(
        _activeChild!.id!,
        categoryId,
        newName,
        newImageFile: newImageFile,
        currentImageUrl: currentImageUrl,
      );
      await _fetchChildProfiles();
      print('ProfileProvider: Category $categoryId edited for child ${_activeChild!.name} and state refreshed.');
    } catch (e) {
      print('ProfileProvider Error: Failed to edit category: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Item Management for Active Child's Categories (via API service) ---

  Future<void> addItemToCategory(int categoryId, String word, {XFile? pickedImage}) async {
    if (_activeChild == null) {
      print('ProfileProvider: Not logged in or no active child to add item to.');
      return;
    }

    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.addItemToCategory(_activeChild!.id!, categoryId, word, imageFile: pickedImage);
      await _fetchChildProfiles();
      print('ProfileProvider: Item $word added to category $categoryId and state refreshed.');
    } catch (e) {
      print('ProfileProvider Error: Failed to add item: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteItemFromCategory(int categoryId, int itemId) async {
    if (_activeChild == null) {
      print('ProfileProvider: Not logged in or no active child to delete item from.');
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.deleteItemFromCategory(_activeChild!.id!, categoryId, itemId);
      await _fetchChildProfiles();
      print('ProfileProvider: Item $itemId deleted from category $categoryId and state refreshed.');
    } catch (e) {
      print('ProfileProvider Error: Failed to delete item: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editItemInCategory(int categoryId, int itemId, String newWord, {XFile? newImageFile, String? currentImageUrl}) async {
    if (_activeChild == null) {
      print('ProfileProvider: Not logged in or no active child to edit item for.');
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.editItemInCategory(
        _activeChild!.id!,
        categoryId,
        itemId,
        newWord,
        newImageFile: newImageFile,
        currentImageUrl: currentImageUrl,
      );
      await _fetchChildProfiles();
      print('ProfileProvider: Item $itemId edited in category $categoryId and state refreshed.');
    } catch (e) {
      print('ProfileProvider Error: Failed to edit item: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}