import 'package:flutter/material.dart';
import '../models/comic_detail_model.dart';
import '../services/api_service.dart';
import 'comic_read_screen.dart';

class ComicDetailScreen extends StatefulWidget {
  final String slug;

  const ComicDetailScreen({super.key, required this.slug});

  @override
  State<ComicDetailScreen> createState() => _ComicDetailScreenState();
}

class _ComicDetailScreenState extends State<ComicDetailScreen> {
  late Future<ComicDetailData> _futureDetail;
  bool _isAscending = false; // State sorting

  // --- Pagination State ---
  int _currentPage = 0;
  final int _itemsPerPage = 20;

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

            // 1. Sorting Logic
            final allChapters = List<DetailChapter>.from(data.chapters);
            if (_isAscending) {
              allChapters.sort((a, b) => a.title.compareTo(b.title));
            }

            // 2. Pagination Logic
            final totalChapters = allChapters.length;
            final totalPages = (totalChapters / _itemsPerPage).ceil();

            if (_currentPage >= totalPages && totalPages > 0) {
              _currentPage = totalPages - 1;
            }

            final int startIndex = _currentPage * _itemsPerPage;
            final int endIndex = (startIndex + _itemsPerPage < totalChapters)
                ? startIndex + _itemsPerPage
                : totalChapters;

            final displayedChapters = (totalChapters > 0)
                ? allChapters.sublist(startIndex, endIndex)
                : <DetailChapter>[];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

                  // --- GENRES ---
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

                  // --- ACTION BUTTONS ---
                  if (data.chapters.isNotEmpty)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final firstCh = data.chapters.last;
                              // Pass full chapter list
                              _openReader(
                                firstCh.slug,
                                data.title,
                                firstCh.title,
                                data.chapters,
                              );
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
                              final lastCh = data.chapters.first;
                              // Pass full chapter list
                              _openReader(
                                lastCh.slug,
                                data.title,
                                lastCh.title,
                                data.chapters,
                              );
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

                  // --- CHAPTER LIST HEADER ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Chapters ($totalChapters)",
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
                            _currentPage = 0;
                          });
                        },
                        icon: Icon(
                          _isAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // --- CHAPTER LIST ITEMS ---
                  if (displayedChapters.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "Tidak ada chapter",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayedChapters.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final chapter = displayedChapters[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            onTap: () => _openReader(
                              chapter.slug,
                              data.title,
                              chapter.title,
                              data.chapters,
                            ),
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

                  // --- PAGINATION CONTROLS ---
                  if (totalPages > 1) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _currentPage > 0
                                ? () => setState(() => _currentPage--)
                                : null,
                            icon: Icon(
                              Icons.arrow_back_ios,
                              size: 18,
                              color: _currentPage > 0
                                  ? Colors.white
                                  : Colors.white24,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              "Hal ${_currentPage + 1} / $totalPages",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _currentPage < totalPages - 1
                                ? () => setState(() => _currentPage++)
                                : null,
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color: _currentPage < totalPages - 1
                                  ? Colors.white
                                  : Colors.white24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
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

  // --- UPDATED NAVIGATOR ---
  // Menerima List<DetailChapter> untuk dikirim ke Reader
  void _openReader(
    String chapterSlug,
    String comicTitle,
    String chapterTitle,
    List<DetailChapter> chapters,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComicReadScreen(
          chapterSlug: chapterSlug,
          comicTitle: comicTitle,
          chapterTitle: chapterTitle,
          chapterList: chapters, // Kirim list chapter
        ),
      ),
    );
  }

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
