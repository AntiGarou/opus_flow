import '../client.dart';

/// Likes + dislikes endpoints.
/// Dart port of `yandex_music._client.likes.LikesMixin`.
class LikesManager {
  LikesManager(this._client);

  final YandexClient _client;

  String _resolveUserId(Object? userId) {
    if (userId == null) {
      throw ArgumentError('userId is required for likes endpoints');
    }
    return '$userId';
  }

  Future<Map<String, dynamic>?> _toggle(String entity, String action,
      List<Object> ids, Object? userId) async {
    final uid = _resolveUserId(userId);
    final field = entity.endsWith('s') ? '$entity-ids' : '$entity-ids';
    final data = await _client.postForm(
        '/users/$uid/likes/$entity/$action-multiple',
        {field: ids.map((e) => '$e').join(',')});
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> addTracks(List<Object> ids, {Object? userId}) =>
      _toggle('tracks', 'add', ids, userId);

  Future<Map<String, dynamic>?> removeTracks(List<Object> ids,
          {Object? userId}) =>
      _toggle('tracks', 'remove', ids, userId);

  Future<Map<String, dynamic>?> addAlbums(List<Object> ids, {Object? userId}) =>
      _toggle('albums', 'add', ids, userId);

  Future<Map<String, dynamic>?> removeAlbums(List<Object> ids,
          {Object? userId}) =>
      _toggle('albums', 'remove', ids, userId);

  Future<Map<String, dynamic>?> addArtists(List<Object> ids,
          {Object? userId}) =>
      _toggle('artists', 'add', ids, userId);

  Future<Map<String, dynamic>?> removeArtists(List<Object> ids,
          {Object? userId}) =>
      _toggle('artists', 'remove', ids, userId);

  Future<Map<String, dynamic>?> addPlaylists(List<Object> ids,
          {Object? userId}) =>
      _toggle('playlists', 'add', ids, userId);

  Future<Map<String, dynamic>?> removePlaylists(List<Object> ids,
          {Object? userId}) =>
      _toggle('playlists', 'remove', ids, userId);

  Future<List<Map<String, dynamic>>> _list(String entity, Object? userId,
      {bool withTimestamps = false}) async {
    final uid = _resolveUserId(userId);
    final path = '/users/$uid/likes/$entity';
    final data = await _client.fetch(
      path,
      params:
          withTimestamps ? {'if-modified-since-revision': 0} : null,
    );
    if (data is Map && data['library'] is Map) {
      final library = data['library'] as Map;
      final raw = library[entity];
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  Future<List<Map<String, dynamic>>> tracksList(Object userId) =>
      _list('tracks', userId);

  Future<List<Map<String, dynamic>>> albumsList(Object userId) =>
      _list('albums', userId);

  Future<List<Map<String, dynamic>>> artistsList(Object userId) =>
      _list('artists', userId);

  Future<List<Map<String, dynamic>>> playlistsList(Object userId) =>
      _list('playlists', userId);

  /// Dislikes
  Future<Map<String, dynamic>?> addDislikedTracks(List<Object> ids,
          {Object? userId}) =>
      _toggle('tracks', 'add', ids, userId);

  Future<Map<String, dynamic>?> removeDislikedTracks(List<Object> ids,
          {Object? userId}) =>
      _toggle('tracks', 'remove', ids, userId);
}
