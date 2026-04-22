import '../util.dart';
import 'episode.dart';

/// Spotify api's show object.
/// Dart port of spotify-api.js `structures/Show.ts`.
class Show {
  Show(Map<String, dynamic> data)
      : availableMarkets = (data['available_markets'] as List?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        copyrights = (data['copyrights'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            const [],
        description = data['description'] as String? ?? '',
        explicit = data['explicit'] as bool? ?? false,
        externalURL = Map<String, String>.from(
            (data['external_urls'] as Map?)?.cast<String, String>() ??
                const <String, String>{}),
        htmlDescription = data['html_description'] as String? ?? '',
        id = data['id'] as String,
        images = (data['images'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            const [],
        isExternallyHosted = data['is_externally_hosted'] as bool? ?? false,
        languages = (data['languages'] as List?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        mediaType = data['media_type'] as String? ?? '',
        name = data['name'] as String,
        publisher = data['publisher'] as String? ?? '',
        type = data['type'] as String? ?? 'show',
        uri = data['uri'] as String,
        episodes = _extractEpisodes(data['episodes']);

  final List<String> availableMarkets;
  final List<Map<String, dynamic>> copyrights;
  final String description;
  final bool explicit;
  final Map<String, String> externalURL;
  final String htmlDescription;
  final String id;
  final List<Map<String, dynamic>> images;
  final bool isExternallyHosted;
  final List<String> languages;
  final String mediaType;
  final String name;
  final String publisher;
  final String type;
  final String uri;
  final List<Episode>? episodes;

  String codeImage([String color = '1DB954']) => makeCodeImage(uri, color);

  static List<Episode>? _extractEpisodes(dynamic raw) {
    if (raw == null) return null;
    final list = raw is List
        ? raw
        : raw is Map && raw['items'] is List
            ? raw['items'] as List
            : null;
    if (list == null) return null;
    return list
        .map((e) => Episode(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
