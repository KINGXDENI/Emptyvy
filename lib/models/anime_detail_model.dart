class AnimeDetailData {
  final String title;
  final String japaneseTitle;
  final String poster;
  final String rating;
  final String status;
  final String episodeCount;
  final String duration;
  final String studio;
  final String synopsis;
  final List<Genre> genres;
  final List<Episode> episodeLists;
  final List<Recommendation> recommendations;

  AnimeDetailData({
    required this.title,
    required this.japaneseTitle,
    required this.poster,
    required this.rating,
    required this.status,
    required this.episodeCount,
    required this.duration,
    required this.studio,
    required this.synopsis,
    required this.genres,
    required this.episodeLists,
    required this.recommendations,
  });

  factory AnimeDetailData.fromJson(Map<String, dynamic> json) {
    var data = json['data'];
    return AnimeDetailData(
      title: data['title'] ?? '',
      japaneseTitle: data['japanese_title'] ?? '',
      poster: data['poster'] ?? '',
      rating: data['rating'] ?? 'N/A',
      status: data['status'] ?? '',
      episodeCount: data['episode_count'] ?? '',
      duration: data['duration'] ?? '',
      studio: data['studio'] ?? '',
      synopsis: data['synopsis'] ?? '',
      genres: (data['genres'] as List).map((e) => Genre.fromJson(e)).toList(),
      episodeLists: (data['episode_lists'] as List)
          .map((e) => Episode.fromJson(e))
          .toList(),
      recommendations: (data['recommendations'] as List)
          .map((e) => Recommendation.fromJson(e))
          .toList(),
    );
  }
}

class Genre {
  final String name;
  Genre({required this.name});
  factory Genre.fromJson(Map<String, dynamic> json) =>
      Genre(name: json['name']);
}

class Episode {
  final String episode; // Judul episode panjang
  final int episodeNumber;
  final String slug;

  Episode({
    required this.episode,
    required this.episodeNumber,
    required this.slug,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      episode: json['episode'] ?? '',
      episodeNumber: json['episode_number'] ?? 0,
      slug: json['slug'] ?? '',
    );
  }
}

class Recommendation {
  final String title;
  final String poster;
  final String slug;

  Recommendation({
    required this.title,
    required this.poster,
    required this.slug,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      title: json['title'] ?? '',
      poster: json['poster'] ?? '',
      slug: json['slug'] ?? '',
    );
  }
}
