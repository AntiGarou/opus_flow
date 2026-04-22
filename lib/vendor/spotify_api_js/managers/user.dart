import '../cache.dart';
import '../client.dart';
import '../interface.dart';
import '../structures/playlist.dart';
import '../structures/user.dart';

/// Dart port of spotify-api.js `UserManager`.
class UserManager {
  UserManager(this.client);

  final Client client;

  Future<User?> get(String id, {bool? force}) async {
    final bypass = force ?? !client.cacheSettings.users;
    if (!bypass && SpotifyCache.has('users', id)) {
      return SpotifyCache.get('users', id) as User;
    }
    final fetched = await client.fetch('/users/$id');
    if (fetched is! Map) return null;
    return createCacheStruct<User>(
        'users', client.cacheSettings, Map<String, dynamic>.from(fetched));
  }

  Future<List<Playlist>> getPlaylists(String id,
      {int? limit, int? offset}) async {
    final fetched = await client.fetch('/users/$id/playlists',
        FetchOptions(params: {
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        }));
    if (fetched is! Map) return [];
    return createCacheStructArray<Playlist>(
        'playlists', client.cacheSettings, fetched['items'] as List);
  }

  Future<List<bool>> followsPlaylist(
      String playlistID, List<String> userIDs) async {
    final data = await client.fetch(
      '/playlists/$playlistID/followers/contains',
      FetchOptions(params: {'ids': userIDs.join(',')}),
    );
    if (data is! List) return [];
    return data.map((e) => e as bool).toList();
  }

  Future<bool> follow(List<String> ids) async {
    final response = await client.fetch(
      '/me/following',
      FetchOptions(method: 'PUT', params: {'type': 'user', 'ids': ids.join(',')}),
    );
    return response != null;
  }

  Future<bool> unfollow(List<String> ids) async {
    final response = await client.fetch(
      '/me/following',
      FetchOptions(method: 'DELETE', params: {'type': 'user', 'ids': ids.join(',')}),
    );
    return response != null;
  }
}
