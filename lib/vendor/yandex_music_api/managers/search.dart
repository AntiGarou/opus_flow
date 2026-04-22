import '../client.dart';
import '../structures/supplement.dart';

/// Search + suggest endpoints.
/// Dart port of `yandex_music._client.search.SearchMixin`.
class SearchManager {
  SearchManager(this._client);

  final YandexClient _client;

  Future<YSearchResult?> call(
    String text, {
    bool nocorrect = false,
    String type = 'all',
    int page = 0,
    bool playlistInBest = true,
  }) async {
    final data = await _client.fetch('/search', params: {
      'text': text,
      'nocorrect': nocorrect,
      'type': type,
      'page': page,
      'playlist-in-best': playlistInBest,
    });
    if (data is! Map) return null;
    return YSearchResult(Map<String, dynamic>.from(data));
  }

  Future<Map<String, dynamic>?> suggest(String part) async {
    final data = await _client.fetch('/search/suggest', params: {'part': part});
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }
}
