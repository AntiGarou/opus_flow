import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import 'exceptions.dart';
import 'managers/account.dart';
import 'managers/albums.dart';
import 'managers/artists.dart';
import 'managers/landing.dart';
import 'managers/likes.dart';
import 'managers/playlists.dart';
import 'managers/queue.dart';
import 'managers/radio.dart';
import 'managers/search.dart';
import 'managers/tracks.dart';

/// Dart port of the MarshalX `yandex_music.Client`.
///
/// All HTTP traffic goes through [fetch] (or the typed helpers on the manager
/// mixins). Envelope unwrap (the `{invocationInfo, result}` shape) happens
/// inside [fetch] so callers receive the already-unwrapped `result`.
class YandexClient {
  YandexClient({
    this.token,
    this.baseUrl = 'https://api.music.yandex.net',
    this.language = 'ru',
    this.device,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  String? token;
  String baseUrl;
  String language;
  String? device;

  final Dio _dio;

  late final AccountManager account = AccountManager(this);
  late final AlbumsManager albums = AlbumsManager(this);
  late final ArtistsManager artists = ArtistsManager(this);
  late final LandingManager landing = LandingManager(this);
  late final LikesManager likes = LikesManager(this);
  late final PlaylistsManager playlists = PlaylistsManager(this);
  late final QueueManager queue = QueueManager(this);
  late final RadioManager radio = RadioManager(this);
  late final SearchManager search = SearchManager(this);
  late final TracksManager tracks = TracksManager(this);

  /// Initialise the client by calling `/account/status`.
  /// Mirrors `Client.init()` in the Python client.
  Future<YandexClient> init() async {
    await account.status();
    return this;
  }

  /// Low-level fetch. Returns the `result` payload from the Yandex
  /// JSON envelope, or the raw body if no envelope is present.
  Future<dynamic> fetch(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? params,
    Object? body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.request<dynamic>(
        path.startsWith('http') ? path : '$baseUrl$path',
        options: Options(
          method: method,
          headers: {
            if (token != null) 'Authorization': 'OAuth $token',
            'Accept-Language': language,
            if (device != null) 'X-Yandex-Music-Client': device,
            'Accept': 'application/json',
            if (headers != null) ...headers,
          },
          contentType: body is Map || body is List
              ? 'application/x-www-form-urlencoded'
              : null,
        ),
        queryParameters: params,
        data: body,
      );
      final data = response.data;
      if (data is Map && data.containsKey('result')) return data['result'];
      return data;
    } on DioException catch (e) {
      throw makeYandexError(e);
    }
  }

  /// Convenience wrapper for `POST` with form-encoded body.
  Future<dynamic> postForm(String path, Map<String, dynamic> form) =>
      fetch(path, method: 'POST', body: form);

  /// Compute the `sign` value used by `/tracks/{id}/download-info/*/m3u8`.
  /// Dart port of the helper in `yandex_music/utils/sign_request.py`.
  static String computeSign(String path, String ts, String secret) {
    final payload = '$path$ts';
    final hmac = Hmac(sha256, utf8.encode(secret));
    final digest = hmac.convert(utf8.encode(payload));
    return base64Encode(digest.bytes).replaceAll('=', '');
  }
}
