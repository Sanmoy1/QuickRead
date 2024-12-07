import 'package:flutter_test/flutter_test.dart';
import 'package:news_reader_app/models/article.dart';

void main() {
  group('Article', () {
    test('should create Article instance from JSON', () {
      final json = {
        'title': 'Test Title',
        'description': 'Test Description',
        'url': 'https://test.com',
        'urlToImage': 'https://test.com/image.jpg',
        'publishedAt': '2023-12-10',
        'source': {'name': 'Test Source'},
      };

      final article = Article.fromJson(json);

      expect(article.title, 'Test Title');
      expect(article.description, 'Test Description');
      expect(article.url, 'https://test.com');
      expect(article.imageUrl, 'https://test.com/image.jpg');
      expect(article.publishedAt, '2023-12-10');
      expect(article.source, 'Test Source');
      expect(article.isBookmarked, false);
    });

    test('should handle missing values in JSON', () {
      final json = {
        'title': null,
        'description': null,
        'url': null,
        'urlToImage': null,
        'publishedAt': null,
        'source': null,
      };

      final article = Article.fromJson(json);

      expect(article.title, '');
      expect(article.description, '');
      expect(article.url, '');
      expect(article.imageUrl, '');
      expect(article.publishedAt, '');
      expect(article.source, '');
      expect(article.isBookmarked, false);
    });

    test('should convert Article to JSON', () {
      final article = Article(
        title: 'Test Title',
        description: 'Test Description',
        url: 'https://test.com',
        imageUrl: 'https://test.com/image.jpg',
        publishedAt: '2023-12-10',
        source: 'Test Source',
        isBookmarked: true,
      );

      final json = article.toJson();

      expect(json['title'], 'Test Title');
      expect(json['description'], 'Test Description');
      expect(json['url'], 'https://test.com');
      expect(json['urlToImage'], 'https://test.com/image.jpg');
      expect(json['publishedAt'], '2023-12-10');
      expect(json['source']['name'], 'Test Source');
      expect(json['isBookmarked'], true);
    });

    test('should create Article with default values', () {
      final article = Article(
        title: 'Test Title',
        description: 'Test Description',
        url: 'https://test.com',
        imageUrl: 'https://test.com/image.jpg',
        publishedAt: '2023-12-10',
        source: 'Test Source',
      );

      expect(article.isBookmarked, false);
    });

    test('should compare Articles correctly', () {
      final article1 = Article(
        title: 'Test Title',
        description: 'Test Description',
        url: 'https://test.com',
        imageUrl: 'https://test.com/image.jpg',
        publishedAt: '2023-12-10',
        source: 'Test Source',
      );

      final article2 = Article(
        title: 'Test Title',
        description: 'Test Description',
        url: 'https://test.com',
        imageUrl: 'https://test.com/image.jpg',
        publishedAt: '2023-12-10',
        source: 'Test Source',
      );

      expect(article1.url == article2.url, true);
    });
  });
}
