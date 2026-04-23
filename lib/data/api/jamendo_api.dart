import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../preferences/credentials_store.dart';

class JamendoApi {
  static const _baseUrl = 'https://api.jamendo.com/v3.0';

  final Dio _dio;
  final CredentialsStore? _credentials;
  final String _fallbackClientId;

  JamendoApi({
    Dio? dio,
    CredentialsStore? credentials,
    String fallbackClientId = '',
  })  : _dio = dio ?? Dio(),
        _credentials = credentials,
        _fallbackClientId = fallbackClientId;

  Future<String> _clientId() async {
    await _credentials?.ensureLoaded();
    final c = _credentials?.snapshot.jamendoClientId ?? '';
    return c.isNotEmpty ? c : _fallbackClientId;
  }

  Future<List<Map<String, dynamic>>> _listTracks(
      Map<String, dynamic> extraQuery) async {
    final clientId = await _clientId();
    if (clientId.isEmpty) return [];
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/tracks',
        queryParameters: {
          'client_id': clientId,
          'format': 'json',
          ...extraQuery,
        },
      );
      final results = response.data?['results'] as List?;
      if (results == null) return [];
      return results.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('JamendoApi request failed: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchTracks(
    String query, {
    int limit = 20,
  }) =>
      _listTracks({'limit': limit, 'search': query});

  Future<List<Map<String, dynamic>>> getTrending({int limit = 20}) =>
      _listTracks({'limit': limit, 'order': 'popularity_total'});

  Future<List<Map<String, dynamic>>> getByGenre(
    String genre, {
    int limit = 20,
  }) =>
      _listTracks({'limit': limit, 'tags': genre});

  Future<Map<String, dynamic>?> getTrack(String id) async {
    final results = await _listTracks({'id': id});
    if (results.isEmpty) return null;
    return results.first;
  }
}
