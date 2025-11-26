import 'package:flutter/material.dart';
import '../services/api_service.dart';

// --- IMPORT MODELS ---
// Pastikan path import ini sesuai dengan struktur folder Anda
import '../models/search_genre_model.dart'; // Untuk Anime (jika pakai model ini)
import '../models/donghua_model.dart'; // Untuk Donghua
import '../models/comic_search_model.dart'; // Untuk Comic (Model baru di atas)

// --- IMPORT DETAILS SCREENS ---
import 'detail_screen.dart'; // Detail Anime
import 'donghua_detail_screen.dart'; // Detail Donghua
import 'comic_detail_screen.dart'; // Detail Komik

class SearchScreen extends StatefulWidget {
  final bool isDonghua;
  final bool isComic;

  const SearchScreen({super.key, this.isDonghua = false, this.isComic = false});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final ApiService _apiService = ApiService();

  List<dynamic> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  // --- LOGIKA PENCARIAN UTAMA ---
  void _doSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _results.clear();
    });

    try {
      List<dynamic> data = [];

      if (widget.isComic) {
        // 1. Cari Komik
        // Pastikan api_service.dart memiliki method searchComic(query)
        data = await _apiService.searchComic(query);
      } else if (widget.isDonghua) {
        // 2. Cari Donghua
        data = await _apiService.searchDonghua(query);
      } else {
        // 3. Cari Anime (Default)
        // Pastikan api_service.dart memiliki method searchAnime(query)
        // Jika belum ada, ganti dengan method yang sesuai di API Service Anda
        data = await _apiService.searchAnime(query);
      }

      if (mounted) {
        setState(() {
          _results = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error searching: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan Hint Text
    String hintText = "Cari Anime...";
    if (widget.isDonghua) hintText = "Cari Donghua...";
    if (widget.isComic) hintText = "Cari Komik/Manga...";

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: TextField(
          controller: _controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: _doSearch,
          autofocus: true,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => _doSearch(_controller.text),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.redAccent),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: Colors.grey[800]),
            const SizedBox(height: 16),
            Text(
              "Ketik judul untuk mulai mencari",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      return const Center(
        child: Text("Tidak ditemukan", style: TextStyle(color: Colors.white)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _results[index];

        // --- RENDER BERDASARKAN TIPE ---

        // A. COMIC
        if (widget.isComic) {
          // Asumsikan item adalah ComicSearchItem
          return _buildComicItem(item);
        }
        // B. DONGHUA
        else if (widget.isDonghua) {
          // Asumsikan item adalah DonghuaItem
          return _buildDonghuaItem(item);
        }
        // C. ANIME (Default)
        else {
          // Sesuaikan dengan model Anime Anda (misal AnimeCardData atau AnimeSearchModel)
          return _buildAnimeItem(item);
        }
      },
    );
  }

  // --- WIDGET ITEM: KOMIK ---
  Widget _buildComicItem(ComicSearchItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ComicDetailScreen(slug: item.slug),
          ),
        );
      },
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Gambar
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(8),
              ),
              child: Image.network(
                item.image,
                width: 90,
                height: 130,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 90,
                  color: Colors.grey[800],
                  child: const Icon(Icons.broken_image, color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tipe & Rating
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            item.type,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          item.rating,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Latest Chapter
                    Row(
                      children: [
                        const Icon(
                          Icons.history,
                          color: Colors.redAccent,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.latestChapter,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET ITEM: DONGHUA ---
  Widget _buildDonghuaItem(dynamic item) {
    // Sesuaikan casting tipe data jika perlu, misal: item as DonghuaItem
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DonghuaDetailScreen(slug: item.slug),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                item.image,
                width: 60,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(width: 60, height: 80, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: item.status == "Ongoing"
                          ? Colors.blueAccent
                          : Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET ITEM: ANIME ---
  Widget _buildAnimeItem(dynamic item) {
    // Sesuaikan dengan Model Anime Anda
    // Misal: item.title, item.image, item.slug
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(slug: item.slug),
          ),
        );
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(8),
              ),
              child: Image.network(
                item.image, // Pastikan field ini ada di model Anime
                width: 70,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(width: 70, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title, // Pastikan field ini ada
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Jika ada info lain seperti rating/episode untuk anime, tampilkan di sini
                    const Text(
                      "Anime",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
