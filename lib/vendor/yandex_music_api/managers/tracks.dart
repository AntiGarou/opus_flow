import '../client.dart';
import '../structures/supplement.dart';
import '../structures/track.dart';

/// Track endpoints.
/// Dart port of `yandex_music._client.tracks.TracksMixin`.
class TracksManager {
  TracksManager(this._client);

  final YandexClient _client;

  Future<List<YTrack>> fetchMany(List<Object> ids,
      {bool withPositions = true}) async {
    final data = await _client.postForm('/tracks', {
      'track-ids': ids.map((e) => '$e').join(','),
      'with-positions': withPositions ? 'true' : 'false',
    });
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => YTrack(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<YDownloadInfo>> downloadInfo(Object id,
      {bool getDirectLinks = false}) async {
    final data = await _client.fetch('/tracks/$id/download-info');
    if (data is! List) return const [];
    final infos = data
        .whereType<Map>()
        .map((e) => YDownloadInfo(Map<String, dynamic>.from(e)))
        .toList();
    if (!getDirectLinks) return infos;
    // Caller can follow downloadInfoUrl manually for the signed XML response.
    return infos;
  }

  Future<YSupplement?> supplement(Object id) async {
    final data = await _client.fetch('/tracks/$id/supplement');
    if (data is! Map) return null;
    return YSupplement(Map<String, dynamic>.from(data));
  }

  Future<Map<String, dynamic>?> lyrics(Object id, String sign, int ts) async {
    final data = await _client.fetch('/tracks/$id/lyrics',
        params: {'format': 'LRC', 'timeStamp': ts, 'sign': sign});
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> similar(Object id) async {
    final data = await _client.fetch('/tracks/$id/similar');
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<bool> playAudio(Map<String, dynamic> payload) async {
    final data = await _client.postForm('/play-audio', payload);
    return data != null;
  }

  Future<Map<String, dynamic>?> afterTrack(String nextTrackId,
      String contextItem, {String context = 'playlist'}) async {
    final data = await _client.fetch('/after-track',
        params: {
          'next-track-id': nextTrackId,
          'context-item': contextItem,
          'context': context,
          'types': 'shot',
          'from': 'mobile-landing-origin-default',
        });
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> fullInfo(Object id) async {
    final data = await _client.fetch('/tracks/$id/full-info');
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }
}
