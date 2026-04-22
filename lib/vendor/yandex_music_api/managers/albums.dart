import '../client.dart';
import '../structures/album.dart';

/// Album endpoints.
/// Dart port of `yandex_music._client.albums.AlbumsMixin`.
class AlbumsManager {
  AlbumsManager(this._client);

  final YandexClient _client;

  Future<List<YAlbum>> fetchMany(List<Object> ids) async {
    final data = await _client.postForm(
        '/albums', {'album-ids': ids.map((e) => '$e').join(',')});
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((e) => YAlbum(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<YAlbum?> withTracks(Object id) async {
    final data = await _client.fetch('/albums/$id/with-tracks');
    if (data is! Map) return null;
    return YAlbum(Map<String, dynamic>.from(data));
  }

  Future<Map<String, dynamic>?> similar(Object id) async {
    final data = await _client.fetch('/albums/$id/similar');
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> trailer(Object id) async {
    final data = await _client.fetch('/albums/$id/trailer');
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }
}
