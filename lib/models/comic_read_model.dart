class ComicReadData {
  final String title;
  final String comicSlug;
  final List<String> images;
  final String? prevSlug;
  final String? nextSlug;

  ComicReadData({
    required this.title,
    required this.comicSlug,
    required this.images,
    this.prevSlug,
    this.nextSlug,
  });

  factory ComicReadData.fromJson(Map<String, dynamic> json) {
    final nav = json['navigation'] ?? {};
    
    // Helper untuk handle null atau string kosong dari API
    String? parseSlug(dynamic value) {
      if (value == null || value == "" || value == "null") return null;
      return value.toString();
    }

    return ComicReadData(
      title: json['title'] ?? '',
      comicSlug: json['comicSlug'] ?? '',
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      prevSlug: parseSlug(nav['prev']),
      nextSlug: parseSlug(nav['next']),
    );
  }
}