import '../cache.dart';
import '../client.dart';
import '../interface.dart';
import '../structures/episode.dart';

/// Dart port of spotify-api.js `EpisodeManager`.
class EpisodeManager {
  EpisodeManager(this.client);

  final Client client;

  Future<List<Episode>> search(String query,
      [SearchOptions options = const SearchOptions()]) async {
    final fetched = await client.fetch('/search', FetchOptions(params: {
      'q': query,
      'type': 'episode',
      'market': options.market ?? 'US',
      if (options.limit != null) 'limit': options.limit,
      if (options.offset != null) 'offset': options.offset,
      if (options.includeExternalAudio == true) 'include_external': 'audio',
    }));
    if (fetched is! Map) return [];
    return createCacheStructArray<Episode>(
        'episodes', client.cacheSettings, fetched['episodes']['items'] as List);
  }

  Future<Episode?> get(String id, {String market = 'US', bool? force}) async {
    final bypass = force ?? !client.cacheSettings.episodes;
    if (!bypass && SpotifyCache.has('episodes', id)) {
      return SpotifyCache.get('episodes', id) as Episode;
    }
    final fetched = await client
        .fetch('/episodes/$id', FetchOptions(params: {'market': market}));
    if (fetched is! Map) return null;
    return createCacheStruct<Episode>(
        'episodes', client.cacheSettings, Map<String, dynamic>.from(fetched));
  }

  Future<List<Episode>> getMultiple(List<String> ids,
      {String market = 'US'}) async {
    final fetched = await client.fetch('/episodes',
        FetchOptions(params: {'ids': ids.join(','), 'market': market}));
    if (fetched is! Map) return [];
    return createCacheStructArray<Episode>(
        'episodes', client.cacheSettings, fetched['episodes'] as List);
  }
}
