import 'package:flutter/material.dart';
import '../models/comic_read_model.dart';
import '../services/api_service.dart';

class ComicReadScreen extends StatefulWidget {
  final String chapterSlug;

  const ComicReadScreen({super.key, required this.chapterSlug});

  @override
  State<ComicReadScreen> createState() => _ComicReadScreenState();
}

class _ComicReadScreenState extends State<ComicReadScreen> {
  late Future<ComicReadData> _futureChapter;

  @override
  void initState() {
    super.initState();
    _loadData(widget.chapterSlug);
  }

  // Method load data yang bisa dipanggil ulang saat ganti chapter
  void _loadData(String slug) {
    setState(() {
      _futureChapter = ApiService().fetchComicChapter(slug);
    });
  }

  void _navigateToChapter(String slug) {
    // Mengganti halaman saat ini dengan chapter baru agar tumpukan navigasi tidak terlalu dalam
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ComicReadScreen(chapterSlug: slug),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background hitam agar fokus
      // AppBar transparan/hitam
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.8),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Membaca",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        elevation: 0,
      ),
      body: FutureBuilder<ComicReadData>(
        future: _futureChapter,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            
            return Column(
              children: [
                // --- AREA GAMBAR (Expanded) ---
                Expanded(
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 4.0, // Bisa zoom sampai 4x
                    child: ListView.builder(
                      // Cache extent agar gambar di bawah pre-load lebih awal
                      cacheExtent: 500, 
                      padding: EdgeInsets.zero,
                      itemCount: data.images.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          data.images[index],
                          fit: BoxFit.fitWidth, // Lebar menyesuaikan layar
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200, // Placeholder height
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.grey[800],
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 100,
                              color: Colors.grey[900],
                              alignment: Alignment.center,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, color: Colors.white54),
                                  SizedBox(height: 4),
                                  Text("Gagal memuat gambar", style: TextStyle(color: Colors.white24, fontSize: 10)),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                // --- NAVIGATION BAR (Sticky Bottom) ---
                Container(
                  color: const Color(0xFF1E1E1E),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tombol Prev
                      ElevatedButton.icon(
                        onPressed: data.prevSlug != null
                            ? () => _navigateToChapter(data.prevSlug!)
                            : null, // Disable jika null
                        icon: const Icon(Icons.arrow_back_ios, size: 14),
                        label: const Text("Prev"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.black12,
                          disabledForegroundColor: Colors.white24,
                        ),
                      ),
                      
                      const Text(
                        "Navigasi",
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),

                      // Tombol Next
                      ElevatedButton.icon(
                        onPressed: data.nextSlug != null
                            ? () => _navigateToChapter(data.nextSlug!)
                            : null, // Disable jika null
                        // Ikon di kanan
                        icon: const Icon(Icons.arrow_forward_ios, size: 14),
                        label: const Text("Next"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.black12,
                          disabledForegroundColor: Colors.white24,
                          // Swap icon ke kanan dengan Directionality (opsional) atau manual row
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text("Tidak ada data", style: TextStyle(color: Colors.white)));
        },
      ),
    );
  }
}