import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';
import '../providers/news_provider.dart';
import '../providers/tts_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleDetailsScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailsScreen({super.key, required this.article});

  String _getReadableText() {
    return '${article.title}. ${article.description}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Details'),
        actions: [
          Consumer<TtsProvider>(
            builder: (context, ttsProvider, child) {
              return IconButton(
                icon: Icon(
                  ttsProvider.isPlaying ? Icons.stop_circle : Icons.play_circle,
                  size: 28,
                ),
                onPressed: () {
                  if (ttsProvider.isPlaying) {
                    ttsProvider.stop();
                  } else {
                    ttsProvider.speak(_getReadableText());
                  }
                },
                tooltip: ttsProvider.isPlaying ? 'Stop Reading' : 'Read Article',
              );
            },
          ),
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
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final Uri url = Uri.parse(article.url);
                            try {
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Could not open the article'),
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error opening article: $e'),
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.launch),
                          label: const Text('Read Full Article'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Consumer<TtsProvider>(
                        builder: (context, ttsProvider, child) {
                          return FloatingActionButton(
                            onPressed: () {
                              if (ttsProvider.isPlaying) {
                                ttsProvider.stop();
                              } else {
                                ttsProvider.speak(_getReadableText());
                              }
                            },
                            child: Icon(
                              ttsProvider.isPlaying ? Icons.stop : Icons.play_arrow,
                            ),
                          );
                        },
                      ),
                    ],
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
