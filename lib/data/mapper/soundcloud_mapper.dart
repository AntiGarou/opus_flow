import '../../domain/model/artist.dart';
import '../../domain/model/track.dart';
import '../../domain/model/track_source.dart';

class SoundCloudMapper {
  static Track toTrack(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final media = json['media'] as Map<String, dynamic>?;
    final transcodings = media?['transcodings'] as List?;

    String? streamUrl;
    if (transcodings != null) {
      Map<String, dynamic>? chosen;
      for (final raw in transcodings) {
        final t = raw as Map<String, dynamic>;
        final format = t['format'] as Map<String, dynamic>?;
        if (format != null &&
            (format['protocol'] == 'progressive') &&
            (format['mime_type']?.toString().contains('audio/mpeg') ?? false)) {
          chosen = t;
          break;
        }
      }
      chosen ??= transcodings.isNotEmpty
          ? transcodings.first as Map<String, dynamic>
          : null;
      streamUrl = chosen?['url'] as String?;
    }

    String? artworkUrl = json['artwork_url'] as String?;
    artworkUrl ??= user?['avatar_url'] as String?;
    if (artworkUrl != null) {
      artworkUrl = artworkUrl.replaceAll('-large', '-t500x500');
    }

    final id = (json['id'] ?? '').toString();
    final title = (json['title'] ?? '').toString();
    final durationMs = (json['duration'] ?? 0) as int;

    return Track(
      id: 'sc_$id',
      title: title,
      artist: Artist(
        id: 'sc_${(user?['id'] ?? '').toString()}',
        name: (user?['username'] ?? 'Unknown').toString(),
        avatarUrl: user?['avatar_url'] as String?,
      ),
      album: null,
      duration: Duration(milliseconds: durationMs),
      streamUrl: streamUrl,
      artworkUrl: artworkUrl,
      genre: json['genre'] as String?,
      source: TrackSource.soundcloud,
      isDownloadable: json['downloadable'] == true,
      isExplicit: false,
    );
  }
}
