import '../../domain/model/album.dart';
import '../../domain/model/artist.dart';
import '../../domain/model/track.dart';
import '../../domain/model/track_source.dart';

class JamendoMapper {
  static Track toTrack(Map<String, dynamic> json) {
    final id = (json['id'] ?? '').toString();
    final title = (json['name'] ?? json['title'] ?? '').toString();
    final durationSec = (json['duration'] as num?)?.toInt() ?? 0;

    final tags = (json['musicinfo']?['tags'] as Map?)?.cast<String, dynamic>();
    String? genre;
    final genres = tags?['genres'] as List?;
    if (genres != null && genres.isNotEmpty) {
      genre = genres.first.toString();
    }

    return Track(
      id: 'jm_$id',
      title: title,
      artist: Artist(
        id: 'jm_${(json['artist_id'] ?? '').toString()}',
        name: (json['artist_name'] ?? 'Unknown').toString(),
      ),
      album: json['album_name'] != null
          ? Album(
              id: 'jm_${(json['album_id'] ?? '').toString()}',
              title: json['album_name'].toString(),
              artworkUrl: json['album_image'] as String?,
            )
          : null,
      duration: Duration(seconds: durationSec),
      streamUrl: json['audio'] as String?,
      artworkUrl: (json['image'] ?? json['album_image']) as String?,
      genre: genre,
      source: TrackSource.jamendo,
      isDownloadable: true,
    );
  }
}
