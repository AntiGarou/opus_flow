import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

/// Stores API credentials the user provides in Settings.
///
/// Spotify / Yandex / Jamendo all need credentials to function. At build time
/// they can also be injected via --dart-define; runtime values from
/// SharedPreferences take precedence.
class CredentialsStore {
  static const _kSpotifyClientId = 'spotify_client_id';
  static const _kSpotifyClientSecret = 'spotify_client_secret';
  static const _kYandexOAuthToken = 'yandex_oauth_token';
  static const _kJamendoClientId = 'jamendo_client_id';

  static const _envSpotifyClientId =
      String.fromEnvironment('SPOTIFY_CLIENT_ID');
  static const _envSpotifyClientSecret =
      String.fromEnvironment('SPOTIFY_CLIENT_SECRET');
  static const _envYandexOAuthToken =
      String.fromEnvironment('YANDEX_OAUTH_TOKEN');
  static const _envJamendoClientId =
      String.fromEnvironment('JAMENDO_CLIENT_ID');

  final StreamController<CredentialsSnapshot> _controller =
      StreamController<CredentialsSnapshot>.broadcast();

  CredentialsSnapshot _cache = const CredentialsSnapshot();
  bool _loaded = false;

  CredentialsSnapshot get snapshot => _cache;

  Stream<CredentialsSnapshot> get stream => _controller.stream;

  Future<CredentialsSnapshot> load() async {
    final p = await SharedPreferences.getInstance();
    final snap = CredentialsSnapshot(
      spotifyClientId:
          _pick(p.getString(_kSpotifyClientId), _envSpotifyClientId),
      spotifyClientSecret:
          _pick(p.getString(_kSpotifyClientSecret), _envSpotifyClientSecret),
      yandexOAuthToken:
          _pick(p.getString(_kYandexOAuthToken), _envYandexOAuthToken),
      jamendoClientId:
          _pick(p.getString(_kJamendoClientId), _envJamendoClientId),
    );
    _cache = snap;
    _loaded = true;
    _controller.add(snap);
    return snap;
  }

  Future<void> ensureLoaded() async {
    if (!_loaded) await load();
  }

  Future<void> setSpotify({required String clientId, required String secret}) =>
      _updateMany({
        _kSpotifyClientId: clientId,
        _kSpotifyClientSecret: secret,
      });

  Future<void> setYandexOAuthToken(String token) =>
      _updateMany({_kYandexOAuthToken: token});

  Future<void> setJamendoClientId(String clientId) =>
      _updateMany({_kJamendoClientId: clientId});

  Future<void> clearSpotify() => _updateMany({
        _kSpotifyClientId: '',
        _kSpotifyClientSecret: '',
      });

  Future<void> clearYandex() => _updateMany({_kYandexOAuthToken: ''});

  Future<void> clearJamendo() => _updateMany({_kJamendoClientId: ''});

  Future<void> _updateMany(Map<String, String> values) async {
    final p = await SharedPreferences.getInstance();
    for (final entry in values.entries) {
      if (entry.value.isEmpty) {
        await p.remove(entry.key);
      } else {
        await p.setString(entry.key, entry.value);
      }
    }
    await load();
  }

  String _pick(String? persisted, String envValue) {
    if (persisted != null && persisted.isNotEmpty) return persisted;
    return envValue;
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

class CredentialsSnapshot {
  final String spotifyClientId;
  final String spotifyClientSecret;
  final String yandexOAuthToken;
  final String jamendoClientId;

  const CredentialsSnapshot({
    this.spotifyClientId = '',
    this.spotifyClientSecret = '',
    this.yandexOAuthToken = '',
    this.jamendoClientId = '',
  });

  bool get hasSpotify =>
      spotifyClientId.isNotEmpty && spotifyClientSecret.isNotEmpty;

  bool get hasYandex => yandexOAuthToken.isNotEmpty;

  bool get hasJamendo => jamendoClientId.isNotEmpty;
}
