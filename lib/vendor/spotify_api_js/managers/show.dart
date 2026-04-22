import '../cache.dart';
import '../client.dart';
import '../interface.dart';
import '../structures/episode.dart';
import '../structures/show.dart';

/// Dart port of spotify-api.js `ShowManager`.
class ShowManager {
  ShowManager(this.client);

  final Client client;

  Future<List<Show>> search(String query,
      [SearchOptions options = const SearchOptions()]) async {
    final fetched = await client.fetch('/search', FetchOptions(params: {
      'q': query,
      'type': 'show',
      'market': options.market ?? 'US',
      if (options.limit != null) 'limit': options.limit,
      if (options.offset != null) 'offset': options.offset,
      if (options.includeExternalAudio == true) 'include_external': 'audio',
    }));
    if (fetched is! Map) return [];
    return createCacheStructArray<Show>(
        'shows', client.cacheSettings, fetched['shows']['items'] as List);
  }

  Future<Show?> get(String id, {String market = 'US', bool? force}) async {
    final bypass = force ?? !client.cacheSettings.shows;
    if (!bypass && SpotifyCache.has('shows', id)) {
      return SpotifyCache.get('shows', id) as Show;
    }
    final fetched = await client
        .fetch('/shows/$id', FetchOptions(params: {'market': market}));
    if (fetched is! Map) return null;
    return createCacheStruct<Show>(
        'shows', client.cacheSettings, Map<String, dynamic>.from(fetched));
  }

  Future<List<Show>> getMultiple(List<String> ids,
      {String market = 'US'}) async {
    final fetched = await client.fetch('/shows',
        FetchOptions(params: {'ids': ids.join(','), 'market': market}));
    if (fetched is! Map) return [];
    return createCacheStructArray<Show>(
        'shows', client.cacheSettings, fetched['shows'] as List);
  }

  Future<List<Episode>> getEpisodes(String id,
      {int? limit, int? offset, String market = 'US'}) async {
    final fetched = await client.fetch('/shows/$id/episodes',
        FetchOptions(params: {
          'market': market,
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        }));
    if (fetched is! Map) return [];
    return createCacheStructArray<Episode>(
        'episodes', client.cacheSettings, fetched['items'] as List);
  }
}
