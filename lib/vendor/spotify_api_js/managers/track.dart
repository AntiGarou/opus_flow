import '../cache.dart';
import '../client.dart';
import '../interface.dart';
import '../structures/track.dart';

/// Dart port of spotify-api.js `TrackManager`.
class TrackManager {
  TrackManager(this.client);

  final Client client;

  Future<List<Track>> search(String query,
      [SearchOptions options = const SearchOptions()]) async {
    final fetched = await client.fetch('/search', FetchOptions(params: {
      'q': query,
      'type': 'track',
      'market': options.market ?? 'US',
      if (options.limit != null) 'limit': options.limit,
      if (options.offset != null) 'offset': options.offset,
      if (options.includeExternalAudio == true) 'include_external': 'audio',
    }));
    if (fetched is! Map) return [];
    return createCacheStructArray<Track>(
        'tracks', client.cacheSettings, fetched['tracks']['items'] as List);
  }

  Future<Track?> get(String id, {String market = 'US', bool? force}) async {
    final bypass = force ?? !client.cacheSettings.tracks;
    if (!bypass && SpotifyCache.has('tracks', id)) {
      return SpotifyCache.get('tracks', id) as Track;
    }
    final fetched = await client
        .fetch('/tracks/$id', FetchOptions(params: {'market': market}));
    if (fetched is! Map) return null;
    return createCacheStruct<Track>(
        'tracks', client.cacheSettings, Map<String, dynamic>.from(fetched));
  }

  Future<List<Track>> getMultiple(List<String> ids,
      {String market = 'US'}) async {
    final fetched = await client.fetch('/tracks',
        FetchOptions(params: {'ids': ids.join(','), 'market': market}));
    if (fetched is! Map) return [];
    return createCacheStructArray<Track>(
        'tracks', client.cacheSettings, fetched['tracks'] as List);
  }

  Future<Map<String, dynamic>?> getAudioFeatures(String id) async {
    final data = await client.fetch('/audio-features/$id');
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<List<Map<String, dynamic>>> getMultipleAudioFeatures(
      List<String> ids) async {
    final data = await client.fetch(
        '/audio-features', FetchOptions(params: {'ids': ids.join(',')}));
    if (data is! Map) return [];
    final list = data['audio_features'] as List?;
    return (list ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<Map<String, dynamic>?> getAudioAnalysis(String id) async {
    final data = await client.fetch('/audio-analysis/$id');
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }
}
