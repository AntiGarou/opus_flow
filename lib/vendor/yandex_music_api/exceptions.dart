import 'package:dio/dio.dart';

/// Base Yandex Music API error. Mirrors
/// `yandex_music.exceptions.YandexMusicError`.
class YandexMusicError implements Exception {
  YandexMusicError(this.message, {this.response});

  final String message;
  final Response<dynamic>? response;

  @override
  String toString() => 'YandexMusicError: $message';
}

/// HTTP 401 — invalid token.
class UnauthorizedError extends YandexMusicError {
  UnauthorizedError(super.message, {super.response});
}

/// HTTP 400 — bad request.
class BadRequestError extends YandexMusicError {
  BadRequestError(super.message, {super.response});
}

/// HTTP 404 — not found.
class NotFoundError extends YandexMusicError {
  NotFoundError(super.message, {super.response});
}

/// HTTP 5xx — network/server error.
class NetworkError extends YandexMusicError {
  NetworkError(super.message, {super.response});
}

YandexMusicError makeYandexError(DioException error) {
  final status = error.response?.statusCode;
  final data = error.response?.data;
  final message = (data is Map && data['error'] is Map)
      ? (data['error']['name'] as String?) ?? error.message ?? 'Unknown error'
      : data?.toString() ?? error.message ?? 'Unknown error';
  switch (status) {
    case 400:
      return BadRequestError(message, response: error.response);
    case 401:
      return UnauthorizedError(message, response: error.response);
    case 404:
      return NotFoundError(message, response: error.response);
    default:
      if (status != null && status >= 500) {
        return NetworkError(message, response: error.response);
      }
      return YandexMusicError(message, response: error.response);
  }
}
