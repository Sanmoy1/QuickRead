import 'package:news_reader_app/models/article.dart';
import 'package:news_reader_app/providers/news_provider.dart';

class MockNewsProvider extends NewsProvider {
  void setTestState({
    List<Article>? articles,
    bool? isLoading,
    String? error,
  }) {
    if (articles != null) {
      this.articles = articles;
    }
    if (isLoading != null) {
      this.isLoading = isLoading;
    }
    if (error != null) {
      this.error = error;
    }
    notifyListeners();
  }
}
