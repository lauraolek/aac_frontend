import 'package:flutter/material.dart';
//import 'package:just_audio/just_audio.dart';
import '../services/api_service.dart';
import '../models/communication_item.dart';

class CommunicationProvider with ChangeNotifier {
  ApiService _apiService;
  final List<CommunicationItem> _selectedItems = [];
  final List<List<CommunicationItem>> _undoStack = [];
  //final _audioPlayer = AudioPlayer();
  bool _isSpeaking = false;
  
  CommunicationProvider(this._apiService);

  set apiService(ApiService apiService) {
    _apiService = apiService;
    notifyListeners();
  }

  List<CommunicationItem> get selectedItems => _selectedItems;
  bool get isSpeaking => _isSpeaking;

  void addItem(CommunicationItem item) {
    _saveStateForUndo();
    _selectedItems.add(item);
    notifyListeners();
  }

  void removeItem(int itemId) {
    _saveStateForUndo();
    _selectedItems.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void undoLastItem() {
    if (_undoStack.isNotEmpty) {
      _selectedItems.clear();
      _selectedItems.addAll(_undoStack.removeLast());
      notifyListeners();
    }
  }

  void clearAllItems() {
    if (_selectedItems.isNotEmpty) {
      _saveStateForUndo();
      _selectedItems.clear();
      _undoStack.clear();
      notifyListeners();
    }
  }

  Future<void> speakSentence() async {
    if (_selectedItems.isEmpty || _isSpeaking) return;

    _isSpeaking = true;
    notifyListeners();

    try {
      final wordsToConjugate = _selectedItems.map((item) => item.word).toList();
      final response = await _apiService.getAudioAndConjugate(wordsToConjugate);
      final List<String> conjugatedWords = List<String>.from(response['conjugatedWords']!);
      //final audioUrl = response['audioUrl']!;

      if (conjugatedWords.length == _selectedItems.length) {
        for (int i = 0; i < _selectedItems.length; i++) {
          _selectedItems[i] = _selectedItems[i].copyWith(word: conjugatedWords[i]);
        }
      }
      notifyListeners();

      //await _audioPlayer.setUrl(audioUrl);
      //await _audioPlayer.play();
    } catch (e) {
      print('Failed to get audio from backend: $e');
    } finally {
      _isSpeaking = false;
      notifyListeners();
    }
  }


   void _saveStateForUndo() {
    _undoStack.add(List.from(_selectedItems));
  }
  
  @override
  void dispose() {
    //_audioPlayer.dispose();
    super.dispose();
  }
}
