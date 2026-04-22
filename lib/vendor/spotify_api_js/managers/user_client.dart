import '../cache.dart';
import '../client.dart';
import '../error.dart';
import '../interface.dart';
import '../structures/album.dart';
import '../structures/artist.dart';
import '../structures/episode.dart';
import '../structures/playlist.dart';
import '../structures/show.dart';
import '../structures/track.dart';
import 'player.dart';

/// Manager for the authenticated user's own endpoints.
/// Dart port of spotify-api.js `managers/UserClient.ts`.
class UserClient {
  UserClient(this.client) : player = PlayerManager(client);

  final Client client;
  final PlayerManager player;

  String? displayName;
  late String id;
  String? uri;
  String type = 'user';
  List<Map<String, dynamic>>? images;
  int? totalFollowers;
  Map<String, String>? externalURL;
  String? product;
  String? country;
  String? email;
  Map<String, bool>? explicitContent;

  /// Populate this instance from GET /me.
  Future<UserClient> patchInfo() async {
    final data = await client.fetch('/me');
    if (data is! Map) {
      throw SpotifyAPIError(
          'Could not load private user data from the user-authorized token.');
    }
    displayName = data['display_name'] as String?;
    id = data['id'] as String;
    uri = data['uri'] as String?;
    images = (data['images'] as List?)
        ?.map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    totalFollowers = (data['followers'] as Map?)?['total'] as int?;
    externalURL =
        (data['external_urls'] as Map?)?.cast<String, String>();
    email = data['email'] as String?;
    product = data['product'] as String?;
    country = data['country'] as String?;
    final ec = data['explicit_content'];
    if (ec is Map) {
      explicitContent = {
        'filterEnabled': ec['filter_enabled'] as bool? ?? false,
        'filterLocked': ec['filter_locked'] as bool? ?? false,
      };
    }
    return this;
  }

  Future<List<Playlist>> getPlaylists(
      {int? limit, int? offset, bool fetchAll = false}) async {
    final data = await client.fetch(
      '/me/playlists',
      FetchOptions(params: {
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      }),
    );
    if (data is! Map) return [];
    final all = List<dynamic>.from(data['items'] as List);
    final total = data['total'] as int? ?? all.length;
    if (fetchAll && total > all.length) {
      final pageSize = all.length;
      for (var o = pageSize; o < total; o += pageSize) {
        final next = await client.fetch('/me/playlists',
            FetchOptions(params: {'limit': pageSize, 'offset': o}));
        if (next is Map && next['items'] is List) {
          all.addAll(next['items'] as List);
        }
      }
    }
    return createCacheStructArray<Playlist>(
        'playlists', client.cacheSettings, all);
  }

  Future<Playlist?> createPlaylist(CreatePlaylistQuery playlist) =>
      client.playlists.create(id, playlist);

  /// Verify if the current user follows a playlist.
  Future<bool> followsPlaylist(String playlistID) async {
    final response = await client.users.followsPlaylist(playlistID, [id]);
    return response.isNotEmpty && response.first;
  }

  Future<bool> followPlaylist(String playlistID, {bool isPublic = true}) async {
    final response = await client.fetch(
      '/playlists/$playlistID/followers',
      FetchOptions(method: 'PUT', body: {'public': isPublic}),
    );
    return response != null;
  }

  Future<bool> unfollowPlaylist(String playlistID) async {
    final response = await client.fetch(
      '/playlists/$playlistID/followers',
      FetchOptions(method: 'DELETE'),
    );
    return response != null;
  }

  Future<List<Artist>> getTopArtists({String timeRange = 'medium_term',
      int? limit,
      int? offset}) async {
    final data = await client.fetch('/me/top/artists',
        FetchOptions(params: {
          'time_range': timeRange,
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        }));
    if (data is! Map) return [];
    return createCacheStructArray<Artist>(
        'artists', client.cacheSettings, data['items'] as List);
  }

