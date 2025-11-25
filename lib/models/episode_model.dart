class EpisodeDetail {
  final String episodeTitle;
  final String? nextEpisodeSlug;
  final String? prevEpisodeSlug;
  final List<StreamQuality> streamServers;

  EpisodeDetail({
    required this.episodeTitle,
    this.nextEpisodeSlug,
    this.prevEpisodeSlug,
    required this.streamServers,
  });

  factory EpisodeDetail.fromJson(Map<String, dynamic> json) {
    // ---------------------------------------------------------
    // KONDISI 1: Format ANIME (Data ada di dalam key 'data')
    // ---------------------------------------------------------
    if (json.containsKey('data') && json['data'] != null) {
      var data = json['data'];
      return EpisodeDetail(
        episodeTitle: data['episode'] ?? '',
        nextEpisodeSlug: data['has_next_episode'] == true
            ? data['next_episode']['slug']
            : null,
        prevEpisodeSlug: data['has_previous_episode'] == true
            ? data['previous_episode']['slug']
            : null,
        streamServers: (data['stream_servers'] as List? ?? [])
            .map((e) => StreamQuality.fromJson(e))
            .toList(),
      );
    }
    // ---------------------------------------------------------
    // KONDISI 2: Format DONGHUA (Langsung di root object)
    // ---------------------------------------------------------
    else {
      // Ambil navigasi (Next/Prev)
      var nav = json['navigation'] ?? {};
      String? nextSlug;
      String? prevSlug;

      if (nav['next_episode'] != null && nav['next_episode']['slug'] != null) {
        nextSlug = nav['next_episode']['slug'];
      }
      if (nav['previous_episode'] != null &&
          nav['previous_episode']['slug'] != null) {
        prevSlug = nav['previous_episode']['slug'];
      }

      // Ambil Servers dari key "streaming" -> "servers"
      List<Server> donghuaServers = [];
      if (json['streaming'] != null && json['streaming']['servers'] != null) {
        donghuaServers = (json['streaming']['servers'] as List)
            .map((e) => Server.fromJson(e))
            .toList();
      }

      // Donghua tidak dikelompokkan berdasarkan kualitas (360/720/1080) di streaming-nya,
      // jadi kita bungkus semua server dalam satu kualitas bernama "Streaming".
      List<StreamQuality> qualities = [];
      if (donghuaServers.isNotEmpty) {
        qualities.add(
          StreamQuality(quality: "Streaming", servers: donghuaServers),
        );
      }

      return EpisodeDetail(
        episodeTitle: json['episode'] ?? '',
        nextEpisodeSlug: nextSlug,
        prevEpisodeSlug: prevSlug,
        streamServers: qualities,
      );
    }
  }
}

class StreamQuality {
  final String quality; // "360p", "480p", "Streaming" (untuk donghua)
  final List<Server> servers;

  StreamQuality({required this.quality, required this.servers});

  factory StreamQuality.fromJson(Map<String, dynamic> json) {
    return StreamQuality(
      quality: json['quality'] ?? 'Default',
      servers: (json['servers'] as List? ?? [])
          .map((e) => Server.fromJson(e))
          .toList(),
    );
  }
}

class Server {
  final String name; // "vidhide", "filedon", "OK.ru", dll
  final String id; // ID untuk Anime (butuh fetch lagi)
  final String? url; // URL Langsung untuk Donghua

  Server({
    required this.name,
    required this.id,
    this.url, // Optional, hanya ada di Donghua
  });

  factory Server.fromJson(Map<String, dynamic> json) {
    return Server(
      name: json['name'] ?? '',
      id: json['id'] ?? '',
      // Donghua memberikan URL langsung di key 'url'
      url: json['url'],
    );
  }
}
