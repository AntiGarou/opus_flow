import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'soundcloud_client_id_provider.dart';

class SoundCloudApi {
  static const _baseUrl = 'https://api-v2.soundcloud.com';
  final Dio _dio;
  final SoundCloudClientIdProvider _clientIdProvider;

  SoundCloudApi(this._clientIdProvider, {Dio? dio}) : _dio = dio ?? Dio();

  Future<List<Map<String, dynamic>>> searchTracks(
    String query, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final clientId = await _clientIdProvider.getClientId();
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/search/tracks',
        queryParameters: {
          'q': query,
          'limit': limit,
          'offset': offset,
          'client_id': clientId,
        },
      );
      final data = response.data;
      if (data == null) return [];
      final collection = data['collection'] as List?;
      if (collection == null) return [];
      return collection.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('SoundCloudApi.searchTracks failed: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTrending({int limit = 20}) async {
    return searchTracks('top hits', limit: limit);
  }

  Future<Map<String, dynamic>?> getTrack(String id) async {
    try {
      final clientId = await _clientIdProvider.getClientId();
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/tracks/$id',
        queryParameters: {'client_id': clientId},
      );
      return response.data;
    } catch (e) {
      debugPrint('SoundCloudApi.getTrack failed: $e');
      return null;
    }
  }

  Future<String?> resolveStreamUrl(String transcodingUrl) async {
    try {
      final clientId = await _clientIdProvider.getClientId();
      final uri = Uri.parse(transcodingUrl);
      final separator = uri.query.isEmpty ? '?' : '&';
      final response = await _dio.get<Map<String, dynamic>>(
        '$transcodingUrl${separator}client_id=$clientId',
      );
      return response.data?['url'] as String?;
    } catch (e) {
      debugPrint('SoundCloudApi.resolveStreamUrl failed: $e');
      return null;
    }
  }
}
