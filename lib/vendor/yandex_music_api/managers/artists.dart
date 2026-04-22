import '../client.dart';
import '../structures/artist.dart';
import '../structures/track.dart';

/// Artist endpoints.
/// Dart port of `yandex_music._client.artists.ArtistsMixin`.
class ArtistsManager {
  ArtistsManager(this._client);

  final YandexClient _client;

  Future<List<YArtist>> fetchMany(List<Object> ids) async {
    final data = await _client.postForm(
        '/artists', {'artist-ids': ids.map((e) => '$e').join(',')});
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((e) => YArtist(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Map<String, dynamic>?> briefInfo(Object id) async {
    final data = await _client.fetch('/artists/$id/brief-info');
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<List<YTrack>> tracks(Object id,
      {int page = 0, int pageSize = 20}) async {
    final data = await _client.fetch('/artists/$id/tracks',
        params: {'page': page, 'page-size': pageSize});
    if (data is! Map) return const [];
    final raw = data['tracks'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => YTrack(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Map<String, dynamic>?> directAlbums(Object id,
      {int page = 0,
      int pageSize = 20,
      String sortBy = 'year'}) async {
    final data = await _client.fetch('/artists/$id/direct-albums',
        params: {'page': page, 'page-size': pageSize, 'sort-by': sortBy});
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> alsoAlbums(Object id,
      {int page = 0,
      int pageSize = 20,
      String sortBy = 'year'}) async {
    final data = await _client.fetch('/artists/$id/also-albums',
        params: {'page': page, 'page-size': pageSize, 'sort-by': sortBy});
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> similar(Object id) async {
    final data = await _client.fetch('/artists/$id/similar');
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> links(Object id) async {
    final data = await _client.fetch('/artists/$id/links');
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> discographyAlbums(Object id,
      {int page = 0,
      int pageSize = 20,
      String sortBy = 'year'}) async {
    final data = await _client.fetch('/artists/$id/discography-albums',
        params: {'page': page, 'page-size': pageSize, 'sort-by': sortBy});
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> trailer(Object id) async {
    final data = await _client.fetch('/artists/$id/trailer');
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> info(Object id) async {
    final data = await _client.fetch('/artists/$id/info');
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> about(Object id) async {
    final data = await _client.fetch('/artists/$id/about');
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }
}
