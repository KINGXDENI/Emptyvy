class ComicHomeData {
  final List<ComicItem> hotUpdates;
  final List<ComicItem> projectUpdates;
  final List<ComicItem> latestReleases;

  ComicHomeData({
    required this.hotUpdates,
    required this.projectUpdates,
    required this.latestReleases,
  });

  factory ComicHomeData.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return ComicHomeData(
      hotUpdates: (data['hotUpdates'] as List?)
              ?.map((e) => ComicItem.fromJson(e, isHot: true))
              .toList() ??
          [],
      projectUpdates: (data['projectUpdates'] as List?)
              ?.map((e) => ComicItem.fromJson(e))
              .toList() ??
          [],
      latestReleases: (data['latestReleases'] as List?)
              ?.map((e) => ComicItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ComicItem {
  final String title;
  final String slug;
  final String image;
  final String type; // Manhwa, Manhua, Manga
  
  // Field khusus Hot Updates
  final String? rating;
  final String? latestChapterString; 

  // Field khusus Project & Latest Updates
  final List<ComicChapter> chapters;

  ComicItem({
    required this.title,
    required this.slug,
    required this.image,
    required this.type,
    this.rating,
    this.latestChapterString,
    this.chapters = const [],
  });

  factory ComicItem.fromJson(Map<String, dynamic> json, {bool isHot = false}) {
    return ComicItem(
      title: json['title'] ?? 'No Title',
      slug: json['slug'] ?? '',
      image: json['image'] ?? '',
      type: json['type'] ?? 'Unknown',
      rating: json['rating'], // Hanya ada di Hot
      latestChapterString: json['chapter'], // Hanya ada di Hot
      chapters: (json['chapters'] as List?)
              ?.map((e) => ComicChapter.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ComicChapter {
  final String title; // "Ch. 123"
  final String time;  // "2 hours ago"
  final String slug;

  ComicChapter({
    required this.title,
    required this.time,
    required this.slug,
  });

  factory ComicChapter.fromJson(Map<String, dynamic> json) {
    return ComicChapter(
      title: json['title']?.replaceAll('\n', ' ') ?? '', // Hapus new line jika ada
      time: json['time'] ?? '',
      slug: json['slug'] ?? '',
    );
  }
}