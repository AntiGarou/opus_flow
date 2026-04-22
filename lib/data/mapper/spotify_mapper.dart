import '../../domain/model/album.dart';
import '../../domain/model/artist.dart';
import '../../domain/model/track.dart';
import '../../domain/model/track_source.dart';

class SpotifyMapper {
  static Track? toTrack(Map<String, dynamic> json) {
    var track = json;
    if (json['track'] is Map<String, dynamic>) {
      track = json['track'] as Map<String, dynamic>;
    }
    if (track['id'] == null) return null;

    final id = (track['id'] ?? '').toString();
    final title = (track['name'] ?? '').toString();
    final durationMs = (track['duration_ms'] as num?)?.toInt() ?? 0;

    final artists = track['artists'] as List?;
    final firstArtist = (artists != null && artists.isNotEmpty)
        ? artists.first as Map<String, dynamic>
        : null;

    final albumData = track['album'] as Map<String, dynamic>?;
    final images = albumData?['images'] as List?;
    String? artworkUrl;
    if (images != null && images.isNotEmpty) {
      final idx = images.length > 1 ? 1 : 0;
      artworkUrl = (images[idx] as Map<String, dynamic>)['url'] as String?;
    }

    return Track(
      id: 'sp_$id',
      title: title,
      artist: Artist(
        id: 'sp_${(firstArtist?['id'] ?? '').toString()}',
        name: (firstArtist?['name'] ?? 'Unknown').toString(),
      ),
      album: albumData != null
          ? Album(
              id: 'sp_${(albumData['id'] ?? '').toString()}',
              title: (albumData['name'] ?? '').toString(),
              artworkUrl: artworkUrl,
            )
          : null,
      duration: Duration(milliseconds: durationMs),
      streamUrl: track['preview_url'] as String?,
      artworkUrl: artworkUrl,
      genre: null,
      source: TrackSource.spotify,
      isDownloadable: false,
      isExplicit: track['explicit'] == true,
    );
  }
}
