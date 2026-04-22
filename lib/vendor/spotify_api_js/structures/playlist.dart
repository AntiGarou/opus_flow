import '../interface.dart';
import '../util.dart';
import 'episode.dart';
import 'track.dart';
import 'user.dart';

/// Spotify api's playlist object.
/// Dart port of spotify-api.js `structures/Playlist.ts`.
class Playlist {
  Playlist(Map<String, dynamic> data)
      : collaborative = data['collaborative'] as bool? ?? false,
        description = data['description'] as String?,
        externalURL = Map<String, String>.from(
            (data['external_urls'] as Map?)?.cast<String, String>() ??
                const <String, String>{}),
        id = data['id'] as String,
        images = (data['images'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            const [],
        name = data['name'] as String,
        owner = User(Map<String, dynamic>.from(data['owner'] as Map)),
        snapshotID = data['snapshot_id'] as String? ?? '',
        totalTracks = _totalTracks(data['tracks']),
        uri = data['uri'] as String,
        type = data['type'] as String? ?? 'playlist',
        isPublic = data['public'] as bool?,
        totalFollowers = (data['followers'] as Map?)?['total'] as int?,
        tracks = _extractTracks(data['tracks']);

  final bool collaborative;
  final String? description;
  final Map<String, String> externalURL;
  final String id;
  final List<Map<String, dynamic>> images;
  final String name;
  final User owner;
  final String snapshotID;
  final int totalTracks;
  final String uri;
  final String type;
  final bool? isPublic;
  final int? totalFollowers;
  final List<PlaylistTrack>? tracks;

  String codeImage([String color = '1DB954']) => makeCodeImage(uri, color);

  static int _totalTracks(dynamic raw) {
    if (raw is List) return raw.length;
    if (raw is Map) return raw['total'] as int? ?? 0;
    return 0;
  }

  static List<PlaylistTrack>? _extractTracks(dynamic raw) {
    if (raw is Map && raw['items'] is List) {
      return createPlaylistTracks(raw['items'] as List);
    }
    if (raw is List) return createPlaylistTracks(raw);
    return null;
  }
}

/// Maps raw playlist-tracks into [PlaylistTrack] objects.
List<PlaylistTrack> createPlaylistTracks(List rawPlaylistTracks) {
  return rawPlaylistTracks.map((raw) {
    final m = Map<String, dynamic>.from(raw as Map);
    final trackData = m['track'];
    Object? track;
    if (trackData is Map) {
      final t = Map<String, dynamic>.from(trackData);
      track = t['type'] == 'episode' ? Episode(t) : Track(t);
    }
    return PlaylistTrack(
      addedAt: m['added_at'] as String?,
      addedBy: m['added_by'] is Map
          ? User(Map<String, dynamic>.from(m['added_by'] as Map))
          : null,
      isLocal: m['is_local'] as bool? ?? false,
      track: track,
    );
  }).toList();
}
