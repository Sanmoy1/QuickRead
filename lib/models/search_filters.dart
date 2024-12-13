class SearchFilters {
  DateTime? fromDate;
  DateTime? toDate;
  String? source;
  String? category;
  String? sortBy;

  SearchFilters({
    this.fromDate,
    this.toDate,
    this.source,
    this.category,
    this.sortBy,
  });

  // Default values for filters
  static SearchFilters get defaults {
    return SearchFilters(
      fromDate: DateTime.now().subtract(const Duration(days: 30)),
      toDate: DateTime.now(),
      sortBy: 'publishedAt',
    );
  }

  // Available categories
  static List<String> categories = [
    'All',
    'General',
    'Business',
    'Entertainment',
    'Health',
    'Science',
    'Sports',
    'Technology',
  ];

  // Available sort options
  static List<String> sortOptions = [
    'publishedAt',
    'relevancy',
    'popularity',
  ];

  // Convert to API parameters
  Map<String, String> toQueryParameters() {
    final Map<String, String> params = {};

    if (fromDate != null) {
      params['from'] = fromDate!.toIso8601String();
    }
    if (toDate != null) {
      params['to'] = toDate!.toIso8601String();
    }
    if (source != null && source!.isNotEmpty) {
      params['sources'] = source!;
    }
    if (category != null && category != 'All') {
      params['category'] = category!.toLowerCase();
    }
    if (sortBy != null) {
      params['sortBy'] = sortBy!;
    }

    return params;
  }

  // Create a copy with optional new values
  SearchFilters copyWith({
    DateTime? fromDate,
    DateTime? toDate,
    String? source,
    String? category,
    String? sortBy,
  }) {
    return SearchFilters(
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      source: source ?? this.source,
      category: category ?? this.category,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}
