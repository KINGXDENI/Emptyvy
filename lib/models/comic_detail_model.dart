class ComicDetailData {
  final String title;
  final String nativeTitle;
  final String image;
  final String rating;
  final String synopsis;
  final String released;
  final String author;
  final String status;
  final String type;
  final List<ComicGenre> genres;
  final List<DetailChapter> chapters;

  ComicDetailData({
    required this.title,
    required this.nativeTitle,
    required this.image,
    required this.rating,
    required this.synopsis,
    required this.released,
    required this.author,
    required this.status,
    required this.type,
    required this.genres,
    required this.chapters,
  });

  factory ComicDetailData.fromJson(Map<String, dynamic> json) {
    return ComicDetailData(
      title: json['title'] ?? 'No Title', //
      nativeTitle: json['nativeTitle'] ?? '-', //
      image: json['image'] ?? '', //
      rating: json['rating'] ?? '0.0', //
      synopsis: json['synopsis'] ?? '', //
      released: json['released'] ?? '-', //
      author: json['author'] ?? '-', //
      status: json['status'] ?? 'Unknown', //
      type: json['type'] ?? 'Comic', //
      genres: (json['genres'] as List?)
              ?.map((e) => ComicGenre.fromJson(e))
              .toList() ??
          [], //
      chapters: (json['chapters'] as List?)
              ?.map((e) => DetailChapter.fromJson(e))
              .toList() ??
          [], //
    );
  }
}

class ComicGenre {
  final String title;
  final String slug;

  ComicGenre({required this.title, required this.slug});

  factory ComicGenre.fromJson(Map<String, dynamic> json) {
    return ComicGenre(
      title: json['title'] ?? '', //
      slug: json['slug'] ?? '', //
    );
  }
}

class DetailChapter {
  final String title;
  final String slug;
  final String date;

  DetailChapter({
    required this.title,
    required this.slug,
    required this.date,
  });

  factory DetailChapter.fromJson(Map<String, dynamic> json) {
    return DetailChapter(
      // Mengganti baris baru (\n) dengan spasi agar rapi di UI
      title: (json['title'] ?? '').replaceAll('\n', ' '), //
      slug: json['slug'] ?? '', //
      date: json['date'] ?? '', //
    );
  }
}