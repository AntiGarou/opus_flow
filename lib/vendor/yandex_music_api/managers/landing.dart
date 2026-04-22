import '../client.dart';
import '../structures/landing.dart';

/// Landing + feed endpoints.
/// Dart port of `yandex_music._client.landing.LandingMixin`.
class LandingManager {
  LandingManager(this._client);

  final YandexClient _client;

  Future<YFeed?> feed() async {
    final data = await _client.fetch('/feed');
    if (data is! Map) return null;
    return YFeed(Map<String, dynamic>.from(data));
  }

  Future<bool> feedWizardIsPassed() async {
    final data = await _client.fetch('/feed/wizard/is-passed');
    if (data is Map) return data['is_wizard_passed'] as bool? ?? false;
    return false;
  }

  Future<YLanding?> landing(Object blocks) async {
    final joined = blocks is List ? blocks.join(',') : '$blocks';
    final data = await _client.fetch('/landing3',
        params: {'blocks': joined, 'eitherUserId': '10254713668400548221'});
    if (data is! Map) return null;
    return YLanding(Map<String, dynamic>.from(data));
  }

  Future<Map<String, dynamic>?> chart({String chartOption = ''}) async {
    final path = chartOption.isEmpty ? '/landing3/chart' : '/landing3/chart/$chartOption';
    final data = await _client.fetch(path);
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> newReleases() async {
    final data = await _client.fetch('/landing3/new-releases');
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> newPlaylists() async {
    final data = await _client.fetch('/landing3/new-playlists');
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> podcasts() async {
    final data = await _client.fetch('/landing3/podcasts');
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> genres() async {
    final data = await _client.fetch('/genres');
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> tag(String tagId,
      {bool sortByYear = false}) async {
    final data = await _client.fetch('/tags/$tagId/playlist-ids',
        params: {'sort-by-year': sortByYear});
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }
}
