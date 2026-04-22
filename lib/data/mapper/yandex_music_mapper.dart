import '../../domain/model/album.dart';
import '../../domain/model/artist.dart';
import '../../domain/model/track.dart';
import '../../domain/model/track_source.dart';

class YandexMusicMapper {
  static String _coverUrl(String? coverUri, {String size = '400x400'}) {
    if (coverUri == null || coverUri.isEmpty) return '';
    final url = coverUri.replaceAll('%%', size);
    return url.startsWith('http') ? url : 'https://$url';
  }

  static Track toTrack(Map<String, dynamic> json) {
    final trackId = (json['id'] ?? json['realId'] ?? '').toString();
    final albums = json['albums'] as List?;
    Map<String, dynamic>? firstAlbum;
    if (albums != null && albums.isNotEmpty) {
      firstAlbum = albums.first as Map<String, dynamic>;
    }
    final albumId = firstAlbum?['id']?.toString();
    final composedId =
        albumId != null ? 'ym_$trackId:$albumId' : 'ym_$trackId';

    final artists = json['artists'] as List?;
    final firstArtist = (artists != null && artists.isNotEmpty)
        ? artists.first as Map<String, dynamic>
        : null;

    final durationMs = (json['durationMs'] as num?)?.toInt() ?? 0;
    final coverUri = json['coverUri'] as String? ??
        firstAlbum?['coverUri'] as String? ??
        firstArtist?['cover']?['uri'] as String?;
    final artworkUrl = coverUri != null ? _coverUrl(coverUri) : null;

    return Track(
      id: composedId,
      title: (json['title'] ?? '').toString(),
      artist: Artist(
        id: 'ym_${(firstArtist?['id'] ?? '').toString()}',
        name: (firstArtist?['name'] ?? 'Unknown').toString(),
        avatarUrl: firstArtist?['cover']?['uri'] != null
            ? _coverUrl(firstArtist!['cover']['uri'] as String?,
                size: '200x200')
            : null,
      ),
      album: firstAlbum != null
          ? Album(
              id: 'ym_${firstAlbum['id']}',
              title: (firstAlbum['title'] ?? '').toString(),
              artworkUrl: firstAlbum['coverUri'] != null
                  ? _coverUrl(firstAlbum['coverUri'] as String?)
                  : null,
            )
          : null,
      duration: Duration(milliseconds: durationMs),
      streamUrl: null,
      artworkUrl: artworkUrl,
      genre: firstAlbum?['genre'] as String?,
      source: TrackSource.yandex,
      isDownloadable: true,
      isExplicit: json['contentWarning'] == 'explicit',
    );
  }
}
