import 'common.dart';

/// Artist in the Yandex Music catalogue.
///
/// Matches the shape of `yandex_music.Artist`, preserving the raw JSON map
/// for fields the Dart port does not surface explicitly yet.
class YArtist {
  YArtist(Map<String, dynamic> data)
      : raw = data,
        id = data['id'] is int
            ? data['id'] as int
            : int.tryParse('${data['id']}') ?? 0,
        name = data['name'] as String? ?? '',
        various = data['various'] as bool? ?? false,
        composer = data['composer'] as bool? ?? false,
        available = data['available'] as bool? ?? true,
        cover = data['cover'] is Map
            ? Cover(Map<String, dynamic>.from(data['cover'] as Map))
            : null,
        ogImage = data['og_image'] as String?,
        genres = (data['genres'] as List?)?.whereType<String>().toList() ?? const [],
        counts = data['counts'] is Map
            ? Map<String, dynamic>.from(data['counts'] as Map)
            : const {},
        ratings = data['ratings'] is Map
            ? Map<String, dynamic>.from(data['ratings'] as Map)
            : const {},
        links = decodeMapList(data['links']),
        ticketsAvailable = data['tickets_available'] as bool? ?? false,
        likesCount = data['likes_count'] as int?,
        popularTracks = decodeMapList(data['popular_tracks']),
        regions = (data['regions'] as List?)?.whereType<String>().toList() ?? const [],
        decomposed = (data['decomposed'] as List?)?.toList() ?? const [],
        fullNames = (data['full_names'] as List?)?.whereType<String>().toList() ?? const [],
        disclaimers = (data['disclaimers'] as List?)?.whereType<String>().toList() ?? const [],
        initials = data['initials'] as String?,
        englishName = data['english_name'] as String?,
        description = data['description'] is Map
            ? Map<String, dynamic>.from(data['description'] as Map)
            : null,
        countries = (data['countries'] as List?)?.whereType<String>().toList() ?? const [],
        endDate = data['end_date'] as String?;

  final Map<String, dynamic> raw;
  final int id;
  final String name;
  final bool various;
  final bool composer;
  final bool available;
  final Cover? cover;
  final String? ogImage;
  final List<String> genres;
  final Map<String, dynamic> counts;
  final Map<String, dynamic> ratings;
  final List<Map<String, dynamic>> links;
  final bool ticketsAvailable;
  final int? likesCount;
  final List<Map<String, dynamic>> popularTracks;
  final List<String> regions;
  final List decomposed;
  final List<String> fullNames;
  final List<String> disclaimers;
  final String? initials;
  final String? englishName;
  final Map<String, dynamic>? description;
  final List<String> countries;
  final String? endDate;
}
