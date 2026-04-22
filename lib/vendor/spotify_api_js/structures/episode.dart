import '../util.dart';
import 'show.dart';

/// Spotify api's episode object.
/// Dart port of spotify-api.js `structures/Episode.ts`.
class Episode {
  Episode(Map<String, dynamic> data)
      : audioPreviewURL = data['audio_preview_url'] as String?,
        description = data['description'] as String? ?? '',
        duration = data['duration_ms'] as int? ?? 0,
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
        isPlayable = data['is_playable'] as bool? ?? true,
        languages = (data['languages'] as List?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        name = data['name'] as String,
        releaseDate = data['release_date'] as String? ?? '',
        releaseDatePrecision =
            data['release_date_precision'] as String? ?? 'day',
        restrictions = (data['restrictions'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            const [],
        resumePoint = _extractResume(data['resume_point']),
        type = data['type'] as String? ?? 'episode',
        uri = data['uri'] as String,
        show = data['show'] is Map
            ? Show(Map<String, dynamic>.from(data['show'] as Map))
            : null;

  final String? audioPreviewURL;
  final String description;
  final int duration;
  final bool explicit;
  final Map<String, String> externalURL;
  final String htmlDescription;
  final String id;
  final List<Map<String, dynamic>> images;
  final bool isExternallyHosted;
  final bool isPlayable;
  final List<String> languages;
  final String name;
  final String releaseDate;
  final String releaseDatePrecision;
  final List<Map<String, dynamic>> restrictions;
  final Map<String, dynamic>? resumePoint;
  final String type;
  final String uri;
  final Show? show;

  String codeImage([String color = '1DB954']) => makeCodeImage(uri, color);

  static Map<String, dynamic>? _extractResume(dynamic raw) {
    if (raw is! Map) return null;
    return {
      'fullyPlayed': raw['fully_played'] as bool? ?? false,
      'resumePositionMs': raw['resume_position_ms'] as int? ?? 0,
    };
  }
}
