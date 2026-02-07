import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app/constrains/env/env.dart';
import 'package:movie_app/constrains/string/endpoint_tmdb.dart';
import 'package:movie_app/modules/movie/model/tmdb_movie.dart';
import 'package:movie_app/services/tmdb/tmdb_auth_service.dart';

/// TMDB User Service
/// Handles user-specific features: Rating, Favorite, Watchlist, Account States
class TMDBUserService {
  static String get baseUrl => Env.baseUrl;
  static String get apiAccessToken => Env.apiAccessToken;

  final http.Client _client;
  final TMDBAuthService _authService;

  TMDBUserService({http.Client? client, TMDBAuthService? authService})
    : _client = client ?? http.Client(),
      _authService = authService ?? TMDBAuthService();

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $apiAccessToken',
    'accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // ============ HELPER ============

  Future<String> _getSessionId() async {
    final sessionId = await _authService.getSessionId();
    if (sessionId == null || sessionId.isEmpty) {
      throw Exception('Not authenticated. Please login first.');
    }
    return sessionId;
  }

  Future<int> _getAccountId() async {
    final accountId = await _authService.getAccountId();
    if (accountId == null) {
      throw Exception('Account ID not found. Please login first.');
    }
    return accountId;
  }

  List<TMDBMovie> _parseMovieList(
    Map<String, dynamic> data, {
    bool isTVShow = false,
  }) {
    final List results = data['results'] ?? [];
    return results
        .map((json) => TMDBMovie.fromJson(json, isTVShow: isTVShow))
        .toList();
  }

  // ============ ACCOUNT STATES ============

