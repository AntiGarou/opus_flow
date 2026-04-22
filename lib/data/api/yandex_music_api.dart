import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class YandexMusicApi {
  static const _baseUrl = 'https://api.music.yandex.net';
  static const _clientHeader = 'YandexMusicAndroid/24023621';
  static const _lyricsKey = 'p93jhgh689SBReK6ghtw62';

  final Dio _dio;
  final String? _oauthToken;

  YandexMusicApi({Dio? dio, String? oauthToken})
      : _dio = dio ?? Dio(),
        _oauthToken = oauthToken;

  Map<String, String> _headers() {
    final headers = <String, String>{
      'X-Yandex-Music-Client': _clientHeader,
    };
    final token = _oauthToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'OAuth $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>?> _get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl$path',
        queryParameters: query,
        options: Options(headers: _headers()),
      );
      return response.data;
    } catch (e) {
      debugPrint('YandexMusicApi GET $path failed: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl$path',
        queryParameters: query,
        data: data,
        options: Options(
          headers: _headers(),
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      return response.data;
    } catch (e) {
      debugPrint('YandexMusicApi POST $path failed: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> search(
    String text, {
    String type = 'track',
  }) async {
    final data = await _get('/search', query: {'text': text, 'type': type});
    return data?['result'] as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>?> searchSuggest(String part) async {
    final data = await _get('/search/suggest', query: {'part': part});
    return data?['result'] as Map<String, dynamic>?;
  }

  Future<List<Map<String, dynamic>>> tracks(List<String> trackIds) async {
    final data =
        await _get('/tracks', query: {'track-ids': trackIds.join(',')});
    final result = data?['result'] as List?;
    if (result == null) return [];
    return result.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> trackDownloadInfo(String trackId) async {
    final data = await _get('/tracks/$trackId/download-info');
    final result = data?['result'] as List?;
    if (result == null) return [];
    return result.cast<Map<String, dynamic>>();
  }

  ({int timestamp, String value}) _sign() {
    final ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final hmac = Hmac(sha256, utf8.encode(_lyricsKey));
    final digest = hmac.convert(utf8.encode('$ts'));
    final sign = base64.encode(digest.bytes);
    return (timestamp: ts, value: sign);
  }

  Future<String?> tracksLyrics(String trackId) async {
    try {
      final signed = _sign();
      final data = await _get('/tracks/$trackId/lyrics', query: {
        'format': 'TEXT',
        'timeStamp': signed.timestamp,
        'sign': signed.value,
      });
      final download = data?['result']?['downloadUrl'] as String?;
      if (download == null) return null;
      final lyrics = await _dio.get<String>(
        download,
        options: Options(responseType: ResponseType.plain),
      );
      return lyrics.data;
    } catch (e) {
      debugPrint('YandexMusicApi.tracksLyrics failed: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> similarTracks(String trackId) async {
    final data = await _get('/tracks/$trackId/similar');
    final similar = data?['result']?['similarTracks'] as List?;
    if (similar == null) return [];
    return similar.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> trackSupplement(String trackId) async {
    final data = await _get('/tracks/$trackId/supplement');
    return data?['result'] as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>?> landing({
    List<String> blocks = const ['personalplaylists', 'chart', 'new-releases'],
  }) async {
    final data = await _get('/landing3', query: {'blocks': blocks.join(',')});
    return data?['result'] as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>?> chart() async {
    final data = await _get('/landing3/chart');
    return data?['result'] as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>?> newReleases() async {
    final data = await _get('/landing3/new-releases');
    return data?['result'] as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>?> newPlaylists() async {
    final data = await _get('/landing3/new-playlists');
    return data?['result'] as Map<String, dynamic>?;
  }

  Future<List<Map<String, dynamic>>> genres() async {
    final data = await _get('/genres');
    final result = data?['result'] as List?;
    if (result == null) return [];
    return result.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> albums(List<String> albumIds) async {
    final data =
        await _get('/albums', query: {'album-ids': albumIds.join(',')});
    final result = data?['result'] as List?;
    if (result == null) return [];
    return result.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> artist(String artistId) async {
    final data = await _get('/artists/$artistId');
    return data?['result'] as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>?> artistTracks(String artistId) async {
    final data = await _get('/artists/$artistId/tracks');
    return data?['result'] as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>?> artistAlbums(String artistId) async {
    final data = await _get('/artists/$artistId/albums');
    return data?['result'] as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>?> rotorDashboard() async {
    final data = await _get('/rotor/stations/dashboard');
    return data?['result'] as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>?> rotorStationTracks(String stationId) async {
    final data = await _get('/rotor/station/$stationId/tracks');
    return data?['result'] as Map<String, dynamic>?;
  }

  Future<void> playAudio(Map<String, dynamic> body) async {
    await _post('/play-audio', data: body);
  }

  Future<String?> getTrackStreamUrl(String trackId) async {
    try {
      final downloadInfos = await trackDownloadInfo(trackId);
      if (downloadInfos.isEmpty) return null;
      final mp3 = downloadInfos.firstWhere(
        (d) => d['codec'] == 'mp3' && (d['bitrateInKbps'] ?? 0) == 192,
        orElse: () => downloadInfos.firstWhere(
          (d) => d['codec'] == 'mp3',
          orElse: () => downloadInfos.first,
        ),
      );
      final downloadInfoUrl = mp3['downloadInfoUrl'] as String?;
      if (downloadInfoUrl == null) return null;

      final separator = downloadInfoUrl.contains('?') ? '&' : '?';
      final infoResponse = await _dio.get<String>(
        '$downloadInfoUrl${separator}format=json',
        options: Options(headers: _headers()),
      );
      final body = infoResponse.data ?? '';
      final parsed = jsonDecode(body) as Map<String, dynamic>;
      final s = parsed['s'] as String?;
      final ts = parsed['ts'] as String?;
      final path = parsed['path'] as String?;
      final host = parsed['host'] as String?;
      if (s == null || ts == null || path == null || host == null) return null;
      return 'https://$host$path?s=$s&ts=$ts';
    } catch (e) {
      debugPrint('YandexMusicApi.getTrackStreamUrl failed: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> userPlaylists(String userId) async {
    final data = await _get('/users/$userId/playlists/list');
    return data?['result'] as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>?> userLikedTracks(String userId) async {
    final data = await _get('/users/$userId/likes/tracks');
    return data?['result'] as Map<String, dynamic>?;
  }
}
