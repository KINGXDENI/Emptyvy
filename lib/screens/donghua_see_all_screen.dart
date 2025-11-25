import 'package:flutter/material.dart';
import '../models/donghua_model.dart';
import '../services/api_service.dart';
import 'player_screen.dart';
import 'donghua_detail_screen.dart';

// Enum untuk memudahkan pemanggilan tipe
enum DonghuaCategory { latest, completed, ongoing }

class DonghuaSeeAllScreen extends StatefulWidget {
  final DonghuaCategory category;

  const DonghuaSeeAllScreen({super.key, required this.category});

  @override
  State<DonghuaSeeAllScreen> createState() => _DonghuaSeeAllScreenState();
}

class _DonghuaSeeAllScreenState extends State<DonghuaSeeAllScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  List<DonghuaItem> _items = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _fetchData();

    // Listener untuk Infinite Scroll
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMoreData) {
        _fetchData();
      }
    });
  }

  // Helper untuk mendapatkan Judul dan String Type API
  String get _title {
    switch (widget.category) {
      case DonghuaCategory.latest:
        return "Rilis Terbaru";
      case DonghuaCategory.completed:
        return "Donghua Tamat";
      case DonghuaCategory.ongoing:
        return "Sedang Tayang";
    }
  }

  String get _apiType {
    switch (widget.category) {
      case DonghuaCategory.latest:
        return "latest";
      case DonghuaCategory.completed:
        return "completed";
      case DonghuaCategory.ongoing:
        return "ongoing";
    }
  }

  Future<void> _fetchData() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final newItems = await _apiService.fetchDonghuaList(
        _apiType,
        _currentPage,
      );

      setState(() {
        if (newItems.isEmpty) {
          _hasMoreData = false;
        } else {
          _items.addAll(newItems);
          _currentPage++;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          _title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF121212),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _items.isEmpty && _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            )
          : GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 Kolom
                childAspectRatio: 0.65, // Rasio Poster
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _items.length + (_hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                // Loading indicator di bawah grid
                if (index == _items.length) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.redAccent,
                      strokeWidth: 2,
                    ),
                  );
                }

                final item = _items[index];
                return _buildGridCard(item);
              },
            ),
    );
  }

  Widget _buildGridCard(DonghuaItem item) {
    return GestureDetector(
      onTap: () {
        // === LOGIKA NAVIGASI YANG SAMA DENGAN HOME ===
        if (item.isEpisode) {
          // Episode -> Player
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PlayerScreen(slug: item.slug, isDonghua: true),
            ),
          );
        } else {
          // Series -> Detail (Fix slug if needed)
          String fixedSlug = item.slug;
          if (fixedSlug.contains("-episode-")) {
            fixedSlug = fixedSlug.split("-episode-")[0];
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DonghuaDetailScreen(slug: fixedSlug),
            ),
          );
        }
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
                    item.poster,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) =>
                        Container(color: Colors.grey[800]),
                  ),
                  // Badge Episode / Status
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: item.isEpisode
                            ? Colors.redAccent
                            : (item.status == "Completed"
                                  ? Colors.green
                                  : Colors.blueAccent),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.isEpisode ? item.currentEpisode : item.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Icon Play jika Episode
                  if (item.isEpisode)
                    const Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        color: Colors.white70,
                        size: 24,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.title,
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
