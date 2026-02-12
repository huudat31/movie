import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_app/constrains/env/env.dart';
import 'package:movie_app/constrains/string/endpoint_tmdb.dart';

/// TMDB Authentication Service
/// Handles request tokens, sessions, and account management
class TMDBAuthService {
  static String get baseUrl => Env.baseUrl;
  static String get apiAccessToken => Env.apiAccessToken;

  final http.Client _client;

  TMDBAuthService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $apiAccessToken',
    'accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // ============ SESSION STORAGE ============

  static const String _sessionIdKey = 'tmdb_session_id';
  static const String _accountIdKey = 'tmdb_account_id';
  static const String _isGuestKey = 'tmdb_is_guest';

  Future<void> saveSession({
    required String sessionId,
    required int accountId,
    bool isGuest = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionIdKey, sessionId);
    await prefs.setInt(_accountIdKey, accountId);
    await prefs.setBool(_isGuestKey, isGuest);
    debugPrint('✅ TMDB Session saved: $sessionId');
  }

  Future<String?> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionIdKey);
  }

  Future<int?> getAccountId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_accountIdKey);
  }

  Future<bool> isGuestSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isGuestKey) ?? false;
  }

  Future<bool> hasSession() async {
    final sessionId = await getSessionId();
    return sessionId != null && sessionId.isNotEmpty;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionIdKey);
    await prefs.remove(_accountIdKey);
    await prefs.remove(_isGuestKey);
    debugPrint('✅ TMDB Session cleared');
  }

  // ============ AUTHENTICATION ============

  /// Step 1: Create a request token
  /// User must approve this token at TMDB website
  Future<String> createRequestToken() async {
    try {
      final response = await _client.get(
        Uri.parse(EndpointTmdb.createRequestToken),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['request_token'];
        }
        throw Exception(data['status_message'] ?? 'Failed to create token');
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error creating request token: $e');
      rethrow;
    }
  }

  /// Get the URL for user to approve the request token
  String getAuthorizationUrl(String requestToken, {String? redirectTo}) {
    final baseAuthUrl = 'https://www.themoviedb.org/authenticate/$requestToken';
    if (redirectTo != null) {
      return '$baseAuthUrl?redirect_to=${Uri.encodeComponent(redirectTo)}';
    }
    return baseAuthUrl;
  }

  /// Step 2: Create a session after user approves the token
  Future<String> createSession(String requestToken) async {
    try {
      final response = await _client.post(
        Uri.parse(EndpointTmdb.createSession),
        headers: _headers,
        body: json.encode({'request_token': requestToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final sessionId = data['session_id'];

          // Get account details and save session
          final account = await getAccountDetails(sessionId);
          await saveSession(
            sessionId: sessionId,
            accountId: account['id'],
            isGuest: false,
          );

          return sessionId;
        }
        throw Exception(data['status_message'] ?? 'Failed to create session');
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error creating session: $e');
      rethrow;
    }
  }

  /// Create a guest session (no user approval needed)
  /// Guest sessions expire after a period of inactivity
  Future<String> createGuestSession() async {
    try {
      final response = await _client.get(
        Uri.parse(EndpointTmdb.createGuestSession),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final guestSessionId = data['guest_session_id'];

          // Save as guest session (accountId = 0 for guest)
          await saveSession(
            sessionId: guestSessionId,
            accountId: 0,
            isGuest: true,
          );

          return guestSessionId;
        }
        throw Exception(
          data['status_message'] ?? 'Failed to create guest session',
        );
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error creating guest session: $e');
      rethrow;
    }
  }

  /// Delete session (logout)
  Future<bool> deleteSession() async {
    try {
      final sessionId = await getSessionId();
      if (sessionId == null) return true;

      final response = await _client.delete(
        Uri.parse(EndpointTmdb.deleteSession),
        headers: _headers,
        body: json.encode({'session_id': sessionId}),
      );

      await clearSession();

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error deleting session: $e');
      await clearSession(); // Clear local even if API fails
      return false;
    }
  }

  // ============ ACCOUNT ============

  /// Get account details
  Future<Map<String, dynamic>> getAccountDetails(String sessionId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/account?session_id=$sessionId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error getting account details: $e');
      rethrow;
    }
  }

  /// Get current authenticated account
  Future<TMDBAccount?> getCurrentAccount() async {
    try {
      final sessionId = await getSessionId();
      if (sessionId == null) return null;

      final isGuest = await isGuestSession();
      if (isGuest) {
        return TMDBAccount.guest();
      }

      final data = await getAccountDetails(sessionId);
      return TMDBAccount.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error getting current account: $e');
      return null;
    }
  }

  void dispose() {
    _client.close();
  }
}

/// TMDB Account model
class TMDBAccount {
  final int id;
  final String? name;
  final String username;
  final String? avatarPath;
  final String? gravatarHash;
  final String iso6391;
  final String iso31661;
  final bool includeAdult;
  final bool isGuest;

  const TMDBAccount({
    required this.id,
    this.name,
    required this.username,
    this.avatarPath,
    this.gravatarHash,
    this.iso6391 = 'vi',
    this.iso31661 = 'VN',
    this.includeAdult = false,
    this.isGuest = false,
  });

  factory TMDBAccount.fromJson(Map<String, dynamic> json) {
    final avatar = json['avatar'] as Map<String, dynamic>?;
    final gravatar = avatar?['gravatar'] as Map<String, dynamic>?;
    final tmdb = avatar?['tmdb'] as Map<String, dynamic>?;

    return TMDBAccount(
      id: json['id'] ?? 0,
      name: json['name'],
      username: json['username'] ?? 'User',
      avatarPath: tmdb?['avatar_path'],
      gravatarHash: gravatar?['hash'],
      iso6391: json['iso_639_1'] ?? 'vi',
      iso31661: json['iso_3166_1'] ?? 'VN',
      includeAdult: json['include_adult'] ?? false,
      isGuest: false,
    );
  }

  factory TMDBAccount.guest() {
    return const TMDBAccount(id: 0, username: 'Guest', isGuest: true);
  }

  String? getAvatarUrl(String imageBaseUrl) {
    if (avatarPath != null && avatarPath!.isNotEmpty) {
      return '$imageBaseUrl/w185$avatarPath';
    }
    if (gravatarHash != null && gravatarHash!.isNotEmpty) {
      return 'https://www.gravatar.com/avatar/$gravatarHash?s=185';
    }
    return null;
  }
}
