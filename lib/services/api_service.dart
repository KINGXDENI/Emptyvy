import 'dart:convert';
import 'package:emptyvy/models/comic_detail_model.dart';
import 'package:emptyvy/models/comic_read_model.dart';
import 'package:emptyvy/models/donghua_detail_model.dart';
import 'package:emptyvy/models/donghua_model.dart';
import 'package:emptyvy/models/pagination_model.dart';
import 'package:emptyvy/models/search_genre_model.dart';
import 'package:http/http.dart' as http;
import '../models/anime_model.dart';
import '../models/anime_detail_model.dart';
import '../models/episode_model.dart';
import '../models/comic_model.dart';

class ApiService {
  // Base Domain
  static const String _baseUrl = 'https://www.sankavollerei.com';

  /// Mengambil data untuk halaman Home
  Future<AnimeHomeData> fetchHomeData() async {
    final url = '$_baseUrl/anime/home';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 'success') {
          return AnimeHomeData.fromJson(data);
        } else {
          throw Exception('API Error: Status not success');
        }
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal memuat home: $e');
    }
  }

  /// Mengambil data untuk halaman Detail Anime berdasarkan Slug
  Future<AnimeDetailData> fetchAnimeDetail(String slug) async {
    // Format URL sesuai request: /anime/anime/:slug
    final url = '$_baseUrl/anime/anime/$slug';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 'success') {
          return AnimeDetailData.fromJson(data);
        } else {
          throw Exception('API Error: Status not success');
        }
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal memuat detail: $e');
    }
  }

  Future<OngoingPaginationResult> fetchOngoingAnimeByPage(int page) async {
    // URL: .../anime/ongoing-anime?page=1
    final url = '$_baseUrl/anime/ongoing-anime?page=$page';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return OngoingPaginationResult.fromJson(data);
        }
      }
      throw Exception('Gagal load ongoing page $page');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // 2. Fetch Complete dengan Paging
  Future<CompletePaginationResult> fetchCompleteAnimeByPage(int page) async {
    // URL: .../anime/complete-anime/2 (Sesuai request Anda formatnya path parameter)
    final url = '$_baseUrl/anime/complete-anime/$page';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return CompletePaginationResult.fromJson(data);
        }
      }
      throw Exception('Gagal load complete page $page');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // 1. Ambil Detail Episode (List Server & Navigasi)
  Future<EpisodeDetail> fetchEpisodeDetail(String slug) async {
    final url = '$_baseUrl/anime/episode/$slug';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return EpisodeDetail.fromJson(data);
        }
      }
      throw Exception('Gagal load episode');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // 2. Ambil URL Video Embed berdasarkan Server ID
  Future<String> fetchServerEmbedUrl(String serverId) async {
    // serverId dari JSON formatnya "/anime/server/..." jadi tinggal tempel ke domain
    final url = '$_baseUrl$serverId';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['url']; // Mengembalikan https://filedon.co/embed/...
        }
      }
      throw Exception('Gagal load server url');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // 1. Cari Anime
  Future<List<AnimeCardData>> searchAnime(String query) async {
    final url = '$_baseUrl/anime/search/$query';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success') {
          // Search return list langsung di dalam 'data'
          return (data['data'] as List)
              .map((e) => AnimeCardData.fromJson(e))
              .toList();
        }
      }
      return []; // Return kosong jika gagal/tidak ada
    } catch (e) {
      throw Exception('Gagal mencari anime: $e');
    }
  }

  // 2. Anime by Genre (Infinite Scroll)
  Future<GenreResult> fetchAnimeByGenre(String slug, int page) async {
    // URL: .../anime/genre/:slug?page=1
    final url = '$_baseUrl/anime/genre/$slug?page=$page';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success') {
          return GenreResult.fromJson(data);
        }
      }
      throw Exception('Gagal memuat genre');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Fetch Donghua Home
  Future<DonghuaHomeData> fetchDonghuaHome() async {
    const url = '$_baseUrl/anime/donghua/home/1';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success') {
          return DonghuaHomeData.fromJson(data);
        }
      }
      throw Exception('Gagal load Donghua Home');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Fetch Donghua See All (Latest/Ongoing)
  // type: 'latest' atau 'ongoing'
  Future<List<DonghuaItem>> fetchDonghuaList(String type, int page) async {
    // URL: .../anime/donghua/latest/1
    final url = '$_baseUrl/anime/donghua/$type/$page';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success') {
          // Tentukan key JSON berdasarkan tipe URL
          String jsonKey = '';
          if (type == 'latest') {
            jsonKey = 'latest_donghua';
          } else if (type == 'completed') {
            jsonKey = 'completed_donghua';
          } else if (type == 'ongoing') {
            jsonKey = 'ongoing_donghua';
          }

          if (jsonKey.isNotEmpty && data[jsonKey] != null) {
            return (data[jsonKey] as List)
                .map((e) => DonghuaItem.fromJson(e))
                .toList();
          }
        }
      }
      return []; // Return list kosong jika gagal/habis
    } catch (e) {
      throw Exception('Error fetch donghua list: $e');
    }
  }

  Future<DonghuaDetailData> fetchDonghuaDetail(String slug) async {
    // URL: .../anime/donghua/detail/:slug
    final url = '$_baseUrl/anime/donghua/detail/$slug';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // JSON Donghua Detail langsung mereturn object, tidak dibungkus "data": {} lagi
        // Berdasarkan struktur JSON yang kamu kirim:
        // { "status": "Completed", "title": "Little Fairy Yao", ... }

        // Cek apakah key title ada untuk memastikan data valid
        if (data['title'] != null) {
          return DonghuaDetailData.fromJson(data);
        }
      }
      throw Exception('Gagal load detail donghua');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // === TAMBAHKAN INI: Fetch Episode Donghua ===
  Future<EpisodeDetail> fetchDonghuaEpisode(String slug) async {
    // Perhatikan URL-nya beda: /anime/donghua/episode/
    final url = '$_baseUrl/anime/donghua/episode/$slug';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          // Kita asumsikan struktur JSON dalamnya sama dengan Anime
          // (punya stream_servers, next_episode, dll)
          return EpisodeDetail.fromJson(data);
        }
      }
      throw Exception('Gagal load episode donghua');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<DonghuaItem>> searchDonghua(String query) async {
    final url = '$_baseUrl/anime/donghua/search/$query';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // JSON-nya: { "creator": "...", "data": [...] }
        if (data['data'] != null) {
          return (data['data'] as List)
              .map((e) => DonghuaItem.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Gagal mencari donghua: $e');
    }
  }

  Future<ComicHomeData> fetchComicHome() async {
    const url = '$_baseUrl/comic/komikcast/home';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Cek struktur JSON root
        if (data['success'] == true && data['data'] != null) {
          return ComicHomeData.fromJson(data);
        }
      }
      throw Exception('Gagal load Comic Home');
    } catch (e) {
      throw Exception('Error fetching comic: $e');
    }
  }

  Future<ComicDetailData> fetchComicDetail(String slug) async {
    // URL: .../comic/komikcast/detail/:slug
    final url = '$_baseUrl/comic/komikcast/detail/$slug'; //

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Cek struktur JSON: "success": true dan "data" ada
        if (data['success'] == true && data['data'] != null) {
          return ComicDetailData.fromJson(data['data']); //
        }
      }
      throw Exception('Gagal load Detail Comic');
    } catch (e) {
      throw Exception('Error fetching comic detail: $e');
    }
  }

  // ... import model comic_read_model.dart pastikan sudah diimport

  // === TAMBAHKAN INI: Fetch Chapter Images ===
  Future<ComicReadData> fetchComicChapter(String slug) async {
    // URL: .../comic/komikcast/chapter/:slug
    final url = '$_baseUrl/comic/komikcast/chapter/$slug';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          return ComicReadData.fromJson(data['data']);
        }
      }
      throw Exception('Gagal load Chapter');
    } catch (e) {
      throw Exception('Error fetching chapter: $e');
    }
  }
}
