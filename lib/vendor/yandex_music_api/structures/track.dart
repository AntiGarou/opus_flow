import 'artist.dart';
import 'common.dart';

/// Track in the Yandex Music catalogue.
///
/// Keeps the full raw JSON in [raw] for fields the Dart port does not model.
class YTrack {
  YTrack(Map<String, dynamic> data)
      : raw = data,
        id = '${data['id'] ?? ''}',
        realId = data['real_id']?.toString(),
        title = data['title'] as String? ?? '',
        version = data['version'] as String?,
        available = data['available'] as bool? ?? true,
        availableForPremiumUsers =
            data['available_for_premium_users'] as bool? ?? false,
        availableFullWithoutPermission =
            data['available_full_without_permission'] as bool? ?? false,
        durationMs = (data['duration_ms'] as num?)?.toInt() ?? 0,
        explicit = data['explicit'] as bool? ?? false,
        contentWarning = data['content_warning'] as String?,
        storageDir = data['storage_dir'] as String?,
        fileSize = (data['file_size'] as num?)?.toInt(),
        previewDurationMs = (data['preview_duration_ms'] as num?)?.toInt(),
        lyricsAvailable = data['lyrics_available'] as bool? ?? false,
        lyricsInfo = data['lyrics_info'] is Map
            ? Map<String, dynamic>.from(data['lyrics_info'] as Map)
            : null,
        rememberPosition = data['remember_position'] as bool? ?? false,
        trackSharingFlag = data['track_sharing_flag'] as String?,
        ogImage = data['og_image'] as String?,
        coverUri = data['cover_uri'] as String?,
        type = data['type'] as String?,
        regions = (data['regions'] as List?)?.whereType<String>().toList() ?? const [],
        albums = (data['albums'] as List?)
                ?.whereType<Map>()
                .map((a) => Map<String, dynamic>.from(a))
                .toList() ??
            const [],
        artists = (data['artists'] as List?)
                ?.whereType<Map>()
                .map((a) => YArtist(Map<String, dynamic>.from(a)))
                .toList() ??
            const [],
        major = data['major'] is Map
            ? Map<String, dynamic>.from(data['major'] as Map)
            : null,
        normalization = data['normalization'] is Map
            ? Map<String, dynamic>.from(data['normalization'] as Map)
            : null,
        userLikes = data['user_likes'] as bool?,
        substituted = data['substituted'] is Map
            ? Map<String, dynamic>.from(data['substituted'] as Map)
            : null,
        matchedTrack = data['matched_track'] is Map
            ? Map<String, dynamic>.from(data['matched_track'] as Map)
            : null,
        poetryLoverMatches = decodeMapList(data['poetry_lover_matches']);

  final Map<String, dynamic> raw;
  final String id;
  final String? realId;
  final String title;
  final String? version;
  final bool available;
  final bool availableForPremiumUsers;
  final bool availableFullWithoutPermission;
  final int durationMs;
  final bool explicit;
  final String? contentWarning;
  final String? storageDir;
  final int? fileSize;
  final int? previewDurationMs;
  final bool lyricsAvailable;
  final Map<String, dynamic>? lyricsInfo;
  final bool rememberPosition;
  final String? trackSharingFlag;
  final String? ogImage;
  final String? coverUri;
  final String? type;
  final List<String> regions;
  final List<Map<String, dynamic>> albums;
  final List<YArtist> artists;
  final Map<String, dynamic>? major;
  final Map<String, dynamic>? normalization;
  final bool? userLikes;
  final Map<String, dynamic>? substituted;
  final Map<String, dynamic>? matchedTrack;
  final List<Map<String, dynamic>> poetryLoverMatches;

  String? coverUrl([String size = '200x200']) {
    if (coverUri == null) return null;
    final u = coverUri!.replaceAll('%%', size);
    return u.startsWith('http') ? u : 'https://$u';
  }
}
