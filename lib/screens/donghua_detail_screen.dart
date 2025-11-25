import 'package:flutter/material.dart';
import '../models/donghua_detail_model.dart';
import '../services/api_service.dart';
import 'player_screen.dart';

class DonghuaDetailScreen extends StatefulWidget {
  final String slug;

  const DonghuaDetailScreen({super.key, required this.slug});

  @override
  State<DonghuaDetailScreen> createState() => _DonghuaDetailScreenState();
}

class _DonghuaDetailScreenState extends State<DonghuaDetailScreen> {
  late Future<DonghuaDetailData> _futureDetail;

  @override
  void initState() {
    super.initState();
    _futureDetail = ApiService().fetchDonghuaDetail(widget.slug);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: FutureBuilder<DonghuaDetailData>(
        future: _futureDetail,
        builder: (context, snapshot) {
          // 1. Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            );
          }
          // 2. Error
          else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Error: ${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          }
          // 3. Data Kosong
          else if (!snapshot.hasData) {
            return const Center(
              child: Text(
                "Data tidak ditemukan",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final item = snapshot.data!;

          return CustomScrollView(
            slivers: [
              // === HEADER GAMBAR (SliverAppBar) ===
              SliverAppBar(
                expandedHeight: 300.0,
                pinned: true,
                backgroundColor: const Color(0xFF121212),
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background Image (Blur)
                      Image.network(
                        item.poster,
                        fit: BoxFit.cover,
                        color: Colors.black.withOpacity(0.6),
                        colorBlendMode: BlendMode.darken,
                        errorBuilder: (ctx, err, stack) =>
                            Container(color: Colors.black),
                      ),
                      // Poster Utama di Tengah
                      Center(
                        child: Container(
                          height: 180,
                          width: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                            image: DecorationImage(
                              image: NetworkImage(item.poster),
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
                      // Judul
                      Center(
                        child: Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          item.alterTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Info Grid (Icon + Teks)
                      _buildInfoRow(Icons.movie, item.type),
                      _buildInfoRow(Icons.timer, item.duration),
                      _buildInfoRow(Icons.calendar_today, item.released),
                      _buildInfoRow(Icons.business, item.studio),

                      const SizedBox(height: 16),

                      // Genres (Chip)
                      Wrap(
                        spacing: 8,
                        children: item.genres
                            .map(
                              (g) => Chip(
                                label: Text(
                                  g,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                                backgroundColor: Colors.blueAccent.withOpacity(
                                  0.2,
                                ),
                                padding: EdgeInsets.zero,
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            )
                            .toList(),
                      ),

                      const SizedBox(height: 20),

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
                        item.synopsis.isEmpty
                            ? "Tidak ada sinopsis."
                            : item.synopsis,
                        style: const TextStyle(color: Colors.grey, height: 1.5),
                      ),

                      const SizedBox(height: 24),

                      // Daftar Episode
                      const Text(
                        "Daftar Episode",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // List Episode
                      ListView.builder(
                        physics:
                            const NeverScrollableScrollPhysics(), // Scroll ikut parent
                        shrinkWrap: true,
                        itemCount: item.episodeList.length,
                        itemBuilder: (context, index) {
                          final ep = item.episodeList[index];
                          return Card(
                            color: const Color(0xFF1E1E1E),
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(
                                Icons.play_circle_outline,
                                color: Colors.blueAccent,
                              ),
                              title: Text(
                                ep.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                // Navigasi ke Player dengan Mode Donghua
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlayerScreen(
                                      slug: ep.slug,
                                      isDonghua:
                                          true, // PENTING: Aktifkan mode Donghua
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),

                      // Padding bawah extra
                      const SizedBox(height: 30),
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

  // Widget Helper untuk Info Baris
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
