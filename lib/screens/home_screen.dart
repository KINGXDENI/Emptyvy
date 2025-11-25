import 'package:emptyvy/models/donghua_model.dart';
import 'package:emptyvy/screens/donghua_detail_screen.dart';
import 'package:emptyvy/screens/donghua_see_all_screen.dart';
import 'package:flutter/material.dart';
import '../models/anime_model.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';
import 'see_all_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex =
      0; // Index untuk melacak tab aktif (0: Anime, 1: Donghua, 2: Comic)

  // Daftar tampilan untuk setiap tab
  final List<Widget> _tabs = [
    const AnimeTab(), // Tab 0: Kode Home lama Anda
    const DonghuaTab(), // Tab 1: Placeholder Donghua
    const ComicTab(), // Tab 2: Placeholder Comic
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Background Gelap Utama
      appBar: AppBar(
        title: const Text(
          'Emptyvy',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            tooltip: 'Cari',
            onPressed: () {
              // Cek Tab Aktif
              // 0: Anime, 1: Donghua, 2: Comic
              bool isDonghuaSearch = _currentIndex == 1; 

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    isDonghua: isDonghuaSearch, // Kirim parameter
                  ),
                ),
              );
            },
          ),
        ],
      ),
      // Menggunakan IndexedStack agar state (scroll position) tab Anime tidak hilang saat pindah tab
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: const Color(0xFF1E1E1E), // Warna background navbar
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: const Color(0xFF1E1E1E),
          selectedItemColor: Colors.redAccent,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed, // Agar 3 item tetap stabil
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.movie_filter_outlined),
              activeIcon: Icon(Icons.movie_filter),
              label: 'Anime',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.live_tv_outlined),
              activeIcon: Icon(Icons.live_tv),
              label: 'Donghua',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              activeIcon: Icon(Icons.book),
              label: 'Comic',
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 1. ANIME TAB (Logika Home Lama Anda dipindah ke sini)
// ============================================================================
class AnimeTab extends StatefulWidget {
  const AnimeTab({super.key});

  @override
  State<AnimeTab> createState() => _AnimeTabState();
}

class _AnimeTabState extends State<AnimeTab> {
  late Future<AnimeHomeData> _futureAnimeData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _futureAnimeData = ApiService().fetchHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Logika RefreshIndicator dan FutureBuilder asli Anda
    return RefreshIndicator(
      onRefresh: () async {
        _loadData();
        await Future.delayed(const Duration(seconds: 1));
      },
      color: Colors.redAccent,
      backgroundColor: const Color(0xFF1E1E1E),
      child: FutureBuilder<AnimeHomeData>(
        future: _futureAnimeData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi_off,
                      color: Colors.redAccent,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Gagal terhubung ke server.\n${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Coba Lagi"),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Ongoing
                  _buildSectionHeader(
                    context,
                    "Sedang Tayang",
                    AnimeType.ongoing,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 240,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: data.ongoingAnime.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return _buildOngoingCard(
                          context,
                          data.ongoingAnime[index],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section Complete
                  _buildSectionHeader(
                    context,
                    "Baru Tamat",
                    AnimeType.complete,
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: data.completeAnime.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildCompleteCard(
                        context,
                        data.completeAnime[index],
                      );
                    },
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text(
                "Tidak ada data",
                style: TextStyle(color: Colors.white),
              ),
            );
          }
        },
      ),
    );
  }

  // --- Widget Helpers dipindah ke sini (Private Methods) ---

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    AnimeType type,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SeeAllScreen(type: type),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white54,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOngoingCard(BuildContext context, OngoingAnime anime) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(slug: anime.slug),
          ),
        );
      },
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      anime.poster,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [
                            BoxShadow(color: Colors.black45, blurRadius: 4),
                          ],
                        ),
                        child: Text(
                          anime.currentEpisode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              anime.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              anime.releaseDay,
              style: TextStyle(color: Colors.grey[400], fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteCard(BuildContext context, CompleteAnime anime) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(slug: anime.slug),
          ),
        );
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.network(
                anime.poster,
                width: 75,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(width: 75, color: Colors.grey[800]),
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
                      anime.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          anime.rating,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.layers, color: Colors.grey, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "${anime.episodeCount} Eps",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.redAccent,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 2. DONGHUA TAB (Placeholder)
// ============================================================================
class DonghuaTab extends StatefulWidget {
  const DonghuaTab({super.key});

  @override
  State<DonghuaTab> createState() => _DonghuaTabState();
}

class _DonghuaTabState extends State<DonghuaTab> {
  late Future<DonghuaHomeData> _futureDonghua;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _futureDonghua = ApiService().fetchDonghuaHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadData();
        await Future.delayed(const Duration(seconds: 1));
      },
      color: Colors.redAccent,
      backgroundColor: const Color(0xFF1E1E1E),
      child: FutureBuilder<DonghuaHomeData>(
        future: _futureDonghua,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Gagal memuat: ${snapshot.error}",
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Section 1: Rilis Terbaru ---
                  _buildHeader("Rilis Terbaru", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DonghuaSeeAllScreen(
                          category: DonghuaCategory.latest,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: data.latestRelease.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return _buildCard(
                          context,
                          data.latestRelease[index],
                          isPortrait: true,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- Section 2: Tamat / Completed ---
                  _buildHeader("Donghua Tamat", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DonghuaSeeAllScreen(
                          category: DonghuaCategory.completed,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: data.completedDonghua.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildCard(
                        context,
                        data.completedDonghua[index],
                        isPortrait: false,
                      );
                    },
                  ),
                ],
              ),
            );
          }
          return const Center(
            child: Text(
              "Tidak ada data",
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          InkWell(
            onTap: onTap, // <--- Panggil callback di sini
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white54,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    DonghuaItem item, {
    required bool isPortrait,
  }) {
    return GestureDetector(
      onTap: () {
        // [FIX] Logika membersihkan slug
        // Jika slug mengandung "-episode-", kita ambil bagian depannya saja
        // agar menjadi slug series yang valid untuk DonghuaDetailScreen.
        // Contoh: "judul-donghua-episode-120-sub-indo" -> "judul-donghua"
        String fixedSlug = item.slug;
        if (fixedSlug.contains("-episode-")) {
          fixedSlug = fixedSlug.split("-episode-")[0];
        }

        // Tetap ke Detail Screen (Tanpa Player) dengan slug yang sudah diperbaiki
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DonghuaDetailScreen(slug: fixedSlug),
          ),
        );
      },
      child: isPortrait
          ? SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            item.poster,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) =>
                                Container(color: Colors.grey[800]),
                          ),
                          // Badge Episode
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.currentEpisode,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : Container(
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: Image.network(
                      item.poster,
                      width: 75,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) =>
                          Container(width: 75, color: Colors.grey[800]),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
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
// ============================================================================
// 3. COMIC TAB (Placeholder)
// ============================================================================
class ComicTab extends StatelessWidget {
  const ComicTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book, size: 64, color: Colors.white24),
          SizedBox(height: 16),
          Text(
            "Fitur Comic Segera Hadir",
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
