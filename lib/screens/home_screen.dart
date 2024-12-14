import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/search_history_provider.dart';
import '../models/article.dart';
import '../widgets/search_history_list.dart';
import 'article_details_screen.dart';
import '../widgets/search_filters_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  bool _showSearchHistory = false;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadInitialNews();
    _setupSearchFocusListener();
    _searchFocusNode.addListener(_onSearchFocusChange);
  }

  void _loadInitialNews() {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    newsProvider.fetchNews();
  }

  void _setupSearchFocusListener() {
    _searchFocusNode.addListener(() {
      setState(() {
        _showSearchHistory = _searchFocusNode.hasFocus && 
            _searchController.text.isEmpty;
      });
    });
  }

  void _onSearchFocusChange() {
    setState(() {
      _showSearchHistory = _searchFocusNode.hasFocus;
    });
  }

  void _onSearchChanged(String query) {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        newsProvider.fetchNews();
      } else {
        newsProvider.fetchNews(query: query);
      }
    });
  }

  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      Provider.of<SearchHistoryProvider>(context, listen: false).addSearch(query);
      Provider.of<NewsProvider>(context, listen: false).fetchNews(query: query);
      _searchFocusNode.unfocus();
      setState(() {
        _showSearchHistory = false;
      });
    }
  }

  void _showFilters() {
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SearchFiltersBottomSheet(
          initialFilters: newsProvider.currentFilters,
          onApply: (filters) {
            newsProvider.fetchNews(
              query: _searchController.text,
              filters: filters,
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
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
          title: const Text('QuickRead'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilters,
              tooltip: 'Search Filters',
            ),
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
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            Provider.of<NewsProvider>(context, listen: false)
                                .fetchNews();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onChanged: _onSearchChanged,
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
                              color: Theme.of(context).colorScheme.onSurface,
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
                      color: Theme.of(context).colorScheme.surface,
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
