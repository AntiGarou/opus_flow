import '../client.dart';
import '../structures/playlist.dart';

/// Playlist endpoints.
/// Dart port of `yandex_music._client.playlists.PlaylistsMixin`.
class PlaylistsManager {
  PlaylistsManager(this._client);

  final YandexClient _client;

  String? _resolveUserId(Object? userId) {
    if (userId != null) return '$userId';
    return null;
  }

  Future<List<YPlaylist>> userPlaylistsList({Object? userId}) async {
    final uid = _resolveUserId(userId);
    if (uid == null) {
      throw ArgumentError('userId is required for users_playlists_list');
    }
    final data = await _client.fetch('/users/$uid/playlists/list');
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => YPlaylist(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<int>> userPlaylistsKinds({Object? userId}) async {
    final uid = _resolveUserId(userId);
    if (uid == null) {
      throw ArgumentError('userId is required for users_playlists_kinds');
    }
    final data = await _client.fetch('/users/$uid/playlists/kinds');
    if (data is! Map) return const [];
    final list = data['kinds'];
    if (list is! List) return const [];
    return list.whereType<num>().map((e) => e.toInt()).toList();
  }

  Future<YPlaylist?> userPlaylist(Object userId, Object kind,
      {bool mixed = false, bool rich = false}) async {
    final data = await _client.fetch('/users/$userId/playlists/$kind',
        params: {'mixed': mixed, 'rich-tracks': rich});
    if (data is! Map) return null;
    return YPlaylist(Map<String, dynamic>.from(data));
  }

  Future<List<YPlaylist>> userPlaylists(Object userId, List<Object> kinds,
      {bool mixed = false, bool rich = false}) async {
    final data = await _client.postForm('/users/$userId/playlists', {
      'kinds': kinds.map((e) => '$e').join(','),
      'mixed': mixed.toString(),
      'rich-tracks': rich.toString(),
    });
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => YPlaylist(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<YPlaylist?> playlist(String playlistUuid) async {
    final data = await _client.fetch('/playlist/$playlistUuid');
    if (data is! Map) return null;
    return YPlaylist(Map<String, dynamic>.from(data));
  }

  Future<List<YPlaylist>> playlistsList(List<String> ids) async {
    final data = await _client.postForm('/playlists/list', {
      'playlistIds': ids.join(','),
    });
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => YPlaylist(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Map<String, dynamic>?> personal(String playlistId) async {
    final data = await _client.fetch('/users/personal-playlists/$playlistId');
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<YPlaylist?> create(String title,
      {String visibility = 'public', Object? userId}) async {
    final uid = _resolveUserId(userId);
    if (uid == null) {
      throw ArgumentError('userId is required for users_playlists_create');
    }
    final data = await _client.postForm('/users/$uid/playlists/create',
        {'title': title, 'visibility': visibility});
    if (data is! Map) return null;
    return YPlaylist(Map<String, dynamic>.from(data));
  }

  Future<Map<String, dynamic>?> delete(Object kind, {Object? userId}) async {
    final uid = _resolveUserId(userId);
    if (uid == null) {
      throw ArgumentError('userId is required for users_playlists_delete');
    }
    final data = await _client.postForm('/users/$uid/playlists/$kind/delete',
        const <String, dynamic>{});
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> rename(Object kind, String newTitle,
      {Object? userId}) async {
    final uid = _resolveUserId(userId);
    if (uid == null) {
      throw ArgumentError('userId is required for users_playlists_name');
    }
    final data = await _client
        .postForm('/users/$uid/playlists/$kind/name', {'value': newTitle});
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> setVisibility(Object kind, String visibility,
      {Object? userId}) async {
    final uid = _resolveUserId(userId);
    if (uid == null) {
      throw ArgumentError('userId is required for users_playlists_visibility');
    }
    final data = await _client.postForm(
        '/users/$uid/playlists/$kind/visibility', {'value': visibility});
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> setDescription(Object kind, String description,
      {Object? userId}) async {
    final uid = _resolveUserId(userId);
    if (uid == null) {
      throw ArgumentError('userId is required for users_playlists_description');
    }
    final data = await _client.postForm(
        '/users/$uid/playlists/$kind/update', {'description': description});
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> change(Object kind, String diff,
      {int revision = 1, Object? userId}) async {
    final uid = _resolveUserId(userId);
    if (uid == null) {
      throw ArgumentError('userId is required for users_playlists_change');
    }
    final data = await _client.postForm('/users/$uid/playlists/$kind/change',
        {'kind': '$kind', 'revision': '$revision', 'diff': diff});
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> insertTrack(Object kind, Object trackId,
      Object albumId,
      {int at = 0, int revision = 1, Object? userId}) async {
    final diff =
        '[{"op":"insert","at":$at,"tracks":[{"id":"$trackId","albumId":"$albumId"}]}]';
    return change(kind, diff, revision: revision, userId: userId);
  }

  Future<Map<String, dynamic>?> deleteTrack(Object kind,
      {required int from,
      required int to,
      int revision = 1,
      Object? userId}) async {
    final diff = '[{"op":"delete","from":$from,"to":$to}]';
    return change(kind, diff, revision: revision, userId: userId);
  }
}
