import 'pagination_model.dart'; // Import model pagination yang sudah ada

// 1. Model untuk Hasil Search & Genre Item
class AnimeCardData {
  final String title;
  final String slug;
  final String poster;
  final String rating;
  final String status;

  AnimeCardData({
    required this.title,
    required this.slug,
    required this.poster,
    required this.rating,
    required this.status,
  });

  factory AnimeCardData.fromJson(Map<String, dynamic> json) {
    return AnimeCardData(
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      poster: json['poster'] ?? '',
      rating: json['rating'] != null && json['rating'].toString().isNotEmpty
          ? json['rating']
          : '?',
      status: json['status'] ?? '',
    );
  }
}

// 2. Wrapper untuk Respon Genre (Ada Paginasi)
class GenreResult {
  final PaginationInfo pagination;
  final List<AnimeCardData> animeList;

  GenreResult({required this.pagination, required this.animeList});

  factory GenreResult.fromJson(Map<String, dynamic> json) {
    return GenreResult(
      // Perhatikan key JSON-nya: 'pagination' (bukan paginationData)
      pagination: PaginationInfo.fromJson(json['data']['pagination']),
      animeList: (json['data']['anime'] as List)
          .map((e) => AnimeCardData.fromJson(e))
          .toList(),
    );
  }
}
