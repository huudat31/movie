import 'package:equatable/equatable.dart';

/// Represents a user review for a movie/TV show
class TMDBReview extends Equatable {
  final String id;
  final String author;
  final String content;
  final String? authorUsername;
  final String? avatarPath;
  final double? rating;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? url;

  const TMDBReview({
    required this.id,
    required this.author,
    required this.content,
    this.authorUsername,
    this.avatarPath,
    this.rating,
    this.createdAt,
    this.updatedAt,
    this.url,
  });

  factory TMDBReview.fromJson(Map<String, dynamic> json) {
    // Parse author details
    final authorDetails = json['author_details'] as Map<String, dynamic>?;

    return TMDBReview(
      id: json['id'] ?? '',
      author: json['author'] ?? 'Anonymous',
      content: json['content'] ?? '',
      authorUsername: authorDetails?['username'],
      avatarPath: authorDetails?['avatar_path'],
      rating: authorDetails?['rating']?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'content': content,
      'author_details': {
        'username': authorUsername,
        'avatar_path': avatarPath,
        'rating': rating,
      },
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'url': url,
    };
  }

  /// Get avatar URL (handles both TMDB and Gravatar paths)
  String? getAvatarUrl(String imageBaseUrl) {
    if (avatarPath == null || avatarPath!.isEmpty) return null;

    // Gravatar URLs start with /https://
    if (avatarPath!.startsWith('/https://')) {
      return avatarPath!.substring(1); // Remove leading /
    }

    // TMDB avatar path
    return '$imageBaseUrl/w45$avatarPath';
  }

  /// Get a short preview of the content (first 200 chars)
  String get contentPreview {
    if (content.length <= 200) return content;
    return '${content.substring(0, 200)}...';
  }

  /// Format the rating as a string (e.g., "8.5/10")
  String? get formattedRating {
    if (rating == null) return null;
    return '${rating!.toStringAsFixed(1)}/10';
  }

  @override
  List<Object?> get props => [id, author, content, rating, createdAt];
}

/// Container for reviews with pagination info
class TMDBReviewsResponse extends Equatable {
  final int id;
  final int page;
  final List<TMDBReview> results;
  final int totalPages;
  final int totalResults;

  const TMDBReviewsResponse({
    required this.id,
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory TMDBReviewsResponse.fromJson(Map<String, dynamic> json) {
    return TMDBReviewsResponse(
      id: json['id'] ?? 0,
      page: json['page'] ?? 1,
      results:
          (json['results'] as List<dynamic>?)
              ?.map((e) => TMDBReview.fromJson(e))
              .toList() ??
          [],
      totalPages: json['total_pages'] ?? 0,
      totalResults: json['total_results'] ?? 0,
    );
  }

  bool get hasMore => page < totalPages;

  @override
  List<Object?> get props => [id, page, results, totalPages, totalResults];
}
