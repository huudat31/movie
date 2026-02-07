import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app/constrains/env/env.dart';
import 'package:movie_app/constrains/string/endpoint_tmdb.dart';
import 'package:movie_app/modules/movie/model/tmdb_movie.dart';
import 'package:movie_app/modules/movie/model/tmdb_movie_detail.dart';
import 'package:movie_app/modules/movie/model/tmdb_person.dart';
import 'package:movie_app/modules/movie/model/tmdb_video.dart';
import 'package:movie_app/modules/movie/model/tmdb_genre.dart';

class TMDBService {
  static String get apiKey => Env.apiKey;
  static String get apiAccessToken => Env.apiAccessToken;
  static String get baseUrl => Env.baseUrl;
  static String get imageBaseUrl => Env.imageBaseUrl;

  // Image sizes
  static const String posterSize = 'w500';
  static const String backdropSize = 'w1280';
  static const String profileSize = 'w185';
  static const String logoSize = 'w92';

  final http.Client _client;

  TMDBService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $apiAccessToken',
    'accept': 'application/json',
  };

  // ============ HELPER METHODS ============

  Future<Map<String, dynamic>> _get(String url) async {
    try {
      final response = await _client.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ API Error: $e');
      rethrow;
    }
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

  // ============ TRENDING ============

  /// Get trending content
  /// [mediaType]: all, movie, tv, person
  /// [timeWindow]: day, week
  Future<List<TMDBMovie>> getTrending({
    String mediaType = 'all',
    String timeWindow = 'week',
    int page = 1,
  }) async {
    try {
      EndpointTmdb.page = page;
      final data = await _get(EndpointTmdb.getTrending(mediaType, timeWindow));
      final List results = data['results'] ?? [];

      return results
          .where(
            (item) =>
                item['media_type'] == 'movie' || item['media_type'] == 'tv',
          )
          .map(
            (json) =>
                TMDBMovie.fromJson(json, isTVShow: json['media_type'] == 'tv'),
          )
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching trending: $e');
      rethrow;
    }
  }

  Future<List<TMDBMovie>> getTrendingMovies({int page = 1}) async {
    EndpointTmdb.page = page;
    final data = await _get(EndpointTmdb.getTrendingMovies);
    return _parseMovieList(data);
  }

  Future<List<TMDBMovie>> getTrendingTV({int page = 1}) async {
    EndpointTmdb.page = page;
    final data = await _get(EndpointTmdb.getTrendingTV);
    return _parseMovieList(data, isTVShow: true);
  }

  // ============ MOVIES ============

  Future<List<TMDBMovie>> getPopularMovies({int page = 1}) async {
    try {
      EndpointTmdb.page = page;
      final data = await _get(EndpointTmdb.getPopularMovies);
      return _parseMovieList(data);
    } catch (e) {
      debugPrint('❌ Error fetching popular movies: $e');
      rethrow;
    }
  }

  Future<List<TMDBMovie>> getTopRatedMovies({int page = 1}) async {
    try {
      EndpointTmdb.page = page;
      final data = await _get(EndpointTmdb.getTopRatedMovies);
      return _parseMovieList(data);
    } catch (e) {
      debugPrint('❌ Error fetching top rated movies: $e');
      rethrow;
    }
  }

  Future<List<TMDBMovie>> getNowPlayingMovies({int page = 1}) async {
    try {
      EndpointTmdb.page = page;
      final data = await _get(EndpointTmdb.getNowPlayingMovies);
      return _parseMovieList(data);
    } catch (e) {
      debugPrint('❌ Error fetching now playing movies: $e');
      rethrow;
    }
  }

  Future<List<TMDBMovie>> getUpcomingMovies({int page = 1}) async {
    try {
      EndpointTmdb.page = page;
      final data = await _get(EndpointTmdb.getUpcomingMovies);
      return _parseMovieList(data);
    } catch (e) {
      debugPrint('❌ Error fetching upcoming movies: $e');
      rethrow;
    }
  }

  Future<List<TMDBMovie>> getPopularTVShows({int page = 1}) async {
    try {
      EndpointTmdb.page = page;
      final data = await _get(EndpointTmdb.getPopularTVShows);
      return _parseMovieList(data, isTVShow: true);
    } catch (e) {
      debugPrint('❌ Error fetching popular TV shows: $e');
      rethrow;
    }
  }

  Future<List<TMDBMovie>> getTopRatedTV({int page = 1}) async {
    try {
      EndpointTmdb.page = page;
      final data = await _get(EndpointTmdb.getTopRatedTV);
      return _parseMovieList(data, isTVShow: true);
    } catch (e) {
      debugPrint('❌ Error fetching top rated TV: $e');
      rethrow;
    }
  }

  Future<List<TMDBMovie>> getAiringTodayTV({int page = 1}) async {
    try {
      EndpointTmdb.page = page;
      final data = await _get(EndpointTmdb.getAiringTodayTV);
      return _parseMovieList(data, isTVShow: true);
    } catch (e) {
      debugPrint('❌ Error fetching airing today TV: $e');
      rethrow;
    }
  }

  Future<List<TMDBMovie>> getOnTheAirTV({int page = 1}) async {
    try {
      EndpointTmdb.page = page;
      final data = await _get(EndpointTmdb.getOnTheAirTV);
      return _parseMovieList(data, isTVShow: true);
    } catch (e) {
      debugPrint('❌ Error fetching on the air TV: $e');
      rethrow;
    }
  }

  // ============ DISCOVER ============

  Future<List<TMDBMovie>> discoverMovies({
    List<int>? withGenres,
    List<int>? withoutGenres,
    int? year,
    String? releaseDateGte,
    String? releaseDateLte,
    double? voteAverageGte,
    int? voteCountGte,
    String sortBy = 'popularity.desc',
    List<int>? withWatchProviders,
    String? watchRegion,
    String? withWatchMonetizationTypes,
    int page = 1,
  }) async {
    try {
      final url = EndpointTmdb.discoverMovies(
        withGenres: withGenres,
        withoutGenres: withoutGenres,
        year: year,
        releaseDateGte: releaseDateGte,
        releaseDateLte: releaseDateLte,
        voteAverageGte: voteAverageGte,
        voteCountGte: voteCountGte,
        sortBy: sortBy,
        withWatchProviders: withWatchProviders,
        watchRegion: watchRegion,
        withWatchMonetizationTypes: withWatchMonetizationTypes,
        page: page,
      );
      final data = await _get(url);
      return _parseMovieList(data);
    } catch (e) {
      debugPrint('❌ Error discovering movies: $e');
      rethrow;
    }
  }

  Future<List<TMDBMovie>> discoverTV({
    List<int>? withGenres,
    int? firstAirYear,
    String? firstAirDateGte,
    String? firstAirDateLte,
    double? voteAverageGte,
    int? voteCountGte,
    String sortBy = 'popularity.desc',
    int page = 1,
  }) async {
    try {
      final url = EndpointTmdb.discoverTV(
        withGenres: withGenres,
        firstAirYear: firstAirYear,
        firstAirDateGte: firstAirDateGte,
        firstAirDateLte: firstAirDateLte,
        voteAverageGte: voteAverageGte,
        voteCountGte: voteCountGte,
        sortBy: sortBy,
        page: page,
      );
      final data = await _get(url);
      return _parseMovieList(data, isTVShow: true);
    } catch (e) {
      debugPrint('❌ Error discovering TV: $e');
      rethrow;
    }
  }

  // ============ SEARCH ============

  Future<List<TMDBMovie>> searchMulti(String query, {int page = 1}) async {
    try {
      if (query.isEmpty) return [];
      final data = await _get(EndpointTmdb.searchMulti(query, page: page));
      final List results = data['results'] ?? [];
      return results
          .where(
            (item) =>
                item['media_type'] == 'movie' || item['media_type'] == 'tv',
          )
          .map(
            (json) =>
                TMDBMovie.fromJson(json, isTVShow: json['media_type'] == 'tv'),
          )
          .toList();
    } catch (e) {
      debugPrint('❌ Error searching: $e');
      rethrow;
    }
  }

  Future<List<TMDBMovie>> searchMovies(String query, {int page = 1}) async {
    try {
      if (query.isEmpty) return [];
      final data = await _get(EndpointTmdb.searchMovies(query, page: page));
      return _parseMovieList(data);
    } catch (e) {
      debugPrint('❌ Error searching movies: $e');
      rethrow;
    }
  }

  Future<List<TMDBMovie>> searchTV(String query, {int page = 1}) async {
    try {
      if (query.isEmpty) return [];
      final data = await _get(EndpointTmdb.searchTV(query, page: page));
      return _parseMovieList(data, isTVShow: true);
    } catch (e) {
      debugPrint('❌ Error searching TV: $e');
      rethrow;
    }
  }

  Future<List<TMDBPerson>> searchPerson(String query, {int page = 1}) async {
    try {
      if (query.isEmpty) return [];
      final data = await _get(EndpointTmdb.searchPerson(query, page: page));
      final List results = data['results'] ?? [];
      return results.map((json) => TMDBPerson.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Error searching person: $e');
      rethrow;
    }
  }

  // ============ DETAILS ============

  /// Get full movie details with append_to_response
  Future<TMDBMovieDetail> getMovieDetails(int movieId) async {
    try {
      final data = await _get(EndpointTmdb.getMovieDetails(movieId));
      return TMDBMovieDetail.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error fetching movie details: $e');
      rethrow;
    }
  }

  /// Get full TV details with append_to_response
  Future<TMDBMovieDetail> getTVDetails(int tvId) async {
    try {
      final data = await _get(EndpointTmdb.getTVDetails(tvId));
      return TMDBMovieDetail.fromJson(data, isTVShow: true);
    } catch (e) {
      debugPrint('❌ Error fetching TV details: $e');
      rethrow;
    }
  }

  /// Get basic movie info (for backward compatibility)
  Future<TMDBMovie> getMoviesDetails(int movieId) async {
    try {
      final detail = await getMovieDetails(movieId);
      return detail.toTMDBMovie();
    } catch (e) {
      debugPrint('❌ Error fetching movie: $e');
      rethrow;
    }
  }

  /// Get basic TV show info (for backward compatibility)
  Future<TMDBMovie> getTVShowDetails(int tvShowId) async {
    try {
      final detail = await getTVDetails(tvShowId);
      return detail.toTMDBMovie();
    } catch (e) {
      debugPrint('❌ Error fetching TV show details: $e');
      rethrow;
    }
  }

  // ============ VIDEOS ============

  Future<List<TMDBVideo>> getMoviesVideos(int movieId) async {
    try {
      final data = await _get(EndpointTmdb.getMovieVideos(movieId));
      final List results = data['results'] ?? [];
      return results.map((json) => TMDBVideo.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Error fetching movie videos: $e');
      rethrow;
    }
  }

  Future<List<TMDBVideo>> getTVShowVideos(int tvId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/tv/$tvId/videos?language=vi-VN'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'] ?? [];
        return results.map((json) => TMDBVideo.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load videos');
      }
    } catch (e) {
      debugPrint('❌ Error fetching TV show videos: $e');
      return [];
    }
  }

  // ============ SIMILAR & RECOMMENDATIONS ============

  Future<List<TMDBMovie>> getSimilarMovies(int movieId, {int page = 1}) async {
    try {
      EndpointTmdb.page = page;
      final data = await _get(EndpointTmdb.getSimilarMovies(movieId));
      return _parseMovieList(data);
    } catch (e) {
      debugPrint('❌ Error fetching similar movies: $e');
      rethrow;
    }
  }

  Future<List<TMDBMovie>> getMovieRecommendations(
    int movieId, {
    int page = 1,
  }) async {
    try {
      EndpointTmdb.page = page;
      final data = await _get(EndpointTmdb.getMovieRecommendations(movieId));
      return _parseMovieList(data);
    } catch (e) {
      debugPrint('❌ Error fetching movie recommendations: $e');
      rethrow;
    }
  }

  // ============ PERSON ============

  Future<TMDBPerson> getPersonDetails(int personId) async {
    try {
      final data = await _get(EndpointTmdb.getPersonDetails(personId));
      return TMDBPerson.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error fetching person details: $e');
      rethrow;
    }
  }

  // ============ GENRES ============

  Future<List<TMDBGenre>> getMovieGenres() async {
    try {
      final data = await _get(EndpointTmdb.getMovieGenres);
      final List genres = data['genres'] ?? [];
      return genres.map((json) => TMDBGenre.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Error fetching movie genres: $e');
      rethrow;
    }
  }

  Future<List<TMDBGenre>> getTVGenres() async {
    try {
      final data = await _get(EndpointTmdb.getTVGenres);
      final List genres = data['genres'] ?? [];
      return genres.map((json) => TMDBGenre.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Error fetching TV genres: $e');
      rethrow;
    }
  }

  // ============ FIND BY EXTERNAL ID ============

  Future<List<TMDBMovie>> findByIMDBId(String imdbId) async {
    try {
      final data = await _get(EndpointTmdb.findByExternalId(imdbId));
      final List movieResults = data['movie_results'] ?? [];
      final List tvResults = data['tv_results'] ?? [];

      final movies = movieResults
          .map((json) => TMDBMovie.fromJson(json))
          .toList();
      final tvShows = tvResults
          .map((json) => TMDBMovie.fromJson(json, isTVShow: true))
          .toList();

      return [...movies, ...tvShows];
    } catch (e) {
      debugPrint('❌ Error finding by IMDB ID: $e');
      rethrow;
    }
  }

  // ============ IMAGE HELPERS ============

  static String getImageUrl(String? path, {String size = posterSize}) {
    if (path == null || path.isEmpty) return '';
    return '$imageBaseUrl/$size$path';
  }

  static String getPosterUrl(String? path) {
    return getImageUrl(path, size: posterSize);
  }

  static String getBackdropUrl(String? path) {
    return getImageUrl(path, size: backdropSize);
  }

  static String getProfileUrl(String? path) {
    return getImageUrl(path, size: profileSize);
  }

  static String getLogoUrl(String? path) {
    return getImageUrl(path, size: logoSize);
  }

  static String getYouTubeUrl(String key) {
    return 'https://www.youtube.com/watch?v=$key';
  }

  static String getYouTubeThumbnail(String key) {
    return 'https://img.youtube.com/vi/$key/hqdefault.jpg';
  }

  // ============ LEGACY METHODS (for backward compatibility) ============

  Future<List<TMDBMovie>> searchMoviesAndTVShows(
    String query, {
    int page = 1,
  }) async {
    return searchMulti(query, page: page);
  }

  void dispose() {
    _client.close();
  }
}
