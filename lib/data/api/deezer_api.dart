import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DeezerApi {
  static const _baseUrl = 'https://api.deezer.com';
  final Dio _dio;

  DeezerApi({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<Map<String, dynamic>>> searchTracks(
    String query, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/search',
        queryParameters: {
          'q': query,
          'limit': limit,
          'index': offset,
        },
      );
      final data = response.data?['data'] as List?;
      if (data == null) return [];
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('DeezerApi.searchTracks failed: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTrending({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/chart/0/tracks',
        queryParameters: {
          'limit': limit,
          'index': offset,
        },
      );
      final data = response.data?['data'] as List?;
      if (data == null) return [];
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('DeezerApi.getTrending failed: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getTrack(String id) async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>('$_baseUrl/track/$id');
      return response.data;
    } catch (e) {
      debugPrint('DeezerApi.getTrack failed: $e');
      return null;
    }
  }
}
