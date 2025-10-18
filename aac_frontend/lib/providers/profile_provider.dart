import 'dart:io';

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
  String? _userId;

  bool get isLoading => _isLoading;
  List<ChildProfile> get childProfiles => List.unmodifiable(_childProfiles);
  ChildProfile? get activeChild => _activeChild;
  bool get isAuthenticated => _authToken != null && _userId != null;
  String? get userId => _userId;

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
    _userId = prefs.getString('user_id');
    if (_authToken != null) {
      _apiService.setAuthToken(_authToken!);
    }

    if (_authToken != null && _userId != null) {
      await _fetchChildProfiles();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveAuthToken(String token, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await prefs.setString('user_id', userId);
    _authToken = token;
    _userId = userId;
    _apiService.setAuthToken(token);
    notifyListeners();
  }

  Future<void> register(String username, String password, String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.registerUser(username, password, email);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Registration failed: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> login(String usernameOrEmail, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.loginUser(usernameOrEmail, password);
      await _saveAuthToken(response['token'], response['userId']);
      await _fetchChildProfiles();
    } catch (e) {
      print('Login failed: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_id');
    _authToken = null;
    _userId = null;
    _apiService.clearAuthToken();
    _childProfiles.clear();
    _activeChild = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchChildProfiles() async {
    if (_userId == null) {
      print('ProfileProvider: Not logged in or userId is null. Cannot fetch profiles.');
      _childProfiles = [];
      _activeChild = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('ProfileProvider: Fetching child profiles for user $_userId...');
      _childProfiles = await _apiService.fetchChildProfiles(_userId!);
      print('ProfileProvider: Fetched ${_childProfiles.length} profiles for user $_userId.');

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
    if (_userId == null) {
      print('ProfileProvider: Not logged in or userId is null. Cannot add child.');
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final newProfile = await _apiService.addChildProfile(_userId!, profile);
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
    if (_userId == null) {
      print('ProfileProvider: Not logged in or userId is null. Cannot delete child.');
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.deleteChildProfile(_userId!, childId);
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
    if (_userId == null || _activeChild == null) {
      print('ProfileProvider: Not logged in, userId is null, or no active child to add category to.');
      return;
    }

    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.addCategory(_userId!, _activeChild!.id!, categoryName, imageFile: pickedImage);
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
    if (_userId == null || _activeChild == null) {
      print('ProfileProvider: Not logged in, userId is null, or no active child to delete category from.');
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.deleteCategory(_userId!, _activeChild!.id!, categoryId);
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
    if (_userId == null || _activeChild == null) {
      print('ProfileProvider: Not logged in, userId is null, or no active child to edit category for.');
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.editCategory(
        _userId!,
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
    if (_userId == null || _activeChild == null) {
      print('ProfileProvider: Not logged in, userId is null, or no active child to add item to.');
      return;
    }

    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.addItemToCategory(_userId!, _activeChild!.id!, categoryId, word, imageFile: pickedImage);
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
    if (_userId == null || _activeChild == null) {
      print('ProfileProvider: Not logged in, userId is null, or no active child to delete item from.');
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.deleteItemFromCategory(_userId!, _activeChild!.id!, categoryId, itemId);
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
    if (_userId == null || _activeChild == null) {
      print('ProfileProvider: Not logged in, userId is null, or no active child to edit item for.');
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.editItemInCategory(
        _userId!,
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