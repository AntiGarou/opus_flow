import 'package:dio/dio.dart';

/// Thrown when the Spotify Web API fails or returns an invalid body.
/// Dart port of spotify-api.js `SpotifyAPIError`.
class SpotifyAPIError implements Exception {
  SpotifyAPIError(Object error)
      : message = error is String
            ? error
            : error is DioException
                ? (error.response?.data?.toString() ?? error.message ?? 'Spotify API error')
                : error.toString(),
        response = error is DioException ? error.response : null;

  final String message;
  final Response<dynamic>? response;

  @override
  String toString() => 'SpotifyAPIError: $message';
}
