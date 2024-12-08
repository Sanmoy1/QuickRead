import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/search_history_provider.dart';
import '../models/article.dart';
import '../widgets/search_history_list.dart';
import 'article_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  bool _isInitialized = false;
  bool _showSearchHistory = false;
  final FocusNode _searchFocusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChange);
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchFocusChange() {
    setState(() {
      _showSearchHistory = _searchFocusNode.hasFocus;
    });
  }

  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      Provider.of<SearchHistoryProvider>(context, listen: false).addSearch(query);
      Provider.of<NewsProvider>(context, listen: false).searchNews(query);
      _searchFocusNode.unfocus();
      setState(() {
        _showSearchHistory = false;
      });
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      Provider.of<NewsProvider>(context, listen: false).loadTopHeadlines();
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _searchFocusNode.unfocus();
        setState(() {
          _showSearchHistory = false;
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('News Reader'),
          actions: [
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return IconButton(
                  icon: Icon(
                    themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  ),
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                  tooltip: themeProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Search news...',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      _performSearch(_searchController.text);
                    },
                  ),
                ),
                onSubmitted: _performSearch,
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Consumer<NewsProvider>(
                    builder: (context, newsProvider, child) {
                      if (newsProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (newsProvider.error.isNotEmpty) {
                        return Center(
                          child: Text(
                            newsProvider.error,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        );
                      }

                      if (newsProvider.articles.isEmpty) {
                        return Center(
                          child: Text(
                            'No articles found',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        key: ValueKey(Theme.of(context).brightness),
                        itemCount: newsProvider.articles.length,
                        itemBuilder: (context, index) {
                          final article = newsProvider.articles[index];
                          return _buildArticleCard(article, context);
                        },
                      );
                    },
                  ),
                  if (_showSearchHistory)
                    Container(
                      color: Theme.of(context).colorScheme.background,
                      child: SearchHistoryList(
                        onSearchSelected: (query) {
                          _searchController.text = query;
                          _performSearch(query);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleCard(Article article, BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = Theme.of(context);
        return Card(
          color: theme.colorScheme.surface,
          margin: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticleDetailsScreen(article: article),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (article.imageUrl.isNotEmpty)
                  Stack(
                    children: [
                      Image.network(
                        article.imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: theme.colorScheme.surfaceVariant,
                            child: Center(
                              child: Icon(
                                Icons.error,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: theme.colorScheme.surface.withOpacity(0.7),
                          child: IconButton(
                            icon: Icon(
                              article.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: theme.colorScheme.primary,
                            ),
                            onPressed: () {
                              Provider.of<NewsProvider>(context, listen: false)
                                  .toggleBookmark(article);
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: theme.colorScheme.surface.withOpacity(0.7),
                        child: IconButton(
                          icon: Icon(
                            article.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: () {
                            Provider.of<NewsProvider>(context, listen: false)
                                .toggleBookmark(article);
                          },
                        ),
                      ),
                    ),
                  ),
                Container(
                  color: theme.colorScheme.surface,
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.source,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        article.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (article.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          article.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        article.publishedAt,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
