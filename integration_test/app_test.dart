import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:news_reader_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('full app test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify we're on the home screen
      expect(find.text('News Reader'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Wait for articles to load
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to bookmarks
      await tester.tap(find.text('Bookmarks'));
      await tester.pumpAndSettle();

      // Verify we're on the bookmarks screen
      expect(find.text('Bookmarks'), findsOneWidget);

      // Should show no bookmarks message initially
      expect(find.text('No bookmarked articles'), findsOneWidget);

      // Navigate back to home
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Try searching
      await tester.enterText(find.byType(TextField), 'test');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Wait for search results
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });
  });
}
