import '../interface.dart';
import '../util.dart';
import 'album.dart';
import 'artist.dart';

/// Spotify api's track object.
/// Dart port of spotify-api.js `structures/Track.ts`.
class Track {
  Track(Map<String, dynamic> data)
      : artists = ((data['artists'] as List?) ?? const [])
            .map((a) => Artist(Map<String, dynamic>.from(a as Map)))
            .toList(),
        availableMarkets = (data['available_markets'] as List?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        discNumber = data['disc_number'] as int? ?? 1,
        duration = data['duration_ms'] as int? ?? 0,
        explicit = data['explicit'] as bool? ?? false,
        externalURL = Map<String, String>.from(
            (data['external_urls'] as Map?)?.cast<String, String>() ??
                const <String, String>{}),
        id = data['id'] as String,
        isLocal = data['is_local'] as bool? ?? false,
        isPlayable = data['is_playable'] as bool?,
        linkedFrom = _makeLinked(data['linked_from']),
        name = data['name'] as String,
        previewURL = data['preview_url'] as String?,
        restrictions = (data['restrictions'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            const [],
        trackNumber = data['track_number'] as int? ?? 1,
        type = data['type'] as String? ?? 'track',
        uri = data['uri'] as String,
        album = data['album'] is Map
            ? Album(Map<String, dynamic>.from(data['album'] as Map))
            : null,
        externalID = (data['external_ids'] as Map?)?.cast<String, String>(),
        popularity = data['popularity'] as int?;

  final List<Artist> artists;
  final List<String> availableMarkets;
  final int discNumber;
  final int duration;
  final bool explicit;
  final Map<String, String> externalURL;
  final String id;
  final bool isLocal;
  final bool? isPlayable;
  final LinkedTrack? linkedFrom;
  final String name;
  final String? previewURL;
  final List<Map<String, dynamic>> restrictions;
  final int trackNumber;
  final String type;
  final String uri;

  final Album? album;
  final Map<String, String>? externalID;
  final int? popularity;

  String codeImage([String color = '1DB954']) => makeCodeImage(uri, color);

  static LinkedTrack? _makeLinked(dynamic raw) {
    if (raw is! Map) return null;
    return LinkedTrack(
      externalURL: Map<String, String>.from(
          (raw['external_urls'] as Map?)?.cast<String, String>() ??
              const <String, String>{}),
      id: raw['id'] as String,
      type: raw['type'] as String? ?? 'track',
      uri: raw['uri'] as String,
    );
  }
}
