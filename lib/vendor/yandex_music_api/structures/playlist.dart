import 'common.dart';
import 'track.dart';
import 'user.dart';

/// Track inside a playlist (wrapper around a Track + metadata).
class YPlaylistTrack {
  YPlaylistTrack(Map<String, dynamic> data)
      : id = '${data['id'] ?? ''}',
        albumId = data['album_id']?.toString(),
        playCount = data['play_count'] as int?,
        recent = data['recent'] as bool? ?? false,
        timestamp = data['timestamp'] as String?,
        originalIndex = data['original_index'] as int?,
        track = data['track'] is Map
            ? YTrack(Map<String, dynamic>.from(data['track'] as Map))
            : null;

  final String id;
  final String? albumId;
  final int? playCount;
  final bool recent;
  final String? timestamp;
  final int? originalIndex;
  final YTrack? track;
}

/// User-owned or official playlist.
class YPlaylist {
  YPlaylist(Map<String, dynamic> data)
      : raw = data,
        owner = data['owner'] is Map
            ? YUser(Map<String, dynamic>.from(data['owner'] as Map))
            : null,
        cover = data['cover'] is Map
            ? Cover(Map<String, dynamic>.from(data['cover'] as Map))
            : null,
        made = data['made'] as bool? ?? false,
        playlistUuid = data['playlist_uuid'] as String?,
        uid = data['uid']?.toString(),
        kind = (data['kind'] as num?)?.toInt(),
        title = data['title'] as String? ?? '',
        description = data['description'] as String?,
        descriptionFormatted = data['description_formatted'] as String?,
        trackCount = data['track_count'] as int?,
        visibility = data['visibility'] as String?,
        collective = data['collective'] as bool? ?? false,
        urlPart = data['url_part'] as String?,
        created = data['created'] as String?,
        modified = data['modified'] as String?,
        revision = (data['revision'] as num?)?.toInt(),
        snapshot = (data['snapshot'] as num?)?.toInt(),
        durationMs = (data['duration_ms'] as num?)?.toInt(),
        isBanner = data['is_banner'] as bool? ?? false,
        isPremiere = data['is_premiere'] as bool? ?? false,
        everPlayed = data['ever_played'] as bool? ?? false,
        likesCount = data['likes_count'] as int?,
        ogImage = data['og_image'] as String?,
        tags = (data['tags'] as List?)?.toList() ?? const [],
        prerolls = decodeMapList(data['prerolls']),
        tracks = (data['tracks'] as List?)
                ?.whereType<Map>()
                .map((t) => YPlaylistTrack(Map<String, dynamic>.from(t)))
                .toList() ??
            const [],
        originalTracks = decodeMapList(data['original_tracks']),
        available = data['available'] as bool? ?? true,
        generatedPlaylistType = data['generated_playlist_type'] as String?;

  final Map<String, dynamic> raw;
  final YUser? owner;
  final Cover? cover;
  final bool made;
  final String? playlistUuid;
  final String? uid;
  final int? kind;
  final String title;
  final String? description;
  final String? descriptionFormatted;
  final int? trackCount;
  final String? visibility;
  final bool collective;
  final String? urlPart;
  final String? created;
  final String? modified;
  final int? revision;
  final int? snapshot;
  final int? durationMs;
  final bool isBanner;
  final bool isPremiere;
  final bool everPlayed;
  final int? likesCount;
  final String? ogImage;
  final List tags;
  final List<Map<String, dynamic>> prerolls;
  final List<YPlaylistTrack> tracks;
  final List<Map<String, dynamic>> originalTracks;
  final bool available;
  final String? generatedPlaylistType;

  String get playlistId =>
      uid != null && kind != null ? '$uid:$kind' : playlistUuid ?? '';
}