  /// Get the account state for a movie (rated, favorite, watchlist)
  Future<TMDBAccountStates> getMovieAccountStates(int movieId) async {
    try {
      final sessionId = await _getSessionId();
      final response = await _client.get(
        Uri.parse(EndpointTmdb.getMovieAccountStates(movieId, sessionId)),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return TMDBAccountStates.fromJson(json.decode(response.body));
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error getting movie account states: $e');
      rethrow;
    }
  }

  /// Get the account state for a TV show
  Future<TMDBAccountStates> getTVAccountStates(int tvId) async {
    try {
      final sessionId = await _getSessionId();
      final response = await _client.get(
        Uri.parse(EndpointTmdb.getTVAccountStates(tvId, sessionId)),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return TMDBAccountStates.fromJson(json.decode(response.body));
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error getting TV account states: $e');
      rethrow;
    }
  }

  // ============ RATING ============

  /// Rate a movie (value: 0.5 - 10.0, in 0.5 increments)
  Future<bool> rateMovie(int movieId, double rating) async {
    try {
      final sessionId = await _getSessionId();
      final clampedRating = (rating * 2).round() / 2; // Round to nearest 0.5
      final validRating = clampedRating.clamp(0.5, 10.0);

      final response = await _client.post(
        Uri.parse(EndpointTmdb.rateMovie(movieId, sessionId)),
        headers: _headers,
        body: json.encode({'value': validRating}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Movie $movieId rated: $validRating');
        return true;
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error rating movie: $e');
      rethrow;
    }
  }

  /// Delete a movie rating
  Future<bool> deleteMovieRating(int movieId) async {
    try {
      final sessionId = await _getSessionId();
      final response = await _client.delete(
        Uri.parse(EndpointTmdb.rateMovie(movieId, sessionId)),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Movie $movieId rating deleted');
        return true;
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error deleting movie rating: $e');
      rethrow;
    }
  }

  /// Rate a TV show
  Future<bool> rateTV(int tvId, double rating) async {
    try {
      final sessionId = await _getSessionId();
      final clampedRating = (rating * 2).round() / 2;
      final validRating = clampedRating.clamp(0.5, 10.0);

      final response = await _client.post(
        Uri.parse(EndpointTmdb.rateTV(tvId, sessionId)),
        headers: _headers,
        body: json.encode({'value': validRating}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ TV $tvId rated: $validRating');
        return true;
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error rating TV: $e');
      rethrow;
    }
  }

  /// Delete a TV rating
  Future<bool> deleteTVRating(int tvId) async {
    try {
      final sessionId = await _getSessionId();
      final response = await _client.delete(
        Uri.parse(EndpointTmdb.rateTV(tvId, sessionId)),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        debugPrint('✅ TV $tvId rating deleted');
        return true;
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error deleting TV rating: $e');
      rethrow;
    }
  }

  // ============ FAVORITES ============

  /// Add or remove a movie/TV from favorites
  Future<bool> markAsFavorite({
    required String mediaType, // 'movie' or 'tv'
    required int mediaId,
    required bool favorite,
  }) async {
    try {
      final sessionId = await _getSessionId();
      final accountId = await _getAccountId();

      final response = await _client.post(
        Uri.parse(EndpointTmdb.addFavorite(accountId, sessionId)),
        headers: _headers,
        body: json.encode({
          'media_type': mediaType,
          'media_id': mediaId,
          'favorite': favorite,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ $mediaType $mediaId favorite: $favorite');
        return true;
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error marking favorite: $e');
      rethrow;
    }
  }

  /// Get favorite movies
  Future<List<TMDBMovie>> getFavoriteMovies({int page = 1}) async {
    try {
      final sessionId = await _getSessionId();
      final accountId = await _getAccountId();
      EndpointTmdb.page = page;

      final response = await _client.get(
        Uri.parse(EndpointTmdb.getFavoriteMovies(accountId, sessionId)),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return _parseMovieList(json.decode(response.body));
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error getting favorite movies: $e');
      rethrow;
    }
  }

  /// Get favorite TV shows
  Future<List<TMDBMovie>> getFavoriteTV({int page = 1}) async {
    try {
      final sessionId = await _getSessionId();
      final accountId = await _getAccountId();
      EndpointTmdb.page = page;

      final response = await _client.get(
        Uri.parse(EndpointTmdb.getFavoriteTV(accountId, sessionId)),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return _parseMovieList(json.decode(response.body), isTVShow: true);
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error getting favorite TV: $e');
      rethrow;
    }
  }

  // ============ WATCHLIST ============

  /// Add or remove a movie/TV from watchlist
  Future<bool> addToWatchlist({
    required String mediaType, // 'movie' or 'tv'
    required int mediaId,
    required bool watchlist,
  }) async {
    try {
      final sessionId = await _getSessionId();
      final accountId = await _getAccountId();

      final response = await _client.post(
        Uri.parse(EndpointTmdb.addWatchlist(accountId, sessionId)),
        headers: _headers,
        body: json.encode({
          'media_type': mediaType,
          'media_id': mediaId,
          'watchlist': watchlist,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ $mediaType $mediaId watchlist: $watchlist');
        return true;
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error updating watchlist: $e');
      rethrow;
    }
  }

  /// Get watchlist movies
  Future<List<TMDBMovie>> getWatchlistMovies({int page = 1}) async {
    try {
      final sessionId = await _getSessionId();
      final accountId = await _getAccountId();
      EndpointTmdb.page = page;

      final response = await _client.get(
        Uri.parse(EndpointTmdb.getWatchlistMovies(accountId, sessionId)),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return _parseMovieList(json.decode(response.body));
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error getting watchlist movies: $e');
      rethrow;
    }
  }

  /// Get watchlist TV shows
  Future<List<TMDBMovie>> getWatchlistTV({int page = 1}) async {
    try {
      final sessionId = await _getSessionId();
      final accountId = await _getAccountId();
      EndpointTmdb.page = page;

      final response = await _client.get(
        Uri.parse(EndpointTmdb.getWatchlistTV(accountId, sessionId)),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return _parseMovieList(json.decode(response.body), isTVShow: true);
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error getting watchlist TV: $e');
      rethrow;
    }
  }

  // ============ RATED ============

  /// Get rated movies
  Future<List<TMDBRatedMovie>> getRatedMovies({int page = 1}) async {
    try {
      final sessionId = await _getSessionId();
      final accountId = await _getAccountId();
      EndpointTmdb.page = page;

      final response = await _client.get(
        Uri.parse(EndpointTmdb.getRatedMovies(accountId, sessionId)),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'] ?? [];
        return results.map((json) => TMDBRatedMovie.fromJson(json)).toList();
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error getting rated movies: $e');
      rethrow;
    }
  }

  /// Get rated TV shows
  Future<List<TMDBRatedMovie>> getRatedTV({int page = 1}) async {
    try {
      final sessionId = await _getSessionId();
      final accountId = await _getAccountId();
      EndpointTmdb.page = page;

      final response = await _client.get(
        Uri.parse(EndpointTmdb.getRatedTV(accountId, sessionId)),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'] ?? [];
        return results
            .map((json) => TMDBRatedMovie.fromJson(json, isTVShow: true))
            .toList();
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error getting rated TV: $e');
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}

/// Account states for a movie/TV show
class TMDBAccountStates {
  final int id;
  final bool favorite;
  final bool watchlist;
  final double? rating; // null if not rated

  const TMDBAccountStates({
    required this.id,
    required this.favorite,
    required this.watchlist,
    this.rating,
  });

  factory TMDBAccountStates.fromJson(Map<String, dynamic> json) {
    // Rating can be false (not rated) or an object with 'value'
    double? rating;
    final ratedValue = json['rated'];
    if (ratedValue is Map<String, dynamic>) {
      rating = (ratedValue['value'] ?? 0).toDouble();
    }

    return TMDBAccountStates(
      id: json['id'] ?? 0,
      favorite: json['favorite'] ?? false,
      watchlist: json['watchlist'] ?? false,
      rating: rating,
    );
  }

  bool get isRated => rating != null;
}

/// Movie with user's rating
class TMDBRatedMovie extends TMDBMovie {
  final double userRating;

  TMDBRatedMovie({
    required super.id,
    required super.title,
    required super.originalTitle,
    required super.overview,
    super.posterPath,
    super.backdropPath,
    required super.voteAverage,
    required super.voteCount,
    super.releaseDate,
    required super.genreIds,
    super.adult,
    super.originalLanguage,
    super.popularity,
    required super.isTVShow,
    required super.mediaType,
    required this.userRating,
  });

  factory TMDBRatedMovie.fromJson(
    Map<String, dynamic> json, {
    bool isTVShow = false,
  }) {
    return TMDBRatedMovie(
      id: json['id'] ?? 0,
      title: isTVShow
          ? (json['name'] ?? json['original_name'] ?? 'Unknown')
          : (json['title'] ?? json['original_title'] ?? 'Unknown'),
      originalTitle: isTVShow
          ? (json['original_name'] ?? 'Unknown')
          : (json['original_title'] ?? 'Unknown'),
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      releaseDate: isTVShow ? json['first_air_date'] : json['release_date'],
      genreIds: json['genre_ids'] != null
          ? List<int>.from(json['genre_ids'])
          : [],
      adult: json['adult'] ?? false,
      originalLanguage: json['original_language'] ?? 'en',
      popularity: (json['popularity'] ?? 0).toDouble(),
      isTVShow: isTVShow,
      mediaType: json['media_type'] ?? (isTVShow ? 'tv' : 'movie'),
      userRating: (json['rating'] ?? 0).toDouble(),
    );
  }

  String get formattedUserRating => userRating.toStringAsFixed(1);
}
