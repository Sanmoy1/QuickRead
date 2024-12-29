import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';
import '../models/search_filters.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class NewsService {
  // final String? _apiKey = dotenv.env['API_KEY'];
  static const String _baseUrl = 'https://newsapi.org/v2';
  static const String _apiKey = 'a40dc07fb2454b9dbff186b5124169d5'; 

  Future<List<Article>> getTopHeadlines({SearchFilters? filters}) async {
    try {
      final queryParams = {
        'country': 'us',
        'apiKey': _apiKey,
      };

      if (filters != null) {
        queryParams.addAll(filters.toQueryParameters());
      }

      final uri = Uri.parse('$_baseUrl/top-headlines').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(uri);

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
        print('Error response: ${response.body}');
        throw Exception('Failed to load news: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getTopHeadlines: $e');
      rethrow;
    }
  }

  Future<List<Article>> searchNews(String query, {SearchFilters? filters}) async {
    try {
      // Ensure the query is properly encoded
      final encodedQuery = Uri.encodeComponent(query);
      
      final queryParams = {
        'q': encodedQuery,
        'apiKey': _apiKey,
        'language': 'en', // Add language parameter for better results
      };

      if (filters != null) {
        queryParams.addAll(filters.toQueryParameters());
      }

      final uri = Uri.parse('$_baseUrl/everything').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(uri);

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
        print('Error response: ${response.body}');
        throw Exception('Failed to load news: Status ${response.statusCode}');
      }
    } catch (e) {
      print('Error in searchNews: $e');
      rethrow;
    }
  }
}
