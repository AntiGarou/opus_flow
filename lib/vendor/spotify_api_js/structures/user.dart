import '../util.dart';

/// Spotify api's (public) user object.
/// Dart port of spotify-api.js `structures/User.ts`.
class User {
  User(Map<String, dynamic> data)
      : displayName = data['display_name'] as String?,
        id = data['id'] as String,
        uri = data['uri'] as String,
        type = (data['type'] as String?) ?? 'user',
        images = (data['images'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            const [],
        externalURL = Map<String, String>.from(
            (data['external_urls'] as Map?)?.cast<String, String>() ??
                const <String, String>{}),
        totalFollowers = (data['followers'] as Map?)?['total'] as int?;

  final String? displayName;
  final String id;
  final String uri;
  final String type;
  final List<Map<String, dynamic>> images;
  final Map<String, String> externalURL;
  final int? totalFollowers;

  String codeImage([String color = '1DB954']) => makeCodeImage(uri, color);
}
