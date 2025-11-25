import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/episode_model.dart';
import '../services/api_service.dart';

class PlayerScreen extends StatefulWidget {
  final String slug;
  final bool isDonghua; // Parameter pembeda (Anime Biasa vs Donghua)

  const PlayerScreen({
    super.key,
    required this.slug,
    this.isDonghua = false, // Default false (Anime Biasa)
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late WebViewController _webController;
  final ApiService _apiService = ApiService();

  // State Data
  EpisodeDetail? _episodeDetail;
  bool _isLoading = true; // Loading data API episode
  bool _isVideoLoading = false; // Loading konten WebView
  String? _currentEmbedUrl;

  // State Pilihan User
  StreamQuality? _selectedQuality;
  Server? _selectedServer;

  @override
  void initState() {
    super.initState();
    // 1. Inisialisasi WebView Controller
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isVideoLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isVideoLoading = false);
          },
          onWebResourceError: (error) {
            debugPrint("WebView Error: ${error.description}");
          },
        ),
      );

    // 2. Load Data Episode
    _loadEpisodeData(widget.slug);
  }

  /// Mengambil data detail episode dari API
  Future<void> _loadEpisodeData(String slug) async {
    setState(() => _isLoading = true);
    try {
      // LOGIKA PEMILIHAN API
      // Jika isDonghua == true, panggil API khusus Donghua
      // Jika false, panggil API Anime biasa
      final data = widget.isDonghua
          ? await _apiService.fetchDonghuaEpisode(slug)
          : await _apiService.fetchEpisodeDetail(slug);

      if (mounted) {
        setState(() {
          _episodeDetail = data;

          // Otomatis pilih kualitas terbaik (misal: 720p) atau default
          if (data.streamServers.isNotEmpty) {
            // Coba cari yang mengandung '720p', jika tidak ada ambil yang terakhir
            _selectedQuality = data.streamServers.firstWhere(
              (q) => q.quality.contains('720p'),
              orElse: () => data.streamServers.last,
            );

            // Pilih server pertama dari kualitas tersebut
            if (_selectedQuality!.servers.isNotEmpty) {
              _selectedServer = _selectedQuality!.servers.first;

              // Load Video dari server yang terpilih
              _loadServerUrl(_selectedServer!);
            }
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal memuat episode: $e")));
      }
    }
  }

  /// Memuat URL video ke dalam WebView
  /// Menangani logika: Direct URL (Donghua) vs Fetch ID (Anime)
  Future<void> _loadServerUrl(Server server) async {
    setState(() => _isVideoLoading = true);

    try {
      String embedUrl;

      // KONDISI 1: Jika server punya URL langsung (biasanya Donghua)
      if (server.url != null && server.url!.isNotEmpty) {
        embedUrl = server.url!;
      }
      // KONDISI 2: Jika tidak, fetch embed URL dari API menggunakan ID (biasanya Anime)
      else {
        embedUrl = await _apiService.fetchServerEmbedUrl(server.id);
      }

      if (mounted) {
        setState(() {
          _currentEmbedUrl = embedUrl;
        });
        // Load URL ke WebView
        _webController.loadRequest(Uri.parse(embedUrl));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memuat video dari server ini")),
        );
        setState(() => _isVideoLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.redAccent),
              )
            : Column(
                children: [
                  // ==========================================================
                  // 1. AREA PLAYER (WebView 16:9)
                  // ==========================================================
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      children: [
                        if (_currentEmbedUrl != null)
                          WebViewWidget(controller: _webController),

                        // Loading Indicator (Spinner) di atas Player
                        if (_isVideoLoading)
                          Container(
                            color: Colors.black87,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.redAccent,
                              ),
                            ),
                          ),

                        // Tombol Back Custom (Floating)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ==========================================================
                  // 2. KONTROL & INFO AREA
                  // ==========================================================
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Judul Episode
                          Text(
                            _episodeDetail?.episodeTitle ?? "Unknown Episode",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Tombol Navigasi Next/Prev
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Tombol PREV
                              ElevatedButton.icon(
                                onPressed:
                                    _episodeDetail?.prevEpisodeSlug != null
                                    ? () => _loadEpisodeData(
                                        _episodeDetail!.prevEpisodeSlug!,
                                      )
                                    : null, // Disable jika null
                                icon: const Icon(Icons.skip_previous),
                                label: const Text("Prev"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[800],
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey[900],
                                  disabledForegroundColor: Colors.grey[700],
                                ),
                              ),
                              // Tombol NEXT
                              ElevatedButton.icon(
                                onPressed:
                                    _episodeDetail?.nextEpisodeSlug != null
                                    ? () => _loadEpisodeData(
                                        _episodeDetail!.nextEpisodeSlug!,
                                      )
                                    : null,
                                icon: const Icon(Icons.skip_next),
                                label: const Text("Next"),
                                iconAlignment: IconAlignment.end,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.redAccent
                                      .withOpacity(0.3),
                                  disabledForegroundColor: Colors.white30,
                                ),
                              ),
                            ],
                          ),

                          const Divider(color: Colors.white24, height: 32),

                          // === PILIHAN KUALITAS & SERVER ===
                          const Text(
                            "Pilih Server:",
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),

                          if (_episodeDetail != null) ...[
                            // 1. Pilihan Kualitas (Chips: 360p, 480p, Streaming)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _episodeDetail!.streamServers.map((
                                  quality,
                                ) {
                                  final isSelected =
                                      quality == _selectedQuality;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      label: Text(
                                        quality.quality.isEmpty
                                            ? "Default"
                                            : quality.quality,
                                      ),
                                      selected: isSelected,
                                      selectedColor: Colors.redAccent,
                                      backgroundColor: Colors.grey[800],
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey[400],
                                      ),
                                      onSelected: (bool selected) {
                                        if (selected) {
                                          setState(() {
                                            _selectedQuality = quality;
                                            // Reset ke server pertama di kualitas ini
                                            if (quality.servers.isNotEmpty) {
                                              _selectedServer =
                                                  quality.servers.first;
                                              _loadServerUrl(_selectedServer!);
                                            }
                                          });
                                        }
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // 2. Pilihan Server (List: Vidhide, Filedon, Premium, dll)
                            if (_selectedQuality != null)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _selectedQuality!.servers.map((
                                  server,
                                ) {
                                  final isActive = server == _selectedServer;
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedServer = server;
                                      });
                                      _loadServerUrl(server);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? Colors.redAccent.withOpacity(0.2)
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isActive
                                              ? Colors.redAccent
                                              : Colors.grey[700]!,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        server.name.toUpperCase(),
                                        style: TextStyle(
                                          color: isActive
                                              ? Colors.redAccent
                                              : Colors.white70,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
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
