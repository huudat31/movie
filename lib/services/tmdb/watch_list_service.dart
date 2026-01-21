import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:movie_app/modules/movie/model/tmdb_movie.dart';

class WatchlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Collection reference for user's watchlist
  CollectionReference? get _watchlistCollection {
    if (_userId == null) return null;
    return _firestore.collection('users').doc(_userId).collection('watchlist');
  }

  // Add movie to watchlist
  Future<void> addToWatchlist(TMDBMovie movie) async {
    try {
      if (_watchlistCollection == null) {
        throw Exception('User not authenticated');
      }

      await _watchlistCollection!.doc(movie.id.toString()).set({
        'movieId': movie.id,
        'title': movie.title,
        'originalTitle': movie.originalTitle,
        'overview': movie.overview,
        'posterPath': movie.posterPath,
        'backdropPath': movie.backdropPath,
        'voteAverage': movie.voteAverage,
        'voteCount': movie.voteCount,
        'releaseDate': movie.releaseDate,
        'genreIds': movie.genreIds,
        'isTVShow': movie.isTVShow,
        'mediaType': movie.mediaType,
        'addedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Added to watchlist: ${movie.title}');
    } catch (e) {
      debugPrint('❌ Error adding to watchlist: $e');
      rethrow;
    }
  }

  // Remove movie from watchlist
  Future<void> removeFromWatchlist(int movieId) async {
    try {
      if (_watchlistCollection == null) {
        throw Exception('User not authenticated');
      }

      await _watchlistCollection!.doc(movieId.toString()).delete();
      debugPrint('✅ Removed from watchlist: $movieId');
    } catch (e) {
      debugPrint('❌ Error removing from watchlist: $e');
      rethrow;
    }
  }

  // Check if movie is in watchlist
  Future<bool> isInWatchlist(int movieId) async {
    try {
      if (_watchlistCollection == null) return false;

      final doc = await _watchlistCollection!.doc(movieId.toString()).get();
      return doc.exists;
    } catch (e) {
      debugPrint('❌ Error checking watchlist: $e');
      return false;
    }
  }

  // Get user's watchlist
  Stream<List<TMDBMovie>> getWatchlist() {
    if (_watchlistCollection == null) {
      return Stream.value([]);
    }

    return _watchlistCollection!
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return TMDBMovie(
              id: data['movieId'] ?? 0,
              title: data['title'] ?? 'Unknown',
              originalTitle: data['originalTitle'] ?? 'Unknown',
              overview: data['overview'] ?? '',
              posterPath: data['posterPath'],
              backdropPath: data['backdropPath'],
              voteAverage: (data['voteAverage'] ?? 0).toDouble(),
              voteCount: data['voteCount'] ?? 0,
              releaseDate: data['releaseDate'],
              genreIds: List<int>.from(data['genreIds'] ?? []),
              isTVShow: data['isTVShow'] ?? false,
              mediaType: data['mediaType'] ?? 'movie',
              adult: null,
              originalLanguage: '',
              popularity: null,
            );
          }).toList();
        });
  }

  // Get watchlist count
  Future<int> getWatchlistCount() async {
    try {
      if (_watchlistCollection == null) return 0;

      final snapshot = await _watchlistCollection!.get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('❌ Error getting watchlist count: $e');
      return 0;
    }
  }

  // Clear entire watchlist
  Future<void> clearWatchlist() async {
    try {
      if (_watchlistCollection == null) return;

      final snapshot = await _watchlistCollection!.get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      debugPrint('✅ Watchlist cleared');
    } catch (e) {
      debugPrint('❌ Error clearing watchlist: $e');
      rethrow;
    }
  }
}
