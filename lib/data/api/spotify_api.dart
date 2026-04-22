import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class SpotifyApi {
  static const _baseUrl = 'https://api.spotify.com/v1';
  static const _tokenUrl = 'https://accounts.spotify.com/api/token';

  final String clientId;
  final String clientSecret;
  final Dio _dio;

  String? _token;
  DateTime? _expiresAt;

  SpotifyApi({
    required this.clientId,
    required this.clientSecret,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  bool get _hasCredentials => clientId.isNotEmpty && clientSecret.isNotEmpty;

  Future<String?> _getToken() async {
    if (!_hasCredentials) return null;
    if (_token != null &&
        _expiresAt != null &&
        DateTime.now()
            .isBefore(_expiresAt!.subtract(const Duration(minutes: 1)))) {
      return _token;
    }
    try {
      final credentials = base64.encode(utf8.encode('$clientId:$clientSecret'));
      final response = await _dio.post<Map<String, dynamic>>(
        _tokenUrl,
        data: 'grant_type=client_credentials',
        options: Options(
          headers: {
            'Authorization': 'Basic $credentials',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );
      final data = response.data;
      if (data == null) return null;
      final token = data['access_token'] as String?;
      final expiresIn = data['expires_in'] as int? ?? 3600;
      if (token == null) return null;
      _token = token;
      _expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
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
  }) async {
    final token = await _getToken();
    if (token == null) return [];
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/search',
        queryParameters: {
          'q': query,
          'type': 'track',
          'limit': limit,
        },
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
    return searchTracks('genre:$genre', limit: limit);
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

  Future<List<Map<String, dynamic>>> getTrending({int limit = 20}) async {
    final token = await _getToken();
    if (token == null) return [];
    try {
      final featured = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/browse/featured-playlists',
        queryParameters: {'limit': 1},
        options: _authOptions(token),
      );
      final items = featured.data?['playlists']?['items'] as List?;
      if (items == null || items.isEmpty) return [];
      final playlistId = (items.first as Map<String, dynamic>)['id'] as String?;
      if (playlistId == null) return [];
      final tracks = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/playlists/$playlistId/tracks',
        queryParameters: {'limit': limit},
        options: _authOptions(token),
      );
      final trackItems = tracks.data?['items'] as List?;
      if (trackItems == null) return [];
      return trackItems.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('SpotifyApi.getTrending failed: $e');
      return [];
    }
  }
}
