import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile.dart';
import '../services/api_service.dart';

class ProfileProvider with ChangeNotifier {
  ApiService _apiService;
  List<Profile> _profiles = [];
  Profile? _activeProfile;
  bool _isLoading = false;
  String? _authToken;

  bool get isLoading => _isLoading;
  List<Profile> get profiles => List.unmodifiable(_profiles);
  Profile? get activeProfile => _activeProfile;
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
      await _fetchProfiles();
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
      await _fetchProfiles();
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
    _profiles = [];
    _activeProfile = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchProfiles() async {
    if (!isAuthenticated) {
      print('ProfileProvider: Not logged in. Cannot fetch profiles.');
      _profiles = [];
      _activeProfile = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      print('ProfileProvider: Fetching profiles...');
      _profiles = await _apiService.fetchProfiles();
      print('ProfileProvider: Fetched ${_profiles.length} profiles.');

      if (_activeProfile == null && _profiles.isNotEmpty) {
        _activeProfile = _profiles.first;
        print('ProfileProvider: Set active profile to ${_activeProfile!.name}');
      } else if (_activeProfile != null && !_profiles.any((profile) => profile.id == _activeProfile!.id)) {
        _activeProfile = _profiles.isNotEmpty ? _profiles.first : null;
        print('ProfileProvider: Active profile reset after deletion/not found.');
      } else if (_activeProfile != null) {
        _activeProfile = _profiles.firstWhere(
          (profile) => profile.id == _activeProfile!.id,
          orElse: () => _activeProfile!,
        );
      }
    } catch (e) {
      print('ProfileProvider Error: Failed to fetch profiles: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProfile(Profile profile) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newProfile = await _apiService.addProfile(profile);
      _profiles.add(newProfile);
      setActiveProfile(newProfile);
      await _fetchProfiles();
      print('ProfileProvider: Profile ${profile.name} added and state refreshed.');
    } catch (e) {
      print('ProfileProvider Error: Failed to add profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProfile(int profileId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.deleteProfile(profileId);
      await _fetchProfiles();
      print('ProfileProvider: Profile $profileId deleted and state refreshed.');
    } catch (e) {
      print('ProfileProvider Error: Failed to delete profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setActiveProfile(Profile? profile) {
    if (_activeProfile?.id != profile?.id) {
      _activeProfile = profile;
      notifyListeners();
      print('ProfileProvider: Active profile set to ${profile?.name ?? 'null'}.');
    }
  }

  // --- Category Management for Active Profile (via API service) ---

Future<void> addCategory(String categoryName, {XFile? pickedImage}) async {
    if (_activeProfile == null) {
      print('ProfileProvider: Not logged in or no active profile to add category to.');
      return;
    }

    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.addCategory(_activeProfile!.id!, categoryName, imageFile: pickedImage);
      await _fetchProfiles();
      print('ProfileProvider: Category $categoryName added for profile ${_activeProfile!.name} and state refreshed.');
    } catch (e) {
      print('ProfileProvider Error: Failed to add category: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    if (_activeProfile == null) {
      print('ProfileProvider: Not logged in or no active profile to delete category from.');
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.deleteCategory(_activeProfile!.id!, categoryId);
      await _fetchProfiles();
      print('ProfileProvider: Category $categoryId deleted for profile ${_activeProfile!.name} and state refreshed.');
    } catch (e) {
      print('ProfileProvider Error: Failed to delete category: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editCategory(int categoryId, String newName, {XFile? newImageFile, String? currentImageUrl}) async {
    if (_activeProfile == null) {
      print('ProfileProvider: Not logged in, or no active profile to edit category for.');
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.editCategory(
        _activeProfile!.id!,
        categoryId,
        newName,
        newImageFile: newImageFile,
        currentImageUrl: currentImageUrl,
      );
      await _fetchProfiles();
      print('ProfileProvider: Category $categoryId edited for profile ${_activeProfile!.name} and state refreshed.');
    } catch (e) {
      print('ProfileProvider Error: Failed to edit category: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Item Management for Active Profile's Categories (via API service) ---

  Future<void> addItemToCategory(int categoryId, String word, {XFile? pickedImage}) async {
    if (_activeProfile == null) {
      print('ProfileProvider: Not logged in or no active profile to add item to.');
      return;
    }

    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.addItemToCategory(_activeProfile!.id!, categoryId, word, imageFile: pickedImage);
      await _fetchProfiles();
      print('ProfileProvider: Item $word added to category $categoryId and state refreshed.');
    } catch (e) {
      print('ProfileProvider Error: Failed to add item: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteItemFromCategory(int categoryId, int itemId) async {
    if (_activeProfile == null) {
      print('ProfileProvider: Not logged in or no active profile to delete item from.');
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.deleteItemFromCategory(_activeProfile!.id!, categoryId, itemId);
      await _fetchProfiles();
      print('ProfileProvider: Item $itemId deleted from category $categoryId and state refreshed.');
    } catch (e) {
      print('ProfileProvider Error: Failed to delete item: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editItemInCategory(int categoryId, int itemId, String newWord, {XFile? newImageFile, String? currentImageUrl}) async {
    if (_activeProfile == null) {
      print('ProfileProvider: Not logged in or no active profile to edit item for.');
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.editItemInCategory(
        _activeProfile!.id!,
        categoryId,
        itemId,
        newWord,
        newImageFile: newImageFile,
        currentImageUrl: currentImageUrl,
      );
      await _fetchProfiles();
      print('ProfileProvider: Item $itemId edited in category $categoryId and state refreshed.');
    } catch (e) {
      print('ProfileProvider Error: Failed to edit item: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}