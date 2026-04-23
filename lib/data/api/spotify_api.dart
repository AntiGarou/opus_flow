import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../preferences/credentials_store.dart';

/// Spotify Web API client backed by a [CredentialsStore].
///
/// Credentials are read lazily from the store so that configuring Spotify in
/// Settings takes effect without restarting the app. If no credentials are
/// configured, every call short-circuits and returns an empty result rather
/// than throwing, so the rest of the app keeps working.
class SpotifyApi {
  static const _baseUrl = 'https://api.spotify.com/v1';
  static const _tokenUrl = 'https://accounts.spotify.com/api/token';

  final CredentialsStore _credentials;
  final Dio _dio;

  String? _token;
  DateTime? _expiresAt;
  String? _cachedForClientId;

  SpotifyApi({
    required CredentialsStore credentials,
    Dio? dio,
  })  : _credentials = credentials,
        _dio = dio ?? Dio();

  bool get hasCredentials => _credentials.snapshot.hasSpotify;

  Future<String?> _getToken() async {
    await _credentials.ensureLoaded();
    final snap = _credentials.snapshot;
    if (!snap.hasSpotify) return null;

    if (_cachedForClientId != snap.spotifyClientId) {
      _token = null;
      _expiresAt = null;
      _cachedForClientId = snap.spotifyClientId;
    }

    final now = DateTime.now();
    if (_token != null &&
        _expiresAt != null &&
        now.isBefore(_expiresAt!.subtract(const Duration(minutes: 1)))) {
      return _token;
    }

    try {
      final basic = base64
          .encode(utf8.encode('${snap.spotifyClientId}:${snap.spotifyClientSecret}'));
      final response = await _dio.post<Map<String, dynamic>>(
        _tokenUrl,
        data: 'grant_type=client_credentials',
        options: Options(
          headers: {
            'Authorization': 'Basic $basic',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          validateStatus: (s) => s != null && s < 500,
        ),
      );
      final data = response.data;
      if (data == null || response.statusCode != 200) {
        debugPrint('SpotifyApi._getToken failed: ${response.statusCode} $data');
        return null;
      }
      final token = data['access_token'] as String?;
      final expiresIn = data['expires_in'] as int? ?? 3600;
      if (token == null) return null;
      _token = token;
      _expiresAt = now.add(Duration(seconds: expiresIn));
      return token;
    } catch (e) {
      debugPrint('SpotifyApi._getToken failed: $e');
      return null;
    }
  }

  Options _authOptions(String token) => Options(headers: {
        'Authorization': 'Bearer $token',
      });

  Future<List<Map<String, dynamic>>> searchTracks(
    String query, {
    int limit = 20,
    String? market,
  }) async {
    final token = await _getToken();
    if (token == null) return [];
    try {
      final query0 = <String, dynamic>{
        'q': query,
        'type': 'track',
        'limit': limit,
      };
      if (market != null) query0['market'] = market;
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/search',
        queryParameters: query0,
        options: _authOptions(token),
      );
      final items = response.data?['tracks']?['items'] as List?;
      if (items == null) return [];
      return items.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('SpotifyApi.searchTracks failed: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchByGenre(
    String genre, {
    int limit = 20,
  }) async {
    // Spotify removed the genre-seeds & recommendations endpoints in late 2024
    // for non-allowlisted apps. Fall back to a plain-text search by genre
    // name which is public.
    return searchTracks(genre, limit: limit);
  }

  Future<Map<String, dynamic>?> getTrack(String id) async {
    final token = await _getToken();
    if (token == null) return null;
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/tracks/$id',
        options: _authOptions(token),
      );
      return response.data;
    } catch (e) {
      debugPrint('SpotifyApi.getTrack failed: $e');
      return null;
    }
  }

  /// Current "trending" query. /browse/featured-playlists was deprecated by
  /// Spotify for new apps in Nov 2024; falling back to top-year search which
  /// is always available.
  Future<List<Map<String, dynamic>>> getTrending({int limit = 20}) async {
    final now = DateTime.now();
    final queries = <String>[
      'year:${now.year}',
      'year:${now.year - 1}',
      'top hits',
    ];
    for (final q in queries) {
      final items = await searchTracks(q, limit: limit);
      if (items.isNotEmpty) return items;
    }
    return [];
  }
}
