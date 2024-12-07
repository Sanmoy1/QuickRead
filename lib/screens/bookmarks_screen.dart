import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import 'article_details_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
      ),
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          final bookmarkedArticles = newsProvider.bookmarkedArticles;

          if (bookmarkedArticles.isEmpty) {
            return const Center(
              child: Text('No bookmarked articles'),
            );
          }

          return ListView.builder(
            itemCount: bookmarkedArticles.length,
            itemBuilder: (context, index) {
              final article = bookmarkedArticles[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: article.imageUrl.isNotEmpty
                      ? SizedBox(
                          width: 60,
                          height: 60,
                          child: Image.network(
                            article.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error);
                            },
                          ),
                        )
                      : const SizedBox(
                          width: 60,
                          height: 60,
                          child: Icon(Icons.article),
                        ),
                  title: Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    article.source,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.bookmark),
                    onPressed: () {
                      Provider.of<NewsProvider>(context, listen: false)
                          .toggleBookmark(article);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ArticleDetailsScreen(article: article),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
