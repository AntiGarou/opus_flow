import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

import '../../domain/model/album.dart';
import '../../domain/model/artist.dart';
import '../../domain/model/track.dart';
import '../../domain/model/track_source.dart';

class YouTubeMusicMapper {
  static Track toTrack(yt.Video video) {
    final thumb = video.thumbnails.highResUrl;
    final channel = video.author;
    return Track(
      id: 'yt_${video.id.value}',
      title: video.title,
      artist: Artist(
        id: 'yt_channel_${video.channelId.value}',
        name: channel,
      ),
      album: Album(
        id: 'yt_${video.id.value}',
        title: video.title,
        artworkUrl: thumb,
      ),
      duration: video.duration ?? Duration.zero,
      source: TrackSource.youtube,
      artworkUrl: thumb,
      isDownloadable: true,
    );
  }
}
