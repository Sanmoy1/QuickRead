import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article.dart';
import '../providers/news_provider.dart';

class ArticleDetailsScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailsScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Details'),
        actions: [
          IconButton(
            icon: Icon(
              article.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            ),
            onPressed: () {
              Provider.of<NewsProvider>(context, listen: false)
                  .toggleBookmark(article);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl.isNotEmpty)
              Image.network(
                article.imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    height: 250,
                    child: Center(child: Icon(Icons.error)),
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Source: ${article.source}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    article.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (article.url.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Article URL is not available'),
                          ),
                        );
                        return;
                      }

                      try {
                        final Uri url = Uri.parse(article.url);
                        if (!url.hasScheme) {
                          // Add https if scheme is missing
                          final urlString = 'https://${article.url}';
                          final httpsUrl = Uri.parse(urlString);
                          if (await canLaunchUrl(httpsUrl)) {
                            await launchUrl(
                              httpsUrl,
                              mode: LaunchMode.externalApplication,
                              webViewConfiguration: const WebViewConfiguration(
                                enableJavaScript: true,
                                enableDomStorage: true,
                              ),
                            );
                          } else {
                            throw 'Could not launch $urlString';
                          }
                        } else {
                          if (await canLaunchUrl(url)) {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                              webViewConfiguration: const WebViewConfiguration(
                                enableJavaScript: true,
                                enableDomStorage: true,
                              ),
                            );
                          } else {
                            throw 'Could not launch ${url.toString()}';
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Could not open the article: ${e.toString()}'),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.launch),
                    label: const Text('Read Full Article'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
