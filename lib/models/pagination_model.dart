import 'anime_model.dart';

// Model untuk data Paginasi umum
class PaginationInfo {
  final int currentPage;
  final bool hasNextPage;
  final int? nextPage;

  PaginationInfo({
    required this.currentPage,
    required this.hasNextPage,
    this.nextPage,
  });

 factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['current_page'] ?? 1,
      hasNextPage: json['has_next_page'] ?? false,
      nextPage: json['next_page'],
    );
  }
}

// Wrapper untuk Respons Ongoing List
class OngoingPaginationResult {
  final PaginationInfo pagination;
  final List<OngoingAnime> data;

  OngoingPaginationResult({required this.pagination, required this.data});

  factory OngoingPaginationResult.fromJson(Map<String, dynamic> json) {
    return OngoingPaginationResult(
      pagination: PaginationInfo.fromJson(json['data']['paginationData']),
      data: (json['data']['ongoingAnimeData'] as List)
          .map((e) => OngoingAnime.fromJson(e))
          .toList(),
    );
  }
}

// Wrapper untuk Respons Complete List
class CompletePaginationResult {
  final PaginationInfo pagination;
  final List<CompleteAnime> data;

  CompletePaginationResult({required this.pagination, required this.data});

  factory CompletePaginationResult.fromJson(Map<String, dynamic> json) {
    return CompletePaginationResult(
      pagination: PaginationInfo.fromJson(json['data']['paginationData']),
      data: (json['data']['completeAnimeData'] as List)
          .map((e) => CompleteAnime.fromJson(e))
          .toList(),
    );
  }
  
}
