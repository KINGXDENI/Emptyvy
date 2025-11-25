import 'package:flutter/material.dart';
import '../models/anime_model.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';

// Enum untuk menentukan tipe halaman
enum AnimeType { ongoing, complete }

class SeeAllScreen extends StatefulWidget {
  final AnimeType type;

  const SeeAllScreen({super.key, required this.type});

  @override
  State<SeeAllScreen> createState() => _SeeAllScreenState();
}

class _SeeAllScreenState extends State<SeeAllScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> _items = []; // Menyimpan list anime
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasNextPage = true;

  @override
  void initState() {
    super.initState();
    _fetchData(); // Load halaman 1 saat pertama buka

    // Listener untuk Infinite Scroll
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasNextPage) {
        _fetchData(); // Load next page
      }
    });
  }

  Future<void> _fetchData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.type == AnimeType.ongoing) {
        final result = await _apiService.fetchOngoingAnimeByPage(_currentPage);
        setState(() {
          _items.addAll(result.data);
          _hasNextPage = result.pagination.hasNextPage;
          if (_hasNextPage) _currentPage++;
        });
      } else {
        final result = await _apiService.fetchCompleteAnimeByPage(_currentPage);
        setState(() {
          _items.addAll(result.data);
          _hasNextPage = result.pagination.hasNextPage;
          if (_hasNextPage) _currentPage++;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == AnimeType.ongoing
        ? "Semua Ongoing"
        : "Semua Tamat";

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF121212),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _items.isEmpty && _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            )
          : GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 kolom
                childAspectRatio: 0.65, // Rasio poster
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount:
                  _items.length +
                  (_hasNextPage ? 1 : 0), // +1 untuk loading bawah
              itemBuilder: (context, index) {
                // Widget Loading di paling bawah grid
                if (index == _items.length) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.redAccent),
                  );
                }

                final anime = _items[index];
                return _buildAnimeGridCard(anime);
              },
            ),
    );
  }

  Widget _buildAnimeGridCard(dynamic anime) {
    // Handling polimorfisme sederhana karena fieldnya mirip tapi beda kelas
    String title = anime.title;
    String poster = anime.poster;
    String slug = anime.slug;
    String info = "";

    if (anime is OngoingAnime) {
      info = anime.currentEpisode;
    } else if (anime is CompleteAnime) {
      info = "⭐ ${anime.rating}";
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(slug: slug)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    poster,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: Colors.grey[800]),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        info,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
