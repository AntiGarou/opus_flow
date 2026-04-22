import '../util.dart';

/// Spotify api's artist object.
/// Dart port of spotify-api.js `structures/Artist.ts`.
class Artist {
  Artist(Map<String, dynamic> data)
      : externalURL = Map<String, String>.from(
            (data['external_urls'] as Map?)?.cast<String, String>() ??
                const <String, String>{}),
        id = data['id'] as String,
        name = data['name'] as String,
        type = data['type'] as String? ?? 'artist',
        uri = data['uri'] as String,
        images = (data['images'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            const [],
        popularity = data['popularity'] as int?,
        genres =
            (data['genres'] as List?)?.map((e) => e as String).toList(),
        totalFollowers =
            (data['followers'] as Map?)?['total'] as int?;

  final Map<String, String> externalURL;
  final String id;
  final String name;
  final String type;
  final String uri;
  final List<Map<String, dynamic>> images;
  final int? popularity;
  final List<String>? genres;
  final int? totalFollowers;

  /// Returns a scannables.scdn.co code image URL for this artist.
  String codeImage([String color = '1DB954']) => makeCodeImage(uri, color);
}
