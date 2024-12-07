import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/article.dart';
import '../services/news_service.dart';

class NewsProvider with ChangeNotifier {
  final NewsService _newsService;
  final Future<SharedPreferences> _prefs;
  List<Article> _articles = [];
  List<Article> _bookmarkedArticles = [];
  bool _isLoading = false;
  String _error = '';

  NewsProvider([NewsService? newsService, Future<SharedPreferences>? prefs]) 
      : _newsService = newsService ?? NewsService(),
        _prefs = prefs ?? SharedPreferences.getInstance();

  List<Article> get articles => _articles;
  List<Article> get bookmarkedArticles => _bookmarkedArticles;
  bool get isLoading => _isLoading;
  String get error => _error;

  @protected
  set articles(List<Article> value) {
    _articles = value;
    notifyListeners();
  }
  
  @protected
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  @protected
  set error(String value) {
    _error = value;
    notifyListeners();
  }

  Future<void> loadTopHeadlines() async {
    if (_isLoading) return;
    
    isLoading = true;
    error = '';

    try {
      final newArticles = await _newsService.getTopHeadlines();
      articles = newArticles;
      error = '';
      await _loadBookmarkedStatus();
    } catch (e) {
      print('Error loading headlines: $e');
      error = e.toString();
      articles = [];
    } finally {
      isLoading = false;
    }
  }

  Future<void> searchNews(String query) async {
    if (_isLoading) return;
    
    if (query.isEmpty) {
      await loadTopHeadlines();
      return;
    }

    isLoading = true;
    error = '';

    try {
      final searchResults = await _newsService.searchNews(query);
      articles = searchResults;
      error = '';
      await _loadBookmarkedStatus();
    } catch (e) {
      print('Error searching news: $e');
      error = e.toString();
      articles = [];
    } finally {
      isLoading = false;
    }
  }

  Future<void> toggleBookmark(Article article) async {
    article.isBookmarked = !article.isBookmarked;
    
    if (article.isBookmarked) {
      _bookmarkedArticles.add(article);
    } else {
      _bookmarkedArticles.removeWhere((a) => a.url == article.url);
    }

    await _saveBookmarkedArticles();
    notifyListeners();
  }

  Future<void> _loadBookmarkedArticles() async {
    final prefs = await _prefs;
    final bookmarkedJson = prefs.getStringList('bookmarked_articles') ?? [];
    
    _bookmarkedArticles = bookmarkedJson
        .map((json) => Article.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> _saveBookmarkedArticles() async {
    final prefs = await _prefs;
    final bookmarkedJson = _bookmarkedArticles
        .map((article) => jsonEncode(article.toJson()))
        .toList();
    
    await prefs.setStringList('bookmarked_articles', bookmarkedJson);
  }

  Future<void> _loadBookmarkedStatus() async {
    await _loadBookmarkedArticles();
    for (var article in _articles) {
      article.isBookmarked = _bookmarkedArticles
          .any((bookmarked) => bookmarked.url == article.url);
    }
  }
}
