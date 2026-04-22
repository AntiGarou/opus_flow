import '../client.dart';
import '../structures/user.dart';

/// Account + settings endpoints.
/// Dart port of `yandex_music._client.account.AccountMixin`.
class AccountManager {
  AccountManager(this._client);

  final YandexClient _client;

  Future<YStatus?> status() async {
    final data = await _client.fetch('/account/status');
    if (data is! Map) return null;
    final status = YStatus(Map<String, dynamic>.from(data));
    return status;
  }

  Future<Map<String, dynamic>?> settings() async {
    final data = await _client.fetch('/account/settings');
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> setSetting(String param, Object value) async {
    final data = await _client
        .postForm('/account/settings', {param: value.toString()});
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> permissionAlerts() async {
    final data = await _client.fetch('/permission-alerts');
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> experiments() async {
    final data = await _client.fetch('/account/experiments');
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> experimentsDetails() async {
    final data = await _client.fetch('/account/experiments/details');
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> consumePromoCode(String code,
      {String language = 'en'}) async {
    final data = await _client.postForm(
        '/account/consume-promo-code', {'code': code, 'language': language});
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }
}
