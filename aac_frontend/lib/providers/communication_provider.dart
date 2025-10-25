import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/api_service.dart';
import '../models/communication_item.dart';

class CommunicationProvider with ChangeNotifier {
  ApiService _apiService;
  final List<CommunicationItem> _selectedItems = [];
  final List<List<CommunicationItem>> _undoStack = [];
  final _audioPlayer = AudioPlayer();
  bool _isSpeaking = false;
  int counter = 0;
  
  CommunicationProvider(this._apiService);

  set apiService(ApiService apiService) {
    _apiService = apiService;
    notifyListeners();
  }

  List<CommunicationItem> get selectedItems => _selectedItems;
  bool get isSpeaking => _isSpeaking;

  void addItem(CommunicationItem item) {
    counter++;
    item.sequence = counter;
    
    _saveStateForUndo();
    _selectedItems.add(item.copyWith());
    notifyListeners();
  }

  void removeItem(int sequence) {
    _saveStateForUndo();
    _selectedItems.removeWhere((item) => item.sequence == sequence);
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
      counter = 0;
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

      if (response.conjugatedWords.length == _selectedItems.length) {
        for (int i = 0; i < _selectedItems.length; i++) {
          _selectedItems[i] = _selectedItems[i].copyWith(word: response.conjugatedWords[i]);
        }
      }
      notifyListeners();

      playAudioFromBytes(response.audioBase64);
    } catch (e) {
      print('Failed to get audio from backend: $e');
    } finally {
      _isSpeaking = false;
      notifyListeners();
    }
  }

  Future<void> playAudioFromBytes(String audioBytes) async {
    // Ensure the player is stopped before loading new audio
    await _audioPlayer.stop(); 

    final String audioUrl = 'data:audio/wav;base64,$audioBytes';

    try {
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(audioUrl)
        ),
      );

      await _audioPlayer.play();
      print("Playback started successfully.");
    } catch (e) {
      print("Error setting audio source or playing: $e");
    }
  }


   void _saveStateForUndo() {
    _undoStack.add(List.from(_selectedItems));
  }
  
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
