class Article {
  final String title;
  final String description;
  final String url;
  final String imageUrl;
  final String publishedAt;
  final String source;
  bool isBookmarked;

  Article({
    required this.title,
    required this.description,
    required this.url,
    required this.imageUrl,
    required this.publishedAt,
    required this.source,
    this.isBookmarked = false,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    final sourceMap = json['source'] as Map<String, dynamic>?;
    return Article(
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      imageUrl: json['urlToImage']?.toString() ?? '',
      publishedAt: json['publishedAt']?.toString() ?? '',
      source: sourceMap?['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': imageUrl,
      'publishedAt': publishedAt,
      'source': {'name': source},
      'isBookmarked': isBookmarked,
    };
  }
}
