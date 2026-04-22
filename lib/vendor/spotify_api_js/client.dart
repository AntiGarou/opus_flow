import 'package:dio/dio.dart';

import 'cache.dart';
import 'error.dart';
import 'interface.dart';
import 'managers/album.dart';
import 'managers/artist.dart';
import 'managers/auth.dart';
import 'managers/browse.dart';
import 'managers/episode.dart';
import 'managers/playlist.dart';
import 'managers/show.dart';
import 'managers/track.dart';
import 'managers/user.dart';
import 'managers/user_client.dart';

/// Options required to initialise the [Client].
///
/// Either [token] must be supplied directly, or `clientID`/`clientSecret`
/// must be supplied so the client can generate one via client-credentials.
class ClientOptions {
  ClientOptions({
    this.token,
    this.clientID,
    this.clientSecret,
    this.refreshToken,
    this.redirectURL,
    this.code,
    this.userAuthorizedToken = false,
    this.retryOnRateLimit = true,
    CacheSettings? cacheSettings,
    this.onRefresh,
    this.onReady,
    this.onFail,
  }) : cacheSettings = cacheSettings ?? const CacheSettings();

  String? token;
  String? clientID;
  String? clientSecret;
  String? refreshToken;
  String? redirectURL;
  String? code;
  bool userAuthorizedToken;
  bool retryOnRateLimit;
  CacheSettings cacheSettings;
  void Function()? onRefresh;
  void Function(Client client)? onReady;
  void Function(SpotifyAPIError error)? onFail;
}

/// Basic client to interact with the Spotify Web API.
/// Dart port of spotify-api.js `Client`.
class Client {
  Client._(this._options, this._dio) {
    auth = AuthManager(token);
    users = UserManager(this);
    artists = ArtistManager(this);
    browse = BrowseManager(this);
    albums = AlbumManager(this);
    episodes = EpisodeManager(this);
    playlists = PlaylistManager(this);
    shows = ShowManager(this);
    tracks = TrackManager(this);
    retryOnRateLimit = _options.retryOnRateLimit;
    cacheSettings = _options.cacheSettings;
  }

  /// Factory constructor mirroring `Client.create()` in spotify-api.js.
  static Future<Client> create(ClientOptions options, {Dio? dio}) async {
    final client = Client._(options, dio ?? Dio());
    await client._init();
    return client;
  }

  final ClientOptions _options;
  final Dio _dio;

  String token = '';
  String version = 'v1';

  late AuthManager auth;
  late UserManager users;
  late ArtistManager artists;
  late BrowseManager browse;
  late AlbumManager albums;
  late EpisodeManager episodes;
  late PlaylistManager playlists;
  late ShowManager shows;
  late TrackManager tracks;
  UserClient? user;

  late bool retryOnRateLimit;
  late CacheSettings cacheSettings;

  ClientRefreshMeta? refreshMeta;

  void Function() get onRefresh => _options.onRefresh ?? () {};

  /// Search across multiple entity types in one call.
  Future<SearchContent> search(
    String query,
    ClientSearchOptions options,
  ) async {
    final response = SearchContent();
    final fetched = await fetch('/search', FetchOptions(params: {
      'q': query,
      'type': options.types.join(','),
      if (options.market != null) 'market': options.market,
      if (options.limit != null) 'limit': options.limit,
      if (options.offset != null) 'offset': options.offset,
      if (options.includeExternalAudio == true) 'include_external': 'audio',
    }));
    if (fetched is! Map) return response;
    if (fetched['albums'] != null) {
      response.albums = createCacheStructArray(
          'albums', cacheSettings, (fetched['albums']['items'] as List));
    }
    if (fetched['tracks'] != null) {
      response.tracks = createCacheStructArray(
          'tracks', cacheSettings, (fetched['tracks']['items'] as List));
    }
    if (fetched['episodes'] != null) {
      response.episodes = createCacheStructArray(
          'episodes', cacheSettings, (fetched['episodes']['items'] as List));
    }
    if (fetched['shows'] != null) {
      response.shows = createCacheStructArray(
          'shows', cacheSettings, (fetched['shows']['items'] as List));
    }
    if (fetched['artists'] != null) {
      response.artists = createCacheStructArray(
          'artists', cacheSettings, (fetched['artists']['items'] as List));
    }
    return response;
  }

