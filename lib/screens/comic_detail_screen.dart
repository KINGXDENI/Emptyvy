import 'package:flutter/material.dart';
import '../models/comic_detail_model.dart';
import '../services/api_service.dart';
import 'comic_read_screen.dart'; // Pastikan import ini ada untuk navigasi baca

class ComicDetailScreen extends StatefulWidget {
  final String slug; // Slug diterima dari halaman Home

  const ComicDetailScreen({super.key, required this.slug});

  @override
  State<ComicDetailScreen> createState() => _ComicDetailScreenState();
}

class _ComicDetailScreenState extends State<ComicDetailScreen> {
  late Future<ComicDetailData> _futureDetail;
  bool _isAscending =
      false; // State untuk mengurutkan chapter (Terbaru/Terlama)

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _futureDetail = ApiService().fetchComicDetail(widget.slug);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detail Komik",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // Placeholder untuk fitur share
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fitur Share segera hadir")),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<ComicDetailData>(
        future: _futureDetail,
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
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Gagal memuat detail.\n${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      child: const Text("Coba Lagi"),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;

            // Logika Sorting Chapter
            // Kita copy list agar tidak mengubah data asli secara permanen
            final chapters = List<DetailChapter>.from(data.chapters);
            if (_isAscending) {
              // Urutkan dari Chapter 1 ke Chapter Terakhir (Ascending)
              // Logika sort sederhana berdasarkan string title.
              // Untuk hasil lebih akurat, parsing nomor chapter diperlukan,
              // tapi compareTo string cukup untuk kebutuhan dasar.
              chapters.sort((a, b) => a.title.compareTo(b.title));
            } else {
              // Default API biasanya Descending (Terbaru di atas), jadi biarkan atau sort balik
              // chapters.sort((a, b) => b.title.compareTo(a.title));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER SECTION (Poster & Info Utama) ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          data.image,
                          width: 110,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 110,
                            height: 160,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Info Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              Icons.star,
                              data.rating,
                              Colors.amber,
                            ),
                            const SizedBox(height: 4),
                            _buildInfoRow(
                              Icons.circle,
                              data.status,
                              data.status.toLowerCase() == "ongoing"
                                  ? Colors.green
                                  : Colors.blue,
                            ),
                            const SizedBox(height: 4),
                            _buildInfoRow(
                              Icons.book,
                              data.type,
                              Colors.redAccent,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Author: ${data.author}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              "Released: ${data.released}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // --- GENRE CHIPS ---
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: data.genres.map((genre) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          genre.title,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // --- ACTION BUTTONS (Baca Awal & Akhir) ---
                  if (data.chapters.isNotEmpty)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Baca Chapter Terlama (Paling Bawah di list asli)
                              final firstCh = data.chapters.last;
                              _openReader(firstCh.slug);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white10,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Chapter Awal"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Baca Chapter Terbaru (Paling Atas di list asli)
                              final lastCh = data.chapters.first;
                              _openReader(lastCh.slug);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Baca Terbaru"),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // --- SYNOPSIS ---
                  const Text(
                    "Sinopsis",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data.synopsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- CHAPTER HEADER & FILTER ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Chapters (${data.chapters.length})",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isAscending = !_isAscending;
                          });
                        },
                        icon: Icon(
                          _isAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: Colors.redAccent,
                        ),
                        tooltip: "Urutkan Chapter",
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // --- CHAPTER LIST ---
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: chapters.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final chapter = chapters[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          onTap: () {
                            // NAVIGASI KE LAYAR BACA
                            _openReader(chapter.slug);
                          },
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 0,
                          ),
                          title: Text(
                            chapter.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            chapter.date,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Colors.white24,
                          ),
                        ),
                      );
                    },
                  ),
                  // Tambahan padding bawah agar list paling bawah tidak tertutup nav bar (jika ada)
                  const SizedBox(height: 20),
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

  // Helper untuk membuka Reader
  void _openReader(String chapterSlug) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComicReadScreen(chapterSlug: chapterSlug),
      ),
    );
  }

  // Widget Helper untuk baris info (Rating, Status, Type)
  Widget _buildInfoRow(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 14),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
