import '../util.dart';
import 'artist.dart';
import 'track.dart';

/// Spotify api's album object.
/// Dart port of spotify-api.js `structures/Album.ts`.
class Album {
  Album(Map<String, dynamic> data)
      : albumType = data['album_type'] as String? ?? 'album',
        albumGroup = data['album_group'] as String?,
        artists = ((data['artists'] as List?) ?? const [])
            .map((a) => Artist(Map<String, dynamic>.from(a as Map)))
            .toList(),
        availableMarkets = (data['available_markets'] as List?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        externalURL = Map<String, String>.from(
            (data['external_urls'] as Map?)?.cast<String, String>() ??
                const <String, String>{}),
        id = data['id'] as String,
        images = (data['images'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
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
        totalTracks = data['total_tracks'] as int? ?? 0,
        type = data['type'] as String? ?? 'album',
        uri = data['uri'] as String,
        copyrights = (data['copyrights'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
        externalID = (data['external_ids'] as Map?)?.cast<String, String>(),
        genres =
            (data['genres'] as List?)?.map((e) => e as String).toList(),
        label = data['label'] as String?,
        popularity = data['popularity'] as int?,
        tracks = _extractTracks(data['tracks']);

  final String albumType;
  final String? albumGroup;
  final List<Artist> artists;
  final List<String> availableMarkets;
  final Map<String, String> externalURL;
  final String id;
  final List<Map<String, dynamic>> images;
  final String name;
  final String releaseDate;
  final String releaseDatePrecision;
  final List<Map<String, dynamic>> restrictions;
  final int totalTracks;
  final String type;
  final String uri;
  final List<Map<String, dynamic>>? copyrights;
  final Map<String, String>? externalID;
  final List<String>? genres;
  final String? label;
  final int? popularity;
  final List<Track>? tracks;

  String codeImage([String color = '1DB954']) => makeCodeImage(uri, color);

  static List<Track>? _extractTracks(dynamic raw) {
    if (raw == null) return null;
    final list = raw is List
        ? raw
        : raw is Map && raw['items'] is List
            ? raw['items'] as List
            : null;
    if (list == null) return null;
    return list
        .map((t) => Track(Map<String, dynamic>.from(t as Map)))
        .toList();
  }
}
