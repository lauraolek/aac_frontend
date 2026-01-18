import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:aac_app/constants/app_strings.dart';
import 'package:aac_app/models/communication_item.dart';
import 'package:aac_app/models/conjugation_and_audio_result.dart';
import 'package:aac_app/models/conjugation_sentence.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/profile.dart';
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

  Future<String> registerUser(String password, String email) async {
    print('ApiService: Registering user $email...');
    final url = Uri.parse('${AppStrings.baseUrl}/users/register');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(includeAuth: false),
        body: json.encode({
          'password': password,
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

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    print('ApiService: Logging in user $email...');
    final url = Uri.parse('${AppStrings.baseUrl}/users/login');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(includeAuth: false),
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final token = responseData['token'];
        //final userId = responseData['userId']?.toString();
        print('token ${token}');
        if (token != null) {
          _authToken = token;
          print('ApiService: User logged in successfully. Token received.');
          return {'token': token};
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

  // --- Profile Operations ---

  Future<List<Profile>> fetchProfiles() async {
    print('ApiService: Fetching profiles...');
    final url = Uri.parse('${AppStrings.baseUrl}/profiles/me');
    try {
      final response = await http.get(url, headers: _getHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Profile.fromMap(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again.');
      } else {
        final errorBody = json.decode(response.body);
        print('ApiService Error: Fetching profiles failed: ${response.statusCode} - ${errorBody['message']}');
        throw Exception(errorBody['message'] ?? 'Failed to fetch profiles');
      }
    } catch (e) {
      print('ApiService Exception during fetchProfiles: $e');
      throw Exception('Network error or invalid response during fetch profiles: $e');
    }
  }

  Future<Profile> addProfile(Profile profile) async {
    print('ApiService: Adding profile ${profile.name}...');
    final url = Uri.parse('${AppStrings.baseUrl}/profiles/');
    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: json.encode(profile.toMap()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('ApiService: Profile added successfully.');
        return Profile.fromMap(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again.');
      } else {
        final errorBody = json.decode(response.body);
        print('ApiService Error: Adding profile failed: ${response.statusCode} - ${errorBody['message']}');
        throw Exception(errorBody['message'] ?? 'Failed to add profile');
      }
    } catch (e) {
      print('ApiService Exception during addProfile: $e');
      throw Exception('Network error or invalid response during add profile: $e');
    }
  }

  Future<void> deleteProfile(int profileId) async {
    print('ApiService: Deleting profile $profileId...');
    final url = Uri.parse('${AppStrings.baseUrl}/profiles/$profileId');
    try {
      final response = await http.delete(url, headers: _getHeaders());

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('ApiService: Profile deleted successfully.');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again.');
      } else {
        final errorBody = json.decode(response.body);
        print('ApiService Error: Deleting profile failed: ${response.statusCode} - ${errorBody['message']}');
        throw Exception(errorBody['message'] ?? 'Failed to delete profile');
      }
    } catch (e) {
      print('ApiService Exception during deleteProfile: $e');
      throw Exception('Network error or invalid response during delete profile: $e');
    }
  }

  // --- Category Operations ---

Future<List<Category>> fetchCategories(int profileId) async {
    print('ApiService: Fetching profiles for profile $profileId...');
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

  Future<void> addCategory(int profileId, String categoryName, {XFile? imageFile}) async {
    print('ApiService: Adding category $categoryName to profile $profileId...');
    print(_authToken);
    final url = Uri.parse('${AppStrings.baseUrl}/categories/profile/$profileId');

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

  Future<void> deleteCategory(int profileId, int categoryId) async {
    print('ApiService: Deleting category $categoryId from profile $profileId...');
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

  Future<void> editCategory(int profileId, int categoryId, String newName, {XFile? newImageFile, String? currentImageUrl}) async {
    print('ApiService: Editing category $categoryId for profile $profileId...');
    final url = Uri.parse('${AppStrings.baseUrl}/categories/$categoryId');

    final request = http.MultipartRequest('PUT', url)
      ..headers.addAll({'Authorization': 'Bearer $_authToken'})
      ..fields['name'] = newName;

    if (newImageFile != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'imageFile',
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

  Future<void> addItemToCategory(int profileId, int categoryId, String word, {XFile? imageFile}) async {
    print('ApiService: Adding item ${word} to category $categoryId for profile $profileId...');
    final url = Uri.parse('${AppStrings.baseUrl}/imagewords/category/$categoryId');

    final request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Authorization': 'Bearer $_authToken',
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

  Future<void> deleteItemFromCategory(int profileId, int categoryId, int itemId) async {
    print('ApiService: Deleting item $itemId from category $categoryId for profile $profileId...');
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

  Future<void> editItemInCategory(int profileId, int categoryId, int itemId, String newWord, {XFile? newImageFile, String? currentImageUrl}) async {
    print('ApiService: Editing item $itemId in category $categoryId for profile $profileId...');
    final url = Uri.parse('${AppStrings.baseUrl}/imagewords/$itemId');

    final request = http.MultipartRequest('PUT', url)
      ..headers.addAll(_getHeaders(includeAuth: true))
      ..fields['wordText'] = newWord
      ..fields['categoryId'] = categoryId.toString();
    
    if (newImageFile != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'imageFile',
        await newImageFile.readAsBytes(),
        filename: newImageFile.name,
      ));
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


  // -- Audio and conjugation --
  Future<ConjugationAndAudioResult> getAudioAndConjugate(List<CommunicationItem> words) async {
    print('ApiService: Requesting conjugation and audio for words: $words');
    final url = Uri.parse('${AppStrings.baseUrl}/text/process');

    try {
      final request = http.Request('POST', url);
      request.headers['Content-Type'] = 'application/json';
      request.headers['Authorization'] = 'Bearer $_authToken';
      request.body = '{"sentence": ${jsonEncode(words.map((x) => x.toMap()).toList())}}';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('ApiService: Conjugation and audio done successfully.');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again.');
      } else {
        final errorBody = json.decode(response.body);
        print('ApiService Error: Conjugation and audio failed: ${response.statusCode} - ${errorBody['message']}');
        throw Exception(errorBody['message'] ?? 'Failed to conjugate and get audio');
      }

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      final String base64Audio = jsonResponse['audioBase64'];
      final List<CommunicationItem> conjugatedItems = (jsonResponse['sentence'] as List<dynamic>)
          .map((jsonItem) => CommunicationItem.fromMap(jsonItem as Map<String, dynamic>))
          .toList();
      
      print('ApiService: Received conjugated text and audio URL.');
      return ConjugationAndAudioResult(conjugatedWords: conjugatedItems, audioBase64: base64Audio);
    } catch (e) {
      print('ApiService Exception during getAudioAndConjugate: $e');
      throw Exception('Network error or invalid response during getAudioAndConjugate: $e');
    }
  }

  Future<List<CommunicationItem>> getConjugate(List<CommunicationItem> words) async {
    print('ApiService: Requesting conjugation for words: $words');
    final url = Uri.parse('${AppStrings.baseUrl}/estnltk/convert');

    try {
      final request = http.Request('POST', url);
      request.headers['Content-Type'] = 'application/json';
      request.headers['Authorization'] = 'Bearer $_authToken';
      request.body = '{"sentence": ${jsonEncode(words.map((x) => x.toMap()).toList())}}';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('ApiService: Conjugation done successfully.');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again.');
      } else {
        final errorBody = json.decode(response.body);
        print('ApiService Error: Conjugation failed: ${response.statusCode} - ${errorBody['message']}');
        throw Exception(errorBody['message'] ?? 'Failed to conjugate');
      }
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print("here");
      print(jsonResponse);
      final List<CommunicationItem> conjugatedItems = (jsonResponse['sentence'] as List<dynamic>)
          .map((jsonItem) => CommunicationItem.fromMap(jsonItem as Map<String, dynamic>))
          .toList();
      
      print('ApiService: Received conjugated text.');
      return conjugatedItems;
    } catch (e) {
      print('ApiService Exception during getConjugate: $e');
      throw Exception('Network error or invalid response during getConjugate: $e');
    }
  }

  Future<String> getAudio(List<CommunicationItem> words) async {
    print('ApiService: Requesting audio for words: $words');
    final url = Uri.parse('${AppStrings.baseUrl}/tts/audio');

    try {
      final request = http.Request('POST', url);
      request.headers['Content-Type'] = 'application/json';
      request.headers['Authorization'] = 'Bearer $_authToken';
      request.body = '{"sentence": ${jsonEncode(words.map((x) => x.displayedWord).join(" "))}}';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('ApiService: Audio done successfully.');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please log in again.');
      } else {
        final errorBody = json.decode(response.body);
        print('ApiService Error: Audio failed: ${response.statusCode} - ${errorBody['message']}');
        throw Exception(errorBody['message'] ?? 'Failed to get audio');
      }
 
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse['audioBase64'];
    } catch (e) {
      print('ApiService Exception during getAudio: $e');
      throw Exception('Network error or invalid response during getAudio: $e');
    }
  }
}
