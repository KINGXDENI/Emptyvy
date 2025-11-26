import 'dart:async'; // Untuk Timer Auto Scroll
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/comic_read_model.dart';
import '../models/comic_detail_model.dart'; // Import model DetailChapter
import '../services/api_service.dart';

class ComicReadScreen extends StatefulWidget {
  final String chapterSlug;
  final String comicTitle;
  final String chapterTitle;
  final List<DetailChapter> chapterList; // Data seluruh chapter

  const ComicReadScreen({
    super.key,
    required this.chapterSlug,
    required this.comicTitle,
    required this.chapterTitle,
    required this.chapterList,
  });

  @override
  State<ComicReadScreen> createState() => _ComicReadScreenState();
}

class _ComicReadScreenState extends State<ComicReadScreen> {
  late Future<ComicReadData> _futureChapter;
  final ScrollController _scrollController = ScrollController();
  bool _showUI = true;

  // Navigasi Chapter
  String? _currentChapterSlug;
  String? _prevChapterSlug;
  String? _nextChapterSlug;
  String _currentChapterTitle = "";

  // Auto Scroll
  bool _isAutoScrolling = false;
  double _scrollSpeed = 2.0;

  @override
  void initState() {
    super.initState();
    _currentChapterSlug = widget.chapterSlug;
    _currentChapterTitle = widget.chapterTitle;
    _loadData(_currentChapterSlug!);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // --- PERBAIKAN PENTING ---
    // Jangan panggil _stopAutoScroll() di sini karena mengandung setState.
    // Cukup set variabel ke false agar loop berhenti.
    _isAutoScrolling = false;

    _scrollController.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  void _loadData(String slug) {
    // Membungkus fetch API
    final future = ApiService().fetchComicChapter(slug);

    setState(() {
      _futureChapter = future;
    });

    // Menangani hasil future untuk update tombol next/prev
    future
        .then((data) {
          if (!mounted)
            return; // Cek agar tidak error jika widget sudah ditutup

          setState(() {
            _prevChapterSlug = data.prevSlug;
            _nextChapterSlug = data.nextSlug;
          });
        })
        .catchError((_) {
          // Handle error secara silent atau tambahkan log
        });
  }

  // --- LOGIC GANTI CHAPTER ---
  void _navigateToChapter(String? slug) {
    if (slug != null) {
      _stopAutoScroll(); // Stop scroll saat pindah chapter

      String newTitle = _getChapterTitle(slug);

      setState(() {
        _currentChapterSlug = slug;
        _currentChapterTitle = newTitle;

        // Reset scroll ke atas
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }

        // Load data baru
        _loadData(slug);
      });
    }
  }

  String _getChapterTitle(String slug) {
    try {
      final chapter = widget.chapterList.firstWhere((c) => c.slug == slug);
      return chapter.title;
    } catch (e) {
      return "Chapter";
    }
  }

