class BlogPost {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String authorName;
  final String authorImageUrl;
  final DateTime publishDate;
  final String content;
  final String featuredImageUrl;
  final List<String> keyTakeaways;
  final List<RelatedArticle> relatedArticles;

  BlogPost({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.authorName,
    required this.authorImageUrl,
    required this.publishDate,
    required this.content,
    required this.featuredImageUrl,
    required this.keyTakeaways,
    this.relatedArticles = const [],
  });
}

class RelatedArticle {
  final String title;
  final String url;

  RelatedArticle({required this.title, required this.url});
}
