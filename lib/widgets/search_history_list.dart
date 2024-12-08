import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_history_provider.dart';

class SearchHistoryList extends StatelessWidget {
  final Function(String) onSearchSelected;

  const SearchHistoryList({
    super.key,
    required this.onSearchSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchHistoryProvider>(
      builder: (context, searchHistoryProvider, child) {
        if (searchHistoryProvider.searchHistory.isEmpty) {
          return Center(
            child: Text(
              'No search history',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Searches',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      searchHistoryProvider.clearHistory();
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: searchHistoryProvider.searchHistory.length,
                itemBuilder: (context, index) {
                  final query = searchHistoryProvider.searchHistory[index];
                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(query),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        searchHistoryProvider.removeSearch(query);
                      },
                    ),
                    onTap: () {
                      onSearchSelected(query);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