  Future<List<Track>> getTopTracks({String timeRange = 'medium_term',
      int? limit,
      int? offset}) async {
    final data = await client.fetch('/me/top/tracks',
        FetchOptions(params: {
          'time_range': timeRange,
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        }));
    if (data is! Map) return [];
    return createCacheStructArray<Track>(
        'tracks', client.cacheSettings, data['items'] as List);
  }

  Future<List<Saved<Track>>> getSavedTracks({int? limit, int? offset}) async {
    final data = await client.fetch('/me/tracks',
        FetchOptions(params: {
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        }));
    if (data is! Map) return [];
    return createCacheSavedStructArray<Track>(
        'tracks', client.cacheSettings, data['items'] as List);
  }

  Future<List<Saved<Album>>> getSavedAlbums({int? limit, int? offset}) async {
    final data = await client.fetch('/me/albums',
        FetchOptions(params: {
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        }));
    if (data is! Map) return [];
    return createCacheSavedStructArray<Album>(
        'albums', client.cacheSettings, data['items'] as List);
  }

  Future<List<Saved<Show>>> getSavedShows({int? limit, int? offset}) async {
    final data = await client.fetch('/me/shows',
        FetchOptions(params: {
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        }));
    if (data is! Map) return [];
    return createCacheSavedStructArray<Show>(
        'shows', client.cacheSettings, data['items'] as List);
  }

  Future<List<Saved<Episode>>> getSavedEpisodes(
      {int? limit, int? offset}) async {
    final data = await client.fetch('/me/episodes',
        FetchOptions(params: {
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        }));
    if (data is! Map) return [];
    return createCacheSavedStructArray<Episode>(
        'episodes', client.cacheSettings, data['items'] as List);
  }

  Future<List<bool>> hasSavedTracks(List<String> ids) =>
      _contains('/me/tracks/contains', ids);

  Future<List<bool>> hasSavedAlbums(List<String> ids) =>
      _contains('/me/albums/contains', ids);

  Future<List<bool>> hasSavedShows(List<String> ids) =>
      _contains('/me/shows/contains', ids);

  Future<List<bool>> hasSavedEpisodes(List<String> ids) =>
      _contains('/me/episodes/contains', ids);

  Future<bool> saveTracks(List<String> ids) =>
      _libraryPut('/me/tracks', ids);

  Future<bool> saveAlbums(List<String> ids) =>
      _libraryPut('/me/albums', ids);

  Future<bool> saveShows(List<String> ids) =>
      _libraryPut('/me/shows', ids);

  Future<bool> saveEpisodes(List<String> ids) =>
      _libraryPut('/me/episodes', ids);

  Future<bool> removeTracks(List<String> ids) =>
      _libraryDelete('/me/tracks', ids);

  Future<bool> removeAlbums(List<String> ids) =>
      _libraryDelete('/me/albums', ids);

  Future<bool> removeShows(List<String> ids) =>
      _libraryDelete('/me/shows', ids);

  Future<bool> removeEpisodes(List<String> ids) =>
      _libraryDelete('/me/episodes', ids);

  Future<List<Artist>> getFollowedArtists({int? limit, String? after}) async {
    final data = await client.fetch('/me/following',
        FetchOptions(params: {
          'type': 'artist',
          if (limit != null) 'limit': limit,
          if (after != null) 'after': after,
        }));
    if (data is! Map) return [];
    return createCacheStructArray<Artist>('artists',
        client.cacheSettings, (data['artists'] as Map)['items'] as List);
  }

  Future<List<bool>> _contains(String path, List<String> ids) async {
    final data = await client
        .fetch(path, FetchOptions(params: {'ids': ids.join(',')}));
    if (data is! List) return [];
    return data.map((e) => e as bool).toList();
  }

  Future<bool> _libraryPut(String path, List<String> ids) async {
    final response = await client.fetch(
      path,
      FetchOptions(method: 'PUT', params: {'ids': ids.join(',')}),
    );
    return response != null;
  }

  Future<bool> _libraryDelete(String path, List<String> ids) async {
    final response = await client.fetch(
      path,
      FetchOptions(method: 'DELETE', params: {'ids': ids.join(',')}),
    );
    return response != null;
  }
}
