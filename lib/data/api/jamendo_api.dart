import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class JamendoApi {
  static const _baseUrl = 'https://api.jamendo.com/v3.0';
  final String clientId;
  final Dio _dio;

  JamendoApi(this.clientId, {Dio? dio}) : _dio = dio ?? Dio();

  Future<List<Map<String, dynamic>>> searchTracks(
    String query, {
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/tracks',
        queryParameters: {
          'client_id': clientId,
          'format': 'json',
          'limit': limit,
          'search': query,
        },
      );
      final data = response.data;
      if (data == null) return [];
      final results = data['results'] as List?;
      if (results == null) return [];
      return results.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('JamendoApi.searchTracks failed: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTrending({int limit = 20}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/tracks',
        queryParameters: {
          'client_id': clientId,
          'format': 'json',
          'limit': limit,
        },
      );
      final data = response.data;
      if (data == null) return [];
      final results = data['results'] as List?;
      if (results == null) return [];
      return results.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('JamendoApi.getTrending failed: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getByGenre(
    String genre, {
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/tracks',
        queryParameters: {
          'client_id': clientId,
          'format': 'json',
          'limit': limit,
          'tags': genre,
        },
      );
      final data = response.data;
      if (data == null) return [];
      final results = data['results'] as List?;
      if (results == null) return [];
      return results.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('JamendoApi.getByGenre failed: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getTrack(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/tracks',
        queryParameters: {
          'client_id': clientId,
          'format': 'json',
          'id': id,
        },
      );
      final results = response.data?['results'] as List?;
      if (results == null || results.isEmpty) return null;
      return results.first as Map<String, dynamic>;
    } catch (e) {
      debugPrint('JamendoApi.getTrack failed: $e');
      return null;
    }
  }
}
