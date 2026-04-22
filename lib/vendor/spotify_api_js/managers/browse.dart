import '../cache.dart';
import '../client.dart';
import '../interface.dart';
import '../structures/album.dart';
import '../structures/playlist.dart';
import '../structures/track.dart';

/// Dart port of spotify-api.js `BrowseManager`.
class BrowseManager {
  BrowseManager(this.client);

  final Client client;

  Future<List<Album>> getNewReleases(
      {String? country, int? offset, int? limit}) async {
    final fetched = await client.fetch('/browse/new-releases',
        FetchOptions(params: {
          if (country != null) 'country': country,
          if (offset != null) 'offset': offset,
          if (limit != null) 'limit': limit,
        }));
    if (fetched is! Map) return [];
    return createCacheStructArray<Album>(
        'albums', client.cacheSettings, fetched['albums']['items'] as List);
  }

  Future<FeaturedPlaylistContent?> getFeaturedPlaylists(
      {String? country,
      String? locale,
      String? timestamp,
      int? offset,
      int? limit}) async {
    final fetched = await client.fetch('/browse/featured-playlists',
        FetchOptions(params: {
          if (country != null) 'country': country,
          if (locale != null) 'locale': locale,
          if (timestamp != null) 'timestamp': timestamp,
          if (offset != null) 'offset': offset,
          if (limit != null) 'limit': limit,
        }));
    if (fetched is! Map) return null;
    return FeaturedPlaylistContent(
      message: fetched['message'] as String? ?? '',
      playlists: createCacheStructArray<Playlist>('playlists',
          client.cacheSettings, fetched['playlists']['items'] as List),
    );
  }

  Future<List<Map<String, dynamic>>> getCategories(
      {String? country, String? locale, int? offset, int? limit}) async {
    final fetched = await client.fetch('/browse/categories',
        FetchOptions(params: {
          if (country != null) 'country': country,
          if (locale != null) 'locale': locale,
          if (offset != null) 'offset': offset,
          if (limit != null) 'limit': limit,
        }));
    if (fetched is! Map) return [];
    final items = (fetched['categories'] as Map?)?['items'] as List? ?? [];
    return items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Map<String, dynamic>?> getCategory(String id,
      {String? country, String? locale}) async {
    final data = await client.fetch('/browse/categories/$id',
        FetchOptions(params: {
          if (country != null) 'country': country,
          if (locale != null) 'locale': locale,
        }));
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<List<Playlist>> getCategoryPlaylists(String id,
      {String? country, int? offset, int? limit}) async {
    final fetched = await client.fetch('/browse/categories/$id/playlists',
        FetchOptions(params: {
          if (country != null) 'country': country,
          if (offset != null) 'offset': offset,
          if (limit != null) 'limit': limit,
        }));
    if (fetched is! Map) return [];
    return createCacheStructArray<Playlist>('playlists', client.cacheSettings,
        fetched['playlists']['items'] as List);
  }

  Future<Recommendations?> getRecommendations(
      Map<String, dynamic> query) async {
    final fetched =
        await client.fetch('/recommendations', FetchOptions(params: query));
    if (fetched is! Map) return null;
    return Recommendations(
      seeds: (fetched['seeds'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      tracks: createCacheStructArray<Track>(
          'tracks', client.cacheSettings, fetched['tracks'] as List),
    );
  }

  Future<List<String>> getRecommendationGenreSeeds() async {
    final data = await client.fetch('/recommendations/available-genre-seeds');
    if (data is! Map) return [];
    return ((data['genres'] as List?) ?? const [])
        .map((e) => e as String)
        .toList();
  }

  Future<List<String>> getAvailableMarkets() async {
    final data = await client.fetch('/markets');
    if (data is! Map) return [];
    return ((data['markets'] as List?) ?? const [])
        .map((e) => e as String)
        .toList();
  }
}
