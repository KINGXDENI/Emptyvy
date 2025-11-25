class DonghuaHomeData {
  final List<DonghuaItem> latestRelease;
  final List<DonghuaItem> completedDonghua;

  DonghuaHomeData({
    required this.latestRelease,
    required this.completedDonghua,
  });

  factory DonghuaHomeData.fromJson(Map<String, dynamic> json) {
    return DonghuaHomeData(
      latestRelease: (json['latest_release'] as List)
          .map((e) => DonghuaItem.fromJson(e))
          .toList(),
      completedDonghua: (json['completed_donghua'] as List)
          .map((e) => DonghuaItem.fromJson(e))
          .toList(),
    );
  }
}

class DonghuaItem {
  final String title;
  final String slug;
  final String poster;
  final String currentEpisode;
  final String status;
  final String url; // <--- Tambahkan field ini

  DonghuaItem({
    required this.title,
    required this.slug,
    required this.poster,
    required this.currentEpisode,
    required this.status,
    required this.url, // <--- Tambahkan di constructor
  });

  factory DonghuaItem.fromJson(Map<String, dynamic> json) {
    return DonghuaItem(
      title: json['title'] ?? '',
      // Bersihkan slug dari trailing slash '/' agar URL valid
      slug: (json['slug'] ?? '').toString().replaceAll(RegExp(r'/$'), ''),
      poster: json['poster'] ?? '',
      currentEpisode: json['current_episode'] ?? 'End',
      status: json['status'] ?? '',
      url: json['url'] ?? '', // <--- Ambil URL dari JSON
    );
  }

  // Helper untuk mengecek apakah ini link episode
  bool get isEpisode => url.contains('/episode/');
}
