import 'dart:convert';
import 'dart:io';
import 'package:aac_app/constants/app_strings.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/child_profile.dart';
import '../models/category.dart';
class ApiService {
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
    print('ApiService: Auth token set.');
  }

  void clearAuthToken() {
    _authToken = null;
    print('ApiService: Auth token cleared.');
  }

  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (includeAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // --- Authentication Endpoints ---

  Future<String> registerUser(String username, String password, String email) async {
    print('ApiService: Registering user $username...');
    final url = Uri.parse('${AppStrings.baseUrl}/users/register');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(includeAuth: false),
        body: json.encode({
          'username': username,
          'passwordHash': password,
          'email': email,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('ApiService: User registered successfully.');
        return 'Registration successful!';
      } else {
        final errorBody = json.decode(response.body);
        print('ApiService Error: Registration failed: ${response.statusCode} - ${errorBody['message']}');
        throw Exception(errorBody['message'] ?? 'Failed to register user');
      }
    } catch (e) {
      print('ApiService Exception during registration: $e');
      throw Exception('Network error or invalid response during registration: $e');
    }
  }

  Future<Map<String, dynamic>> loginUser(String usernameOrEmail, String password) async {
    print('ApiService: Logging in user $usernameOrEmail...');
    final url = Uri.parse('${AppStrings.baseUrl}/users/login');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(includeAuth: false),
        body: json.encode({
          'username': usernameOrEmail,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final token = responseData['token'];
        final userId = responseData['userId']?.toString();
        print('token ${token} userId ${userId}');
        if (token != null && userId != null) {
          _authToken = token;
          print('ApiService: User logged in successfully. Token received.');
          return {'token': token, 'userId': userId};
        } else {
          
          throw Exception('Login successful but token or userId missing from response.');
        }
      } else {
        final errorBody = json.decode(response.body);
        print('ApiService Error: Login failed: ${response.statusCode} - ${errorBody['message']}');
        throw Exception(errorBody['message'] ?? 'Failed to login');
      }
    } catch (e) {
      print('ApiService Exception during login: $e');
      throw Exception('Network error or invalid response during login: $e');
    }
  }

  // --- Child Profile Operations ---

  Future<List<ChildProfile>> fetchChildProfiles(String userId) async {
    print('ApiService: Fetching child profiles for user $userId...');
    final url = Uri.parse('${AppStrings.baseUrl}/profiles/user/$userId');
    try {
      final response = await http.get(url, headers: _getHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => ChildProfile.fromMap(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again.');
      } else {
        final errorBody = json.decode(response.body);
        print('ApiService Error: Fetching child profiles failed: ${response.statusCode} - ${errorBody['message']}');
        throw Exception(errorBody['message'] ?? 'Failed to fetch child profiles');
      }
    } catch (e) {
      print('ApiService Exception during fetchChildProfiles: $e');
      throw Exception('Network error or invalid response during fetch child profiles: $e');
    }
  }

  Future<void> addChildProfile(String userId, ChildProfile profile) async {
    print('ApiService: Adding child profile ${profile.name} for user $userId...');
    final url = Uri.parse('${AppStrings.baseUrl}/profiles/user/$userId');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: json.encode(profile.toMap()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('ApiService: Child profile added successfully.');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again.');
      } else {
        final errorBody = json.decode(response.body);
        print('ApiService Error: Adding child profile failed: ${response.statusCode} - ${errorBody['message']}');
        throw Exception(errorBody['message'] ?? 'Failed to add child profile');
      }
    } catch (e) {
      print('ApiService Exception during addChildProfile: $e');
      throw Exception('Network error or invalid response during add child profile: $e');
    }
  }

  Future<void> deleteChildProfile(String userId, int childId) async {
    print('ApiService: Deleting child profile $childId for user $userId...');
    final url = Uri.parse('${AppStrings.baseUrl}/profiles/$childId');
    try {
      final response = await http.delete(url, headers: _getHeaders());

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('ApiService: Child profile deleted successfully.');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again.');
      } else {
        final errorBody = json.decode(response.body);
        print('ApiService Error: Deleting child profile failed: ${response.statusCode} - ${errorBody['message']}');
        throw Exception(errorBody['message'] ?? 'Failed to delete child profile');
      }
    } catch (e) {
      print('ApiService Exception during deleteChildProfile: $e');
      throw Exception('Network error or invalid response during delete child profile: $e');
    }
  }

  // --- Category Operations ---

