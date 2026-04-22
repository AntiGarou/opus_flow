import 'artist.dart';
import 'common.dart';
import 'track.dart';

/// Album in the Yandex Music catalogue.
class YAlbum {
  YAlbum(Map<String, dynamic> data)
      : raw = data,
        id = data['id'] is int
            ? data['id'] as int
            : int.tryParse('${data['id']}') ?? 0,
        title = data['title'] as String? ?? '',
        type = data['type'] as String?,
        metaType = data['meta_type'] as String?,
        year = data['year'] as int?,
        releaseDate = data['release_date'] as String?,
        coverUri = data['cover_uri'] as String?,
        ogImage = data['og_image'] as String?,
        genre = data['genre'] as String?,
        trackCount = data['track_count'] as int?,
        likesCount = data['likes_count'] as int?,
        recent = data['recent'] as bool? ?? false,
        veryImportant = data['very_important'] as bool? ?? false,
        available = data['available'] as bool? ?? true,
        availableForPremiumUsers =
            data['available_for_premium_users'] as bool? ?? false,
        availableForMobile = data['available_for_mobile'] as bool? ?? true,
        availablePartially = data['available_partially'] as bool? ?? false,
        bests = decodeIntList(data['bests']),
        prerolls = decodeMapList(data['prerolls']),
        volumes = _extractVolumes(data['volumes']),
        artists = (data['artists'] as List?)
                ?.whereType<Map>()
                .map((a) => YArtist(Map<String, dynamic>.from(a)))
                .toList() ??
            const [],
        labels = decodeMapList(data['labels']),
        shortDescription = data['short_description'] as String?,
        description = data['description'] as String?,
        isPremiere = data['is_premiere'] as bool? ?? false,
        isBanner = data['is_banner'] as bool? ?? false,
        contentWarning = data['content_warning'] as String?,
        buy = (data['buy'] as List?)?.toList() ?? const [],
        sortOrder = data['sort_order'] as String?,
        trackPosition = data['track_position'] is Map
            ? Map<String, dynamic>.from(data['track_position'] as Map)
            : null;

  final Map<String, dynamic> raw;
  final int id;
  final String title;
  final String? type;
  final String? metaType;
  final int? year;
  final String? releaseDate;
  final String? coverUri;
  final String? ogImage;
  final String? genre;
  final int? trackCount;
  final int? likesCount;
  final bool recent;
  final bool veryImportant;
  final bool available;
  final bool availableForPremiumUsers;
  final bool availableForMobile;
  final bool availablePartially;
  final List<int> bests;
  final List<Map<String, dynamic>> prerolls;
  final List<List<YTrack>> volumes;
  final List<YArtist> artists;
  final List<Map<String, dynamic>> labels;
  final String? shortDescription;
  final String? description;
  final bool isPremiere;
  final bool isBanner;
  final String? contentWarning;
  final List buy;
  final String? sortOrder;
  final Map<String, dynamic>? trackPosition;

  String? coverUrl([String size = '200x200']) {
    if (coverUri == null) return null;
    final u = coverUri!.replaceAll('%%', size);
    return u.startsWith('http') ? u : 'https://$u';
  }

  static List<List<YTrack>> _extractVolumes(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((vol) {
      if (vol is! List) return <YTrack>[];
      return vol
          .whereType<Map>()
          .map((t) => YTrack(Map<String, dynamic>.from(t)))
          .toList();
    }).toList();
  }
}
