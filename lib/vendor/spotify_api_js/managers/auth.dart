import 'dart:convert';

import 'package:dio/dio.dart';

import '../interface.dart';

/// Dart port of spotify-api.js `AuthManager`.
class AuthManager {
  AuthManager(this.token, {Dio? dio}) : _dio = dio ?? Dio();

  String token;
  final Dio _dio;

  /// Returns an API token for client-credentials flow.
  Future<String> getApiToken(String clientID, String clientSecret) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'https://accounts.spotify.com/api/token',
      data: {
        'grant_type': 'client_credentials',
        'client_id': clientID,
        'client_secret': clientSecret,
      },
      options: Options(
        contentType: 'application/x-www-form-urlencoded',
      ),
    );
    return response.data!['access_token'] as String;
  }

  /// Returns a user-scoped access token via the authorization-code or
  /// refresh-token flow.
  Future<UserTokenContext> getUserToken(GetUserTokenOptions options) async {
    if (options.refreshToken == null && options.code == null) {
      throw ArgumentError(
          "The 'refresh token' and the 'authorization code' supplied to generate a user token is invalid.");
    }
    final grantType = options.refreshToken != null && options.code == null
        ? 'refresh_token'
        : 'authorization_code';

    final credentials =
        base64Encode(utf8.encode('${options.clientID}:${options.clientSecret}'));

    final response = await _dio.post<Map<String, dynamic>>(
      'https://accounts.spotify.com/api/token',
      data: {
        'grant_type': grantType,
        if (options.code != null) 'code': options.code,
        if (options.refreshToken != null) 'refresh_token': options.refreshToken,
        'redirect_uri': options.redirectURL,
      },
      options: Options(
        contentType: 'application/x-www-form-urlencoded',
        headers: {'Authorization': 'Basic $credentials'},
      ),
    );

    final data = response.data!;
    return UserTokenContext(
      accessToken: data['access_token'] as String,
      tokenType: data['token_type'] as String? ?? 'Bearer',
      scope: data['scope'] as String? ?? '',
      refreshToken: data['refresh_token'] as String?,
      expiresIn: data['expires_in'] as int? ?? 3600,
    );
  }
}