  // --- LOGIC AUTO SCROLL ---
  void _toggleAutoScroll() {
    if (_isAutoScrolling) {
      _stopAutoScroll();
    } else {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    setState(() {
      _isAutoScrolling = true;
      if (_showUI) _toggleUI(); // Sembunyikan UI agar fokus baca
    });
    _scrollStep();
  }

  void _stopAutoScroll() {
    // Pastikan widget masih ada sebelum panggil setState
    if (mounted) {
      setState(() {
        _isAutoScrolling = false;
      });
    } else {
      _isAutoScrolling = false;
    }
  }

  void _scrollStep() {
    if (!_isAutoScrolling || !_scrollController.hasClients || !mounted) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    // Jika sudah mentok bawah, berhenti
    if (currentScroll >= maxScroll) {
      _stopAutoScroll();
      return;
    }

    _scrollController
        .animateTo(
          currentScroll + _scrollSpeed,
          duration: const Duration(milliseconds: 16), // ~60 FPS
          curve: Curves.linear,
        )
        .then((_) {
          // Panggil lagi secara rekursif jika masih aktif dan mounted
          if (_isAutoScrolling && mounted) _scrollStep();
        });
  }

  // --- LOGIC UI ---
  void _toggleUI() {
    setState(() {
      _showUI = !_showUI;
      if (_showUI) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      }
    });
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: 180,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Kecepatan Auto Scroll",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.speed, color: Colors.white54),
                      Expanded(
                        child: Slider(
                          value: _scrollSpeed,
                          min: 1.0,
                          max: 10.0,
                          activeColor: Colors.redAccent,
                          inactiveColor: Colors.grey[800],
                          onChanged: (value) {
                            setModalState(() => _scrollSpeed = value);
                            setState(() => _scrollSpeed = value);
                          },
                        ),
                      ),
                      Text(
                        "${_scrollSpeed.toStringAsFixed(1)}x",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showChapterListModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white12)),
                  ),
                  child: const Center(
                    child: Text(
                      "Daftar Chapter",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: widget.chapterList.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Colors.white12),
                    itemBuilder: (context, index) {
                      final chapter = widget.chapterList[index];
                      final isSelected = chapter.slug == _currentChapterSlug;

                      return ListTile(
                        tileColor: isSelected
                            ? Colors.redAccent.withOpacity(0.1)
                            : null,
                        title: Text(
                          chapter.title,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.redAccent
                                : Colors.white70,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Colors.redAccent)
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToChapter(chapter.slug);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double topSafeArea = MediaQuery.of(context).padding.top;
    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,

      // --- APP BAR ---
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 20),
        child: AnimatedOpacity(
          opacity: _showUI ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                shadows: [Shadow(blurRadius: 10, color: Colors.black)],
              ),
              onPressed: () => Navigator.pop(context),
            ),
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.comicTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
                Text(
                  _currentChapterTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.home,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                ),
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
              ),
            ],
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
            ),
          ),
        ),
      ),

      body: FutureBuilder<ComicReadData>(
        future: _futureChapter,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => _loadData(_currentChapterSlug!),
                    child: const Text(
                      "Coba Lagi",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;

            return GestureDetector(
              onTap: _toggleUI,
              child: Stack(
                children: [
                  // --- GAMBAR ---
                  InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 3.0,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: kToolbarHeight + topSafeArea + 20,
                          bottom: 100 + bottomSafeArea,
                        ),
                        child: Column(
                          children: data.images
                              .map((url) => _buildImageItem(url))
                              .toList(),
                        ),
                      ),
                    ),
                  ),

                  // --- BOTTOM NAV BAR ---
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedOpacity(
                      opacity: _showUI ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        padding: EdgeInsets.only(
                          top: 15,
                          bottom: 10 + bottomSafeArea,
                          left: 20,
                          right: 20,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.9),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // 1. Prev
                            _buildNavBtn(
                              Icons.skip_previous_rounded,
                              _prevChapterSlug,
                              "Prev",
                            ),

                            // 2. Settings
                            _buildIconBtn(
                              Icons.settings,
                              _showSettingsModal,
                              tooltip: "Pengaturan",
                            ),

                            // 3. Play/Pause
                            _buildIconBtn(
                              _isAutoScrolling
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_fill,
                              _toggleAutoScroll,
                              isHighlight: _isAutoScrolling,
                              size: 40,
                              tooltip: "Auto Scroll",
                            ),

                            // 4. List Chapter
                            _buildIconBtn(
                              Icons.list,
                              _showChapterListModal,
                              tooltip: "List Chapter",
                            ),

                            // 5. Next / HOME (Ganti Icon Check jadi Home)
                            if (_nextChapterSlug != null)
                              _buildNavBtn(
                                Icons.skip_next_rounded,
                                _nextChapterSlug,
                                "Next",
                              )
                            else
                              _buildIconBtn(
                                Icons.home, // Icon Home untuk selesai
                                () {
                                  Navigator.of(
                                    context,
                                  ).popUntil((route) => route.isFirst);
                                },
                                isHighlight: true,
                                tooltip: "Kembali ke Home",
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // --- FLOATING SCROLL BTN ---
                  Positioned(
                    right: 16,
                    bottom: 120 + bottomSafeArea,
                    child: AnimatedOpacity(
                      opacity: _showUI ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        children: [
                          _buildScrollBtn(
                            Icons.keyboard_arrow_up,
                            _scrollToTop,
                          ),
                          const SizedBox(height: 12),
                          _buildScrollBtn(
                            Icons.keyboard_arrow_down,
                            _scrollToBottom,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // --- HELPERS ---

  Widget _buildImageItem(String url) {
    return Image.network(
      url,
      fit: BoxFit.fitWidth,
      width: double.infinity,
      loadingBuilder: (ctx, child, progress) {
        if (progress == null) return child;
        return Container(
          height: 300,
          color: const Color(0xFF101010),
          child: Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                  : null,
              color: Colors.redAccent.withOpacity(0.5),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => Container(
        height: 150,
        alignment: Alignment.center,
        color: const Color(0xFF151515),
        child: const Icon(Icons.broken_image, color: Colors.white24),
      ),
    );
  }

  Widget _buildNavBtn(IconData icon, String? slug, String tooltip) {
    final bool isEnabled = slug != null;
    return IconButton(
      onPressed: isEnabled ? () => _navigateToChapter(slug) : null,
      icon: Icon(
        icon,
        size: 30,
        color: isEnabled ? Colors.white : Colors.white24,
      ),
      tooltip: tooltip,
    );
  }

  Widget _buildIconBtn(
    IconData icon,
    VoidCallback onTap, {
    bool isHighlight = false,
    double size = 26,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? "",
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: size,
          color: isHighlight ? Colors.redAccent : Colors.white,
        ),
      ),
    );
  }

  Widget _buildScrollBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
