import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app/constrains/env/env.dart';
import 'package:movie_app/constrains/string/endpoint_tmdb.dart';
import 'package:movie_app/modules/movie/model/tmdb_movie.dart';
import 'package:movie_app/modules/movie/model/tmdb_video.dart';

class TMDBService {
  static String get apiKey => Env.apiKey;
  static String get apiAccessToken => Env.apiAccessToken;
  static String get baseUrl => Env.baseUrl;
  static String get imageBaseUrl => Env.imageBaseUrl;

  // Image sizes
  static const String posterSize = 'w500';
  static const String backdropSize = 'w1280';
  static const String profileSize = 'w185';

  late final http.Client _client;

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $apiAccessToken',
    'accept': 'application/json',
  };

  // get popular movies
  Future<List<TMDBMovie>> getPopularMovies({int page = 1}) async {
    try {
      final response = await _client.get(
        Uri.parse(EndpointTmdb.getPopularMovies),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List resufts = data['resufts'] ?? [];
        return resufts.map((json) => TMDBMovie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load popular movies');
      }
    } catch (e) {
      debugPrint(
        "Error fetching popular movies: ============================> /n $e",
      );
      rethrow;
    }
  }

  // get top_rated movies
  Future<List<TMDBMovie>> getTopRatedMovies({int page = 1}) async {
    try {
      final response = await _client.get(
        Uri.parse(EndpointTmdb.getTopRatedMovies),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List resufts = data['resufts'] ?? [];
        return resufts.map((json) => TMDBMovie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load top rated movies');
      }
    } catch (e) {
      debugPrint(
        "Error fetching top rated movies: ============================> /n $e",
      );
      rethrow;
    }
  }

  //   get playing now movies
  Future<List<TMDBMovie>> getNowPlayingMovies({int page = 1}) async {
    try {
      final response = await _client.get(
        Uri.parse(EndpointTmdb.getNowPlayingMovies),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List resufts = data['resufts'] ?? [];
        return resufts.map((json) => TMDBMovie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load now playing movies');
      }
    } catch (e) {
      debugPrint(
        "Error fetching now playing movies: ============================> /n $e",
      );
      rethrow;
    }
  }

  // get popular TV shows
  Future<List<TMDBMovie>> getPopularTVShows({int page = 1}) async {
    try {
      final response = await _client.get(
        Uri.parse(EndpointTmdb.getPopularTVShows),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'] ?? [];
        return results.map((json) => TMDBMovie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load popular TV shows');
      }
    } catch (e) {
      debugPrint(
        "Error fetching popular TV shows: ============================> /n $e",
      );
      rethrow;
    }
  }

  // search movies and TV shows
  Future<List<TMDBMovie>> searchMoviesAndTVShows(
    String query, {
    int page = 1,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/search/multi?query=${Uri.encodeComponent(query)}'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'] ?? [];
        return results
            .where(
              (item) =>
                  item['media_type'] == 'movie' || item['media_type'] == 'tv',
            )
            .map(
              (json) => TMDBMovie.fromJson(
                json,
                isTVShow: json['media_type'] == 'tv',
              ),
            )
            .toList();
      } else {
        throw Exception('Failed to search movies and TV shows');
      }
    } catch (e) {
      debugPrint(
        "Error searching movies and TV shows: ============================> /n $e",
      );
      rethrow;
    }
  }

  Future<TMDBMovie> getMoviesDetails(int moviesId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/movie/$moviesId?language=en-US'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TMDBMovie.fromJson(data);
      } else {
        throw Exception('Failed to load movie details');
      }
    } catch (e) {
      debugPrint(
        "Error fetching movie details: ============================> /n $e",
      );
      rethrow;
    }
  }

  Future<List<TMDBMovie>> searchMulti(String query, {int page = 1}) async {
    try {
      final response = await _client.get(
        Uri.parse(
          '$baseUrl/search/multi?query=${Uri.encodeComponent(query)}&language=en-US&page=$page',
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'] ?? [];
        return results
            .where(
              (item) =>
                  item['media_type'] == 'movie' || item['media_type'] == 'tv',
            )
            .map(
              (json) => TMDBMovie.fromJson(
                json,
                isTVShow: json['media_type'] == 'tv',
              ),
            )
            .toList();
      } else {
        throw Exception('Failed to search');
      }
    } catch (e) {
      debugPrint('❌ Error searching: $e');
      rethrow;
    }
  }

  // get TV show details
  Future<TMDBVideo> getTVShowDetails(int tvShowId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/tv/$tvShowId?language=en-US'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TMDBVideo.fromJson(data);
      } else {
        throw Exception('Failed to load TV show details');
      }
    } catch (e) {
      debugPrint(
        "Error fetching TV show details: ============================> /n $e",
      );
      rethrow;
    }
  }

  Future<List<TMDBVideo>> getMoviesVideos(int movieId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/movie/$movieId/videos?language=en-US'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'] ?? [];
        return results.map((json) => TMDBVideo.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load movie videos');
      }
    } catch (e) {
      debugPrint(
        "Error fetching movie videos: ============================> /n $e",
      );
      rethrow;
    }
  }

  Future<List<TMDBVideo>> getTVShowVideos(int tvId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/tv/$tvId/videos?language=en-US'),
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
      debugPrint(
        "Error fetching TV show videos: ============================> /n $e",
      );
      return [];
    }
  }

  static String getImageUrl(String? path, {String size = posterSize}) {
    if (path == null || path.isEmpty) return '';
    return '$imageBaseUrl/$size$path';
  }

  // Get Poster URL
  static String getPosterUrl(String? path) {
    return getImageUrl(path, size: posterSize);
  }

  // Get Backdrop URL
  static String getBackdropUrl(String? path) {
    return getImageUrl(path, size: backdropSize);
  }

  // Get YouTube URL
  static String getYouTubeUrl(String key) {
    return 'https://www.youtube.com/watch?v=$key';
  }

  // Get YouTube Thumbnail
  static String getYouTubeThumbnail(String key) {
    return 'https://img.youtube.com/vi/$key/hqdefault.jpg';
  }

  void dispose() {
    _client.close();
  }
}
