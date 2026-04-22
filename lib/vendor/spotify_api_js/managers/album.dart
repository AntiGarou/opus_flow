import '../cache.dart';
import '../client.dart';
import '../interface.dart';
import '../structures/album.dart';
import '../structures/track.dart';

/// Dart port of spotify-api.js `AlbumManager`.
class AlbumManager {
  AlbumManager(this.client);

  final Client client;

  Future<List<Album>> search(String query,
      [SearchOptions options = const SearchOptions()]) async {
    final fetched = await client.fetch('/search', FetchOptions(params: {
      'q': query,
      'type': 'album',
      if (options.market != null) 'market': options.market,
      if (options.limit != null) 'limit': options.limit,
      if (options.offset != null) 'offset': options.offset,
      if (options.includeExternalAudio == true) 'include_external': 'audio',
    }));
    if (fetched is! Map) return [];
    return createCacheStructArray<Album>(
        'albums', client.cacheSettings, fetched['albums']['items'] as List);
  }

  Future<Album?> get(String id, {bool? force}) async {
    final bypass = force ?? !client.cacheSettings.albums;
    if (!bypass && SpotifyCache.has('albums', id)) {
      return SpotifyCache.get('albums', id) as Album;
    }
    final fetched = await client.fetch('/albums/$id');
    if (fetched is! Map) return null;
    return createCacheStruct<Album>(
        'albums', client.cacheSettings, Map<String, dynamic>.from(fetched));
  }

  Future<List<Album>> getMultiple(List<String> ids) async {
    final fetched = await client
        .fetch('/albums', FetchOptions(params: {'ids': ids.join(',')}));
    if (fetched is! Map) return [];
    return createCacheStructArray<Album>(
        'albums', client.cacheSettings, fetched['albums'] as List);
  }

  Future<List<Track>> getTracks(String id) async {
    final fetched = await client.fetch('/albums/$id/tracks');
    if (fetched is! Map) return [];
    return createCacheStructArray<Track>(
        'tracks', client.cacheSettings, fetched['items'] as List);
  }
}
