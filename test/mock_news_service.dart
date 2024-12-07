import 'package:news_reader_app/services/news_service.dart';
import 'package:news_reader_app/models/article.dart';

class MockNewsService extends NewsService {
  List<Article> _articles = [];
  String _error = '';
  bool _shouldThrow = false;

  void setArticles(List<Article> articles) {
    _articles = articles;
  }

  void setError(String error) {
    _error = error;
  }

  void setShouldThrow(bool shouldThrow) {
    _shouldThrow = shouldThrow;
  }

  @override
  Future<List<Article>> getTopHeadlines() async {
    // Add a small delay to simulate network request
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (_shouldThrow) {
      throw Exception(_error);
    }
    return _articles;
  }

  @override
  Future<List<Article>> searchNews(String query) async {
    // Add a small delay to simulate network request
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (_shouldThrow) {
      throw Exception(_error);
    }
    return _articles.where((article) => 
      article.title.toLowerCase().contains(query.toLowerCase()) ||
      article.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
