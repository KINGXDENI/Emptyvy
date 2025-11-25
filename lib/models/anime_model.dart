class AnimeHomeData {
  final List<OngoingAnime> ongoingAnime;
  final List<CompleteAnime> completeAnime;

  AnimeHomeData({required this.ongoingAnime, required this.completeAnime});

  factory AnimeHomeData.fromJson(Map<String, dynamic> json) {
    return AnimeHomeData(
      ongoingAnime: (json['data']['ongoing_anime'] as List)
          .map((e) => OngoingAnime.fromJson(e))
          .toList(),
      completeAnime: (json['data']['complete_anime'] as List)
          .map((e) => CompleteAnime.fromJson(e))
          .toList(),
    );
  }
}

class OngoingAnime {
  final String title;
  final String slug;
  final String poster;
  final String currentEpisode;
  final String releaseDay;

  OngoingAnime({
    required this.title,
    required this.slug,
    required this.poster,
    required this.currentEpisode,
    required this.releaseDay,
  });

  factory OngoingAnime.fromJson(Map<String, dynamic> json) {
    return OngoingAnime(
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      poster: json['poster'] ?? '',
      currentEpisode: json['current_episode'] ?? '',
      releaseDay: json['release_day'] ?? '',
    );
  }
}

class CompleteAnime {
  final String title;
  final String slug;
  final String poster;
  final String episodeCount;
  final String rating;

  CompleteAnime({
    required this.title,
    required this.slug,
    required this.poster,
    required this.episodeCount,
    required this.rating,
  });

  factory CompleteAnime.fromJson(Map<String, dynamic> json) {
    return CompleteAnime(
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      poster: json['poster'] ?? '',
      episodeCount: json['episode_count'] ?? '',
      rating: json['rating'] ?? '',
    );
  }
}