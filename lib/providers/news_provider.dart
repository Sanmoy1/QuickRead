import 'package:flutter/material.dart';
import '../models/article.dart';
import '../models/search_filters.dart';
import '../services/news_service.dart';

class NewsProvider with ChangeNotifier {
  final NewsService _newsService = NewsService();
  List<Article> _articles = [];
  final List<Article> _bookmarkedArticles = [];
  bool _isLoading = false;
  String _error = '';
  SearchFilters _currentFilters = SearchFilters.defaults;

  List<Article> get articles => _articles;
  List<Article> get bookmarkedArticles => _bookmarkedArticles;
  bool get isLoading => _isLoading;
  String get error => _error;
  SearchFilters get currentFilters => _currentFilters;

  Future<void> fetchNews({String? query, SearchFilters? filters}) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final searchFilters = filters ?? _currentFilters;
      _currentFilters = searchFilters;

      final List<Article> fetchedArticles;
      if (query != null && query.isNotEmpty) {
        fetchedArticles = await _newsService.searchNews(query, filters: searchFilters);
      } else {
        fetchedArticles = await _newsService.getTopHeadlines(filters: searchFilters);
      }

      _articles = fetchedArticles;
      
      // Update bookmark status for fetched articles
      _articles = _articles.map((article) {
        article.isBookmarked = _bookmarkedArticles
            .any((bookmarked) => bookmarked.url == article.url);
        return article;
      }).toList();
      
    } catch (e) {
      _error = 'Error fetching news: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleBookmark(Article article) {
    final index = _bookmarkedArticles
        .indexWhere((bookmarked) => bookmarked.url == article.url);
    
    if (index >= 0) {
      _bookmarkedArticles.removeAt(index);
      article.isBookmarked = false;
    } else {
      article.isBookmarked = true;
      _bookmarkedArticles.add(article);
    }
    
    // Update the bookmark status in the main articles list
    final mainIndex = _articles
        .indexWhere((mainArticle) => mainArticle.url == article.url);
    if (mainIndex >= 0) {
      _articles[mainIndex].isBookmarked = article.isBookmarked;
    }
    
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
