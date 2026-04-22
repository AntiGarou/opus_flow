import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class SoundCloudClientIdProvider {
  final Dio _dio;

  static const _fallbackIds = [
    'iZIs9mchVcX5lbVRKCFoxyQdNklfW4yD',
    'JYcZsDqFQFCLCwrKzJYk8gDv5aKOIjhi',
  ];

  String? _cachedId;
  DateTime? _cachedAt;
  static const _ttl = Duration(hours: 1);

  SoundCloudClientIdProvider({Dio? dio}) : _dio = dio ?? Dio();

  Future<String> getClientId() async {
    if (_cachedId != null && _cachedAt != null) {
      if (DateTime.now().difference(_cachedAt!) < _ttl) {
        return _cachedId!;
      }
    }

    final scraped = await _scrape();
    if (scraped != null) {
      _cachedId = scraped;
      _cachedAt = DateTime.now();
      return scraped;
    }

    _cachedId = _fallbackIds.first;
    _cachedAt = DateTime.now();
    return _cachedId!;
  }

  Future<String?> _scrape() async {
    try {
      final response = await _dio.get<String>(
        'https://m.soundcloud.com',
        options: Options(
          headers: {
            'User-Agent':
                'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
          },
          responseType: ResponseType.plain,
        ),
      );
      final html = response.data ?? '';

      final inline = RegExp(r'"clientId":"([^"]+)"').firstMatch(html);
      if (inline != null) {
        return inline.group(1);
      }

      final scriptMatches =
          RegExp(r'https://[^"]+\.js').allMatches(html).map((m) => m.group(0)!);
      for (final scriptUrl in scriptMatches.take(20)) {
        try {
          final js = await _dio.get<String>(
            scriptUrl,
            options: Options(responseType: ResponseType.plain),
          );
          final body = js.data ?? '';
          final match = RegExp(r'client_id:"([^"]+)"').firstMatch(body);
          if (match != null) {
            return match.group(1);
          }
        } catch (e) {
          debugPrint('SoundCloudClientIdProvider: script fetch failed: $e');
        }
      }
    } catch (e) {
      debugPrint('SoundCloudClientIdProvider: scrape failed: $e');
    }
    return null;
  }

  void invalidate() {
    _cachedId = null;
    _cachedAt = null;
  }
}
