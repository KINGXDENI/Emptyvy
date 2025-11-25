class DonghuaDetailData {
  final String title;
  final String alterTitle;
  final String poster;
  final String status;
  final String studio;
  final String network;
  final String released;
  final String duration;
  final String type; // <--- Tambahkan field ini
  final String episodesCount;
  final String synopsis;
  final List<String> genres;
  final List<DonghuaEpisode> episodeList;

  DonghuaDetailData({
    required this.title,
    required this.alterTitle,
    required this.poster,
    required this.status,
    required this.studio,
    required this.network,
    required this.released,
    required this.duration,
    required this.type, // <--- Tambahkan di constructor
    required this.episodesCount,
    required this.synopsis,
    required this.genres,
    required this.episodeList,
  });

  factory DonghuaDetailData.fromJson(Map<String, dynamic> json) {
    return DonghuaDetailData(
      title: json['title'] ?? '',
      alterTitle: json['alter_title'] ?? '-',
      poster: json['poster'] ?? '',
      status: json['status'] ?? '',
      studio: json['studio'] ?? '-',
      network: json['network'] ?? '-',
      released: json['released'] ?? '-',
      duration: json['duration'] ?? '-',
      type: json['type'] ?? 'Donghua', // <--- Mapping dari JSON
      episodesCount: json['episodes_count'] ?? '',
      synopsis: json['synopsis'] ?? '',
      genres:
          (json['genres'] as List?)
              ?.map((e) => e['name'].toString())
              .toList() ??
          [],
      episodeList:
          (json['episodes_list'] as List?)
              ?.map((e) => DonghuaEpisode.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class DonghuaEpisode {
  final String title;
  final String slug;
  final String url;

  DonghuaEpisode({required this.title, required this.slug, required this.url});

  factory DonghuaEpisode.fromJson(Map<String, dynamic> json) {
    return DonghuaEpisode(
      title: json['episode'] ?? '',
      slug: json['slug'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
