import 'dart:convert';
import 'package:flutter/material.dart';
//import 'package:shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryProvider with ChangeNotifier {
  static const String _historyKey = 'search_history';
  static const int _maxHistoryItems = 10;
  List<String> _searchHistory = [];
  
  List<String> get searchHistory => _searchHistory;

  SearchHistoryProvider() {
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_historyKey);
    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      _searchHistory = decoded.cast<String>();
      notifyListeners();
    }
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = jsonEncode(_searchHistory);
    await prefs.setString(_historyKey, historyJson);
  }

  void addSearch(String query) {
    if (query.trim().isEmpty) return;
    
    // Remove if exists (to move it to top)
    _searchHistory.remove(query);
    
    // Add to beginning of list
    _searchHistory.insert(0, query);
    
    // Keep only last N items
    if (_searchHistory.length > _maxHistoryItems) {
      _searchHistory = _searchHistory.take(_maxHistoryItems).toList();
    }
    
    _saveSearchHistory();
    notifyListeners();
  }

  void removeSearch(String query) {
    _searchHistory.remove(query);
    _saveSearchHistory();
    notifyListeners();
  }

  void clearHistory() {
    _searchHistory.clear();
    _saveSearchHistory();
    notifyListeners();
  }
}
