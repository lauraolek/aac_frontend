import 'package:flutter/material.dart';
import '../models/communication_item.dart';

class CommunicationProvider with ChangeNotifier {
  final List<CommunicationItem> _selectedItems = [];
  final List<List<CommunicationItem>> _undoStack = [];

  CommunicationProvider();

  List<CommunicationItem> get selectedItems =>
      List.unmodifiable(_selectedItems);

  void addItem(CommunicationItem item) {
    _saveStateForUndo();
    _selectedItems.add(item);
    notifyListeners();
  }

  void removeItem(String itemId) {
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
    if (_selectedItems.isNotEmpty) {
      // TODO
    }
  }

  void _saveStateForUndo() {
    _undoStack.add(List.from(_selectedItems));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
