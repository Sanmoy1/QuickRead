import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class NewsService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  static const String _apiKey = 'a40dc07fb2454b9dbff186b5124169d5'; 

  Future<List<Article>> getTopHeadlines() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/top-headlines?country=us&apiKey=$_apiKey'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'X-Api-Key': _apiKey,
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'error') {
          throw Exception(json['message'] ?? 'Failed to load news');
        }
        final articles = (json['articles'] as List)
            .map((article) => Article.fromJson(article))
            .toList();
        return articles;
      } else {
        throw Exception('Failed to load news: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getTopHeadlines: $e');
      rethrow;
    }
  }

  Future<List<Article>> searchNews(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/everything?q=$query&apiKey=$_apiKey'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'X-Api-Key': _apiKey,
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['status'] == 'error') {
          throw Exception(json['message'] ?? 'Failed to search news');
        }
        final articles = (json['articles'] as List)
            .map((article) => Article.fromJson(article))
            .toList();
        return articles;
      } else {
        throw Exception('Failed to search news: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Error in searchNews: $e');
      rethrow;
    }
  }
}
