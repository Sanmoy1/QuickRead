import 'package:flutter/material.dart';
import '../models/search_filters.dart';
import 'package:intl/intl.dart';

class SearchFiltersBottomSheet extends StatefulWidget {
  final SearchFilters initialFilters;
  final Function(SearchFilters) onApply;

  const SearchFiltersBottomSheet({
    super.key,
    required this.initialFilters,
    required this.onApply,
  });

  @override
  State<SearchFiltersBottomSheet> createState() => _SearchFiltersBottomSheetState();
}

class _SearchFiltersBottomSheetState extends State<SearchFiltersBottomSheet> {
  late SearchFilters _filters;
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _filters.fromDate ?? DateTime.now().subtract(const Duration(days: 30)),
        end: _filters.toDate ?? DateTime.now(),
      ),
    );

    if (picked != null) {
      setState(() {
        _filters = _filters.copyWith(
          fromDate: picked.start,
          toDate: picked.end,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Search Filters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Date Range
          ListTile(
            title: const Text('Date Range'),
            subtitle: Text(
              _filters.fromDate != null && _filters.toDate != null
                  ? '${_dateFormat.format(_filters.fromDate!)} - ${_dateFormat.format(_filters.toDate!)}'
                  : 'Select date range',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: _selectDateRange,
          ),
          const Divider(),

          // Category
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            value: _filters.category ?? 'All',
            items: SearchFilters.categories.map((String category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                _filters = _filters.copyWith(category: value);
              });
            },
          ),
          const SizedBox(height: 16),

          // Sort By
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Sort By',
              border: OutlineInputBorder(),
            ),
            value: _filters.sortBy ?? 'publishedAt',
            items: SearchFilters.sortOptions.map((String option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option[0].toUpperCase() + option.substring(1)),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                _filters = _filters.copyWith(sortBy: value);
              });
            },
          ),
          const SizedBox(height: 24),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _filters = SearchFilters.defaults;
                    });
                  },
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    widget.onApply(_filters);
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