Future<List<Category>> fetchCategories(int profileId) async {
    print('ApiService: Fetching child profiles for profile $profileId...');
    final url = Uri.parse('${AppStrings.baseUrl}/categories/profile/${profileId.toString()}');
    try {
      final response = await http.get(url, headers: _getHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Category.fromMap(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again.');
      } else {
        final errorBody = json.decode(response.body);
        print('ApiService Error: Fetching categories failed: ${response.statusCode} - ${errorBody['message']}');
        throw Exception(errorBody['message'] ?? 'Failed to fetch categoriees');
      }
    } catch (e) {
      print('ApiService Exception during fetchCategories: $e');
      throw Exception('Network error or invalid response during fetch categoriees: $e');
    }
  }

  Future<void> addCategory(String userId, int childId, String categoryName, {XFile? imageFile}) async {
    print('ApiService: Adding category $categoryName to child $childId for user $userId...');
    final url = Uri.parse('${AppStrings.baseUrl}/categories/profile/$childId');

    final request = http.MultipartRequest('POST', url)
      ..headers.addAll({'Authorization': 'Bearer $_authToken'}) // multipart headers
      ..fields['name'] = categoryName;

    if (imageFile != null) {
      // fromBytes to handle both web and mobile files
      request.files.add(http.MultipartFile.fromBytes(
        'imageFile',
        await imageFile.readAsBytes(),
        filename: imageFile.name,
      ));
      print('ApiService: Adding category with image file: ${imageFile.name}');
    } else {
      print("imageURL");
      request.fields['imageUrl'] = 'https://placehold.co/150x150/CCCCCC/000000?text=Category';
      print('ApiService: Adding category with placeholder image URL.');
    }
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);


      if (response.statusCode == 200 || response.statusCode == 201) {
        print('ApiService: Category added successfully.');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again.');
      } else {
        final errorBody = json.decode(response.body);
        print('ApiService Error: Adding category failed: ${response.statusCode} - ${errorBody['message']}');
        throw Exception(errorBody['message'] ?? 'Failed to add category');
      }
    } catch (e) {
      print('ApiService Exception during addCategory: $e');
      throw Exception('Network error or invalid response during add category: $e');
    }
  }

  Future<void> deleteCategory(String userId, int childId, int categoryId) async {
    print('ApiService: Deleting category $categoryId from child $childId for user $userId...');
    final url = Uri.parse('${AppStrings.baseUrl}/categories/$categoryId');
    try {
      final response = await http.delete(url, headers: _getHeaders());

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('ApiService: Category deleted successfully.');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again.');
      } else {
        final errorBody = json.decode(response.body);
        print('ApiService Error: Deleting category failed: ${response.statusCode} - ${errorBody['message']}');
        throw Exception(errorBody['message'] ?? 'Failed to delete category');
      }
    } catch (e) {
      print('ApiService Exception during deleteCategory: $e');
      throw Exception('Network error or invalid response during delete category: $e');
    }
  }

  Future<void> editCategory(String userId, int childId, int categoryId, String newName, {XFile? newImageFile, String? currentImageUrl}) async {
    print('ApiService: Editing category $categoryId for child $childId for user $userId...');
    final url = Uri.parse('${AppStrings.baseUrl}/categories/$categoryId');

    final request = http.MultipartRequest('PUT', url)
      ..headers.addAll({'Authorization': 'Bearer $_authToken'})
      ..fields['name'] = newName;

    if (newImageFile != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        await newImageFile.readAsBytes(),
        filename: newImageFile.name,
      ));
      print('ApiService: Editing category with new image file: ${newImageFile.name}');
    } else {
      request.fields['imageUrl'] = currentImageUrl ?? 'https://placehold.co/150x150/CCCCCC/000000?text=Category';
      print('ApiService: Editing category without a new image, using current URL.');
    }
    
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('ApiService: Category edited successfully.');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again.');
      } else {
        final errorBody = json.decode(response.body);
        print('ApiService Error: Editing category failed: ${response.statusCode} - ${errorBody['message']}');
        throw Exception(errorBody['message'] ?? 'Failed to edit category');
      }
    } catch (e) {
      print('ApiService Exception during editCategory: $e');
      throw Exception('Network error or invalid response during edit category: $e');
    }
  }

  // --- Item Operations ---

  Future<void> addItemToCategory(String userId, int childId, int categoryId, String word, {XFile? imageFile}) async {
    print('ApiService: Adding item ${word} to category $categoryId for child $childId for user $userId...');
    final url = Uri.parse('${AppStrings.baseUrl}/imagewords/category/$categoryId');

    final request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Authorization': 'Bearer $_authToken!',
    });
    request.fields['word'] = word;

    if (imageFile != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'imageFile',
        await imageFile.readAsBytes(),
        filename: imageFile.name,
      ));
      print('ApiService: Adding item with image file: ${imageFile.name}');
    } else {
      request.fields['imageUrl'] = 'https://placehold.co/100x100/CCCCCC/000000?text=Item';
      print('ApiService: Adding item with placeholder image URL.');
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('ApiService: Item added successfully.');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again.');
      } else {
        final errorBody = json.decode(response.body);
        print('ApiService Error: Adding item failed: ${response.statusCode} - ${errorBody['message']}');
        throw Exception(errorBody['message'] ?? 'Failed to add item');
      }
    } catch (e) {
      print('ApiService Exception during addItemToCategory: $e');
      throw Exception('Network error or invalid response during add item: $e');
    }
  }

  Future<void> deleteItemFromCategory(String userId, int childId, int categoryId, int itemId) async {
    print('ApiService: Deleting item $itemId from category $categoryId for child $childId for user $userId...');
    final url = Uri.parse('${AppStrings.baseUrl}/imagewords/$itemId');
    try {
      final response = await http.delete(url, headers: _getHeaders());

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('ApiService: Item deleted successfully.');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again.');
      } else {
        final errorBody = json.decode(response.body);
        print('ApiService Error: Deleting item failed: ${response.statusCode} - ${errorBody['message']}');
        throw Exception(errorBody['message'] ?? 'Failed to delete item');
      }
    } catch (e) {
      print('ApiService Exception during deleteItemFromCategory: $e');
      throw Exception('Network error or invalid response during delete item: $e');
    }
  }

  Future<void> editItemInCategory(String userId, int childId, int categoryId, int itemId, String newWord, {File? newImageFile, String? currentImageUrl}) async {
    print('ApiService: Editing item $itemId in category $categoryId for child $childId for user $userId...');
    final url = Uri.parse('${AppStrings.baseUrl}/imagewords/$itemId');

    final request = http.MultipartRequest('PUT', url)
      ..headers.addAll(_getHeaders(includeAuth: true))
      ..fields['word'] = newWord;
    
    if (newImageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', newImageFile.path));
      print('ApiService: Editing item with new image file: ${newImageFile.path}');
    } else {
      request.fields['imageUrl'] = currentImageUrl ?? 'https://placehold.co/100x100/CCCCCC/000000?text=Item';
      print('ApiService: Editing item without a new image, using current URL.');
    }
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('ApiService: Item edited successfully.');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again.');
      } else {
        final errorBody = json.decode(response.body);
        print('ApiService Error: Editing item failed: ${response.statusCode} - ${errorBody['message']}');
        throw Exception(errorBody['message'] ?? 'Failed to edit item');
      }
    } catch (e) {
      print('ApiService Exception during editItemInCategory: $e');
      throw Exception('Network error or invalid response during edit item: $e');
    }
  }
}
