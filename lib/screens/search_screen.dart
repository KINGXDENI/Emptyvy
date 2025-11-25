import 'package:flutter/material.dart';
import '../models/search_genre_model.dart';
import '../models/donghua_model.dart'; // Import model Donghua
import '../services/api_service.dart';
import 'detail_screen.dart';
import 'donghua_detail_screen.dart'; // Import detail Donghua

class SearchScreen extends StatefulWidget {
  final bool isDonghua; // Parameter penentu

  const SearchScreen({super.key, this.isDonghua = false});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final ApiService _apiService = ApiService();

  // Gunakan List<dynamic> karena isinya bisa AnimeCardData atau DonghuaItem
  List<dynamic> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  void _doSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _results.clear();
    });

    try {
      if (widget.isDonghua) {
        // --- LOGIKA DONGHUA ---
        final data = await _apiService.searchDonghua(query);
        setState(() {
          _results = data;
        });
      } else {
        // --- LOGIKA ANIME ---
        final data = await _apiService.searchAnime(query);
        setState(() {
          _results = data;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String hintText = widget.isDonghua
        ? "Cari Donghua (contoh: Fairy Yao)..."
        : "Cari Anime (contoh: Boruto)...";

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        iconTheme: const IconThemeData(color: Colors.white),
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
            icon: const Icon(Icons.search),
            onPressed: () => _doSearch(_controller.text),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            )
          : _hasSearched && _results.isEmpty
          ? const Center(
              child: Text(
                "Tidak ditemukan",
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _results.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _results[index];

                // Variabel UI
                String title = "";
                String poster = "";
                String status = "";
                String ratingOrEps = "";
                String slug = "";

                // Ekstrak data berdasarkan tipe object
                if (item is AnimeCardData) {
                  title = item.title;
                  poster = item.poster;
                  status = item.status;
                  ratingOrEps = "⭐ ${item.rating}";
                  slug = item.slug;
                } else if (item is DonghuaItem) {
                  title = item.title;
                  poster = item.poster;
                  status = item.status;
                  ratingOrEps =
                      ""; // Donghua search JSON tidak ada rating/eps spesifik
                  slug = item.slug;
                }

                return GestureDetector(
                  onTap: () {
                    // Navigasi Berdasarkan Tipe
                    if (widget.isDonghua) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DonghuaDetailScreen(slug: slug),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(slug: slug),
                        ),
                      );
                    }
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
                            poster,
                            width: 70,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(width: 70, color: Colors.grey),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    if (ratingOrEps.isNotEmpty) ...[
                                      Text(
                                        ratingOrEps,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const Spacer(),
                                    ],

                                    // Status Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: status == "Ongoing"
                                            ? Colors.blueAccent
                                            : Colors.green,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        status,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
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
              },
            ),
    );
  }
}
