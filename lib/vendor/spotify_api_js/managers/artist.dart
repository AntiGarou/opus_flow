import '../cache.dart';
import '../client.dart';
import '../interface.dart';
import '../structures/album.dart';
import '../structures/artist.dart';
import '../structures/track.dart';

/// Dart port of spotify-api.js `ArtistManager`.
class ArtistManager {
  ArtistManager(this.client);

  final Client client;

  Future<List<Artist>> search(String query,
      [SearchOptions options = const SearchOptions()]) async {
    final fetched = await client.fetch('/search', FetchOptions(params: {
      'q': query,
      'type': 'artist',
      if (options.market != null) 'market': options.market,
      if (options.limit != null) 'limit': options.limit,
      if (options.offset != null) 'offset': options.offset,
      if (options.includeExternalAudio == true) 'include_external': 'audio',
    }));
    if (fetched is! Map) return [];
    return createCacheStructArray<Artist>(
        'artists', client.cacheSettings, fetched['artists']['items'] as List);
  }

  Future<Artist?> get(String id, {bool? force}) async {
    final bypass = force ?? !client.cacheSettings.artists;
    if (!bypass && SpotifyCache.has('artists', id)) {
      return SpotifyCache.get('artists', id) as Artist;
    }
    final fetched = await client.fetch('/artists/$id');
    if (fetched is! Map) return null;
    return createCacheStruct<Artist>(
        'artists', client.cacheSettings, Map<String, dynamic>.from(fetched));
  }

  Future<List<Artist>> getMultiple(List<String> ids) async {
    final fetched = await client
        .fetch('/artists', FetchOptions(params: {'ids': ids.join(',')}));
    if (fetched is! Map) return [];
    return createCacheStructArray<Artist>(
        'artists', client.cacheSettings, fetched['artists'] as List);
  }

  Future<List<Track>> getTopTracks(String id, {String market = 'US'}) async {
    final fetched = await client
        .fetch('/artists/$id/top-tracks', FetchOptions(params: {'market': market}));
    if (fetched is! Map) return [];
    return createCacheStructArray<Track>(
        'tracks', client.cacheSettings, fetched['tracks'] as List);
  }

  Future<List<Artist>> getRelatedArtists(String id) async {
    final fetched = await client.fetch('/artists/$id/related-artists');
    if (fetched is! Map) return [];
    return createCacheStructArray<Artist>(
        'artists', client.cacheSettings, fetched['artists'] as List);
  }

  Future<List<Album>> getAlbums(String id,
      {String? includeGroups, String? market, int? limit, int? offset}) async {
    final fetched = await client.fetch('/artists/$id/albums',
        FetchOptions(params: {
          if (includeGroups != null) 'include_groups': includeGroups,
          if (market != null) 'market': market,
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        }));
    if (fetched is! Map) return [];
    return createCacheStructArray<Album>(
        'albums', client.cacheSettings, fetched['items'] as List);
  }

  Future<bool> follow(List<String> ids) async {
    final response = await client.fetch(
      '/me/following',
      FetchOptions(method: 'PUT', params: {'type': 'artist', 'ids': ids.join(',')}),
    );
    return response != null;
  }

  Future<bool> unfollow(List<String> ids) async {
    final response = await client.fetch(
      '/me/following',
      FetchOptions(method: 'DELETE', params: {'type': 'artist', 'ids': ids.join(',')}),
    );
    return response != null;
  }
}
