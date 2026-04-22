import '../cache.dart';
import '../client.dart';
import '../interface.dart';
import '../structures/playlist.dart';

/// Dart port of spotify-api.js `PlaylistManager`.
class PlaylistManager {
  PlaylistManager(this.client);

  final Client client;

  Future<Playlist?> get(String id, {String market = 'US', bool? force}) async {
    final bypass = force ?? !client.cacheSettings.playlists;
    if (!bypass && SpotifyCache.has('playlists', id)) {
      return SpotifyCache.get('playlists', id) as Playlist;
    }
    final fetched = await client
        .fetch('/playlists/$id', FetchOptions(params: {'market': market}));
    if (fetched is! Map) return null;
    return createCacheStruct<Playlist>(
        'playlists', client.cacheSettings, Map<String, dynamic>.from(fetched));
  }

  Future<List<PlaylistTrack>> getTracks(String id,
      {String? market, int? limit, int? offset}) async {
    final fetched = await client.fetch('/playlists/$id/tracks',
        FetchOptions(params: {
          if (market != null) 'market': market,
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        }));
    if (fetched is! Map) return [];
    return createPlaylistTracks(fetched['items'] as List);
  }

  Future<List<Map<String, dynamic>>> getImages(String id) async {
    final fetched = await client.fetch('/playlists/$id/images');
    if (fetched is! List) return [];
    return fetched.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<Playlist?> create(String userID, CreatePlaylistQuery playlist) async {
    final fetched = await client.fetch(
      '/users/$userID/playlists',
      FetchOptions(method: 'POST', body: playlist.toJson()),
    );
    if (fetched is! Map) return null;
    return createCacheStruct<Playlist>(
        'playlists', client.cacheSettings, Map<String, dynamic>.from(fetched));
  }

  Future<bool> edit(String id, Map<String, dynamic> playlist) async {
    final response = await client.fetch(
      '/playlists/$id',
      FetchOptions(method: 'PUT', body: playlist),
    );
    return response != null;
  }

  Future<String> addItems(String id, List<String> uris, {int? position}) async {
    final fetched = await client.fetch(
      '/playlists/$id/tracks',
      FetchOptions(method: 'POST', body: {
        'uris': uris,
        if (position != null) 'position': position,
      }),
    );
    if (fetched is Map) return fetched['snapshot_id'] as String? ?? '';
    return '';
  }

  Future<String> reorderItems(
      String id, PlaylistReorderOptions options) async {
    final fetched = await client.fetch(
      '/playlists/$id/tracks',
      FetchOptions(method: 'PUT', body: {
        if (options.uris != null) 'uris': options.uris,
        if (options.rangeStart != null) 'range_start': options.rangeStart,
        if (options.rangeLength != null) 'range_length': options.rangeLength,
        if (options.insertBefore != null) 'insert_before': options.insertBefore,
        if (options.snapshotID != null) 'snapshot_id': options.snapshotID,
      }),
    );
    if (fetched is Map) return fetched['snapshot_id'] as String? ?? '';
    return '';
  }

  Future<String> removeItems(String id, List<String> uris,
      {String? snapshotID}) async {
    final fetched = await client.fetch(
      '/playlists/$id/tracks',
      FetchOptions(method: 'DELETE', body: {
        'tracks': uris.map((u) => {'uri': u}).toList(),
        if (snapshotID != null) 'snapshot_id': snapshotID,
      }),
    );
    if (fetched is Map) return fetched['snapshot_id'] as String? ?? '';
    return '';
  }

  Future<bool> uploadImage(String id, String base64Jpeg) async {
    final response = await client.fetch(
      '/playlists/$id/images',
      FetchOptions(
        method: 'PUT',
        headers: {'Content-Type': 'image/jpeg'},
        body: base64Jpeg,
      ),
    );
    return response != null;
  }
}
