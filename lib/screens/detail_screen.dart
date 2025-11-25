import 'package:flutter/material.dart';
import '../models/anime_detail_model.dart';
import '../services/api_service.dart';
import 'player_screen.dart'; // Pastikan file player_screen.dart sudah ada

class DetailScreen extends StatefulWidget {
  final String slug;

  const DetailScreen({super.key, required this.slug});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<AnimeDetailData> _futureDetail;

  @override
  void initState() {
    super.initState();
    _futureDetail = ApiService().fetchAnimeDetail(widget.slug);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Background gelap
      body: FutureBuilder<AnimeDetailData>(
        future: _futureDetail,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            );
          }
          // 2. Error State
          else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Error: ${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          }
          // 3. Data Not Found
          else if (!snapshot.hasData) {
            return const Center(
              child: Text(
                "Data tidak ditemukan",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final anime = snapshot.data!;

          return CustomScrollView(
            slivers: [
              // === HEADER GAMBAR (SLIVER APP BAR) ===
              SliverAppBar(
                expandedHeight: 320.0,
                pinned: true, // Header tetap terlihat saat scroll
                backgroundColor: const Color(0xFF121212),
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 1. Gambar Background (Blur/Darkened)
                      Image.network(
                        anime.poster,
                        fit: BoxFit.cover,
                        color: Colors.black.withOpacity(0.6), // Gelapkan gambar
                        colorBlendMode: BlendMode.darken,
                        errorBuilder: (ctx, err, stack) =>
                            Container(color: Colors.grey[900]),
                      ),

                      // 2. Gradient dari bawah ke atas supaya teks menyatu
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              const Color(0xFF121212).withOpacity(0.5),
                              const Color(0xFF121212),
                            ],
                          ),
                        ),
                      ),

                      // 3. Poster Utama di Tengah
                      Center(
                        child: Container(
                          height: 200,
                          width: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                            image: DecorationImage(
                              image: NetworkImage(anime.poster),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // === KONTEN BODY ===
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul Anime
                      Center(
                        child: Text(
                          anime.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Info Rating, Status, Studio
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            anime.rating,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text("|", style: TextStyle(color: Colors.grey)),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: anime.status == "Ongoing"
                                  ? Colors.redAccent
                                  : Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              anime.status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // List Genre
                      Center(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: anime.genres.map((genre) {
                            return Chip(
                              label: Text(
                                genre.name,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: const Color(0xFF2C2C2C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.zero,
                              side: BorderSide.none,
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Sinopsis
                      const Text(
                        "Sinopsis",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        anime.synopsis.isEmpty
                            ? "Tidak ada sinopsis."
                            : anime.synopsis,
                        style: const TextStyle(color: Colors.grey, height: 1.5),
                        textAlign: TextAlign.justify,
                      ),

                      const SizedBox(height: 32),

                      // === DAFTAR EPISODE ===
                      const Text(
                        "Daftar Episode",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // List Episode Vertikal
                      ListView.builder(
                        physics:
                            const NeverScrollableScrollPhysics(), // Scroll ikut parent
                        shrinkWrap: true,
                        itemCount: anime.episodeLists.length,
                        itemBuilder: (context, index) {
                          final ep = anime.episodeLists[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "#${ep.episodeNumber}",
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                ep.episode,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.play_circle_fill,
                                color: Colors.white70,
                              ),
                              onTap: () {
                                // Navigasi ke Player Screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PlayerScreen(slug: ep.slug),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // === REKOMENDASI ANIME ===
                      if (anime.recommendations.isNotEmpty) ...[
                        const Text(
                          "Rekomendasi",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 200,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: anime.recommendations.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final rec = anime.recommendations[index];
                              return GestureDetector(
                                onTap: () {
                                  // Navigasi Recursive (Buka Detail Baru)
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailScreen(slug: rec.slug),
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  width: 110,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          rec.poster,
                                          width: 110,
                                          height: 150,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, stack) =>
                                              Container(
                                                width: 110,
                                                height: 150,
                                                color: Colors.grey[800],
                                              ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        rec.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
