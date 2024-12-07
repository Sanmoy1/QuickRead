import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:news_reader_app/models/article.dart';
import 'package:news_reader_app/screens/home_screen.dart';
import 'package:news_reader_app/providers/news_provider.dart';
import 'mock_news_service.dart';

void main() {
  late MockNewsService mockNewsService;
  late SharedPreferences mockPrefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockPrefs = await SharedPreferences.getInstance();
    mockNewsService = MockNewsService();
  });

  Widget createHomeScreen() {
    return MaterialApp(
      home: ChangeNotifierProvider<NewsProvider>(
        create: (_) => NewsProvider(mockNewsService, Future.value(mockPrefs)),
        child: const HomeScreen(),
      ),
    );
  }

  group('HomeScreen Widget Tests', () {
    testWidgets('should display loading indicator when loading',
        (WidgetTester tester) async {
      mockNewsService.setShouldThrow(false);
      mockNewsService.setArticles([]);
      
      await tester.pumpWidget(createHomeScreen());
      
      // Initial build should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Wait for the mock delay and rebuild
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should display error message when there is an error',
        (WidgetTester tester) async {
      mockNewsService.setShouldThrow(true);
      mockNewsService.setError('Test error message');
      
      await tester.pumpWidget(createHomeScreen());
      
      // Wait for the mock delay and error state
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.text('Test error message'), findsOneWidget);
    });

    testWidgets('should display search bar', (WidgetTester tester) async {
      mockNewsService.setShouldThrow(false);
      mockNewsService.setArticles([]);
      
      await tester.pumpWidget(createHomeScreen());
      
      // Wait for the mock delay
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should display articles when loaded',
        (WidgetTester tester) async {
      final testArticle = Article(
        title: 'Test Article',
        description: 'Test Description',
        url: 'https://test.com',
        imageUrl: 'https://test.com/image.jpg',
        publishedAt: '2023-12-10',
        source: 'Test Source',
      );
      
      mockNewsService.setShouldThrow(false);
      mockNewsService.setArticles([testArticle]);
      
      await tester.pumpWidget(createHomeScreen());
      
      // Wait for the mock delay and rebuild
      await tester.pump(const Duration(milliseconds: 150));

      // Verify article content
      expect(find.text('Test Article'), findsOneWidget);
      expect(find.text('Test Source'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
    });

    testWidgets('should display no articles message when empty',
        (WidgetTester tester) async {
      mockNewsService.setShouldThrow(false);
      mockNewsService.setArticles([]);
      
      await tester.pumpWidget(createHomeScreen());
      
      // Wait for the mock delay and rebuild
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.text('No articles found'), findsOneWidget);
    });
  });
}
