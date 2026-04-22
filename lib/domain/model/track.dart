import 'package:equatable/equatable.dart';

import 'album.dart';
import 'artist.dart';

class Track extends Equatable {
  final String id;
  final String title;
  final Artist artist;
  final Album? album;
  final Duration duration;
  final String? streamUrl;
  final String? artworkUrl;
  final String? genre;
  final String source;
  final bool isDownloadable;
  final bool isFavorite;
  final bool isExplicit;
  final String? videoUrl;

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.duration = Duration.zero,
    this.streamUrl,
    this.artworkUrl,
    this.genre,
    required this.source,
    this.isDownloadable = false,
    this.isFavorite = false,
    this.isExplicit = false,
    this.videoUrl,
  });

  Track copyWith({
    String? id,
    String? title,
    Artist? artist,
    Album? album,
    Duration? duration,
    String? streamUrl,
    String? artworkUrl,
    String? genre,
    String? source,
    bool? isDownloadable,
    bool? isFavorite,
    bool? isExplicit,
    String? videoUrl,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      streamUrl: streamUrl ?? this.streamUrl,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      genre: genre ?? this.genre,
      source: source ?? this.source,
      isDownloadable: isDownloadable ?? this.isDownloadable,
      isFavorite: isFavorite ?? this.isFavorite,
      isExplicit: isExplicit ?? this.isExplicit,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        artist,
        album,
        duration,
        streamUrl,
        artworkUrl,
        genre,
        source,
        isDownloadable,
        isFavorite,
        isExplicit,
        videoUrl,
      ];
}