  /// Low-level fetch against the Spotify REST API.
  Future<dynamic> fetch(String url, [FetchOptions options = const FetchOptions()]) async {
    try {
      final response = await _dio.request<dynamic>(
        'https://api.spotify.com/$version$url',
        options: Options(
          method: options.method,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            if (options.headers != null) ...options.headers!,
          },
        ),
        queryParameters: options.params,
        data: options.body,
      );
      return response.data;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 404) return null;
      if (status == 429 && retryOnRateLimit) {
        final retryAfter = error.response?.headers.value('Retry-After');
        final seconds = int.tryParse(retryAfter ?? '') ?? 1;
        await Future<void>.delayed(Duration(seconds: seconds));
        return fetch(url, options);
      }
      final data = error.response?.data;
      final message = (data is Map && data['error'] is Map)
          ? data['error']['message'] as String?
          : null;
      if (refreshMeta != null &&
          (message == 'Invalid access token' ||
              message == 'The access token expired')) {
        await refreshFromMeta();
        return fetch(url, options);
      }
      throw SpotifyAPIError(error);
    }
  }

  /// Refresh the client token using cached refresh metadata.
  Future<void> refreshFromMeta() async {
    final meta = refreshMeta;
    if (meta == null) return;
    if (meta.refreshToken != null || meta.redirectURL != null) {
      final context = await auth.getUserToken(GetUserTokenOptions(
        clientID: meta.clientID,
        clientSecret: meta.clientSecret,
        redirectURL: meta.redirectURL ?? '',
        refreshToken: meta.refreshToken,
      ));
      token = context.accessToken;
      if (context.refreshToken != null) meta.refreshToken = context.refreshToken;
      final uc = UserClient(this);
      await uc.patchInfo();
      user = uc;
    } else {
      token = await auth.getApiToken(meta.clientID, meta.clientSecret);
    }
    auth = AuthManager(token);
    onRefresh();
  }

  Future<void> _init() async {
    if (_options.token == null &&
        (_options.clientID == null || _options.clientSecret == null)) {
      throw SpotifyAPIError('No token was provided in [ClientOptions]');
    }

    try {
      if (_options.token != null) {
        token = _options.token!;
        if (_options.clientID != null && _options.clientSecret != null) {
          refreshMeta = ClientRefreshMeta(
            clientID: _options.clientID!,
            clientSecret: _options.clientSecret!,
            refreshToken: _options.refreshToken,
            redirectURL: _options.redirectURL,
          );
        }
        if (_options.userAuthorizedToken) {
          final uc = UserClient(this);
          await uc.patchInfo();
          user = uc;
        }
      } else if (_options.code != null || _options.refreshToken != null) {
        final context = await AuthManager('').getUserToken(
          GetUserTokenOptions(
            clientID: _options.clientID!,
            clientSecret: _options.clientSecret!,
            redirectURL: _options.redirectURL ?? '',
            code: _options.code,
            refreshToken: _options.refreshToken,
          ),
        );
        token = context.accessToken;
        refreshMeta = ClientRefreshMeta(
          clientID: _options.clientID!,
          clientSecret: _options.clientSecret!,
          refreshToken: context.refreshToken ?? _options.refreshToken,
          redirectURL: _options.redirectURL,
        );
        final uc = UserClient(this);
        await uc.patchInfo();
        user = uc;
      } else {
        token = await AuthManager('')
            .getApiToken(_options.clientID!, _options.clientSecret!);
        refreshMeta = ClientRefreshMeta(
          clientID: _options.clientID!,
          clientSecret: _options.clientSecret!,
        );
      }
      auth = AuthManager(token);
      _options.onReady?.call(this);
    } on SpotifyAPIError catch (e) {
      _options.onFail?.call(e);
      rethrow;
    } catch (e) {
      final wrapped = SpotifyAPIError(e);
      _options.onFail?.call(wrapped);
      throw wrapped;
    }
  }
}
