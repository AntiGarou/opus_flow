import '../../domain/model/album.dart';
import '../../domain/model/artist.dart';
import '../../domain/model/track.dart';
import '../../domain/model/track_source.dart';

class DeezerMapper {
  static Track toTrack(Map<String, dynamic> json) {
    final artistData = json['artist'] as Map<String, dynamic>?;
    final albumData = json['album'] as Map<String, dynamic>?;
    final id = (json['id'] ?? '').toString();
    final title = (json['title'] ?? '').toString();
    final durationSec = (json['duration'] as num?)?.toInt() ?? 0;

    return Track(
      id: 'dz_$id',
      title: title,
      artist: Artist(
        id: 'dz_${(artistData?['id'] ?? '').toString()}',
        name: (artistData?['name'] ?? 'Unknown').toString(),
        avatarUrl: artistData?['picture_medium'] as String?,
      ),
      album: albumData != null
          ? Album(
              id: 'dz_${(albumData['id'] ?? '').toString()}',
              title: (albumData['title'] ?? '').toString(),
              artworkUrl: (albumData['cover_medium'] ??
                      albumData['cover_big'] ??
                      albumData['cover']) as String?,
            )
          : null,
      duration: Duration(seconds: durationSec),
      streamUrl: json['preview'] as String?,
      artworkUrl: (albumData?['cover_big'] ??
          albumData?['cover_medium'] ??
          albumData?['cover']) as String?,
      genre: null,
      source: TrackSource.deezer,
      isDownloadable: false,
      isExplicit: json['explicit_lyrics'] == true,
    );
  }
}
