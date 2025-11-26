class ComicSearchItem {
  final String title;
  final String slug;
  final String image;
  final String type;
  final String latestChapter;
  final String rating;

  ComicSearchItem({
    required this.title,
    required this.slug,
    required this.image,
    required this.type,
    required this.latestChapter,
    required this.rating,
  });

  factory ComicSearchItem.fromJson(Map<String, dynamic> json) {
    return ComicSearchItem(
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      image: json['image'] ?? '',
      type: json['type'] ?? 'Unknown',
      latestChapter: json['latestChapter'] ?? '',
      rating: json['rating'] ?? '0.0',
    );
  }
}
