import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Keyless YouTube Music source backed by `youtube_explode_dart`.
///
/// No API key or user login is required. `youtube_explode_dart` talks to
/// the same InnerTube endpoints `music.youtube.com` uses, extracts and
/// deciphers stream URLs locally, so we get full-length audio for free.
class YouTubeMusicApi {
  final YoutubeExplode _yt;

  YouTubeMusicApi({YoutubeExplode? yt}) : _yt = yt ?? YoutubeExplode();

  /// Text search for tracks. Returns raw videos — mappers turn them into
  /// domain tracks.
  Future<List<Video>> searchTracks(String query, {int limit = 20}) async {
    try {
      final results = await _yt.search.search(query);
      return results.take(limit).toList();
    } catch (e) {
      debugPrint('YouTubeMusicApi.searchTracks failed: $e');
      return [];
    }
  }

  /// Returns a popular-music surrogate — YouTube doesn't expose a generic
  /// "trending" endpoint via InnerTube, so this returns a music-genre
  /// search that rotates with the calendar year.
  Future<List<Video>> getTrending({int limit = 20}) async {
    final now = DateTime.now();
    final queries = <String>[
      'top hits ${now.year}',
      'popular music ${now.year}',
      'trending music',
    ];
    for (final q in queries) {
      final items = await searchTracks(q, limit: limit);
      if (items.isNotEmpty) return items;
    }
    return [];
  }

  Future<List<Video>> searchByGenre(String genre, {int limit = 20}) =>
      searchTracks('$genre music', limit: limit);

  /// Metadata for one video.
  Future<Video?> getVideo(String videoId) async {
    try {
      return await _yt.videos.get(videoId);
    } catch (e) {
      debugPrint('YouTubeMusicApi.getVideo($videoId) failed: $e');
      return null;
    }
  }

  /// Resolves the best audio-only stream URL for a video. Picks the highest
  /// bitrate audio-only variant; falls back to the highest muxed stream if
  /// none exists.
  Future<String?> getStreamUrl(String videoId) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final audios = manifest.audioOnly;
      if (audios.isNotEmpty) {
        final best = audios.withHighestBitrate();
        return best.url.toString();
      }
      final muxed = manifest.muxed;
      if (muxed.isNotEmpty) {
        return muxed.withHighestBitrate().url.toString();
      }
      return null;
    } catch (e) {
      debugPrint('YouTubeMusicApi.getStreamUrl($videoId) failed: $e');
      return null;
    }
  }

  /// Fetches auto-generated or manual subtitles as plain text.
  /// Returns null when no English track exists.
  Future<String?> getLyrics(String videoId) async {
    try {
      final manifest = await _yt.videos.closedCaptions.getManifest(videoId);
      if (manifest.tracks.isEmpty) return null;
      final english = manifest.tracks.firstWhere(
        (t) => t.language.code.toLowerCase().startsWith('en'),
        orElse: () => manifest.tracks.first,
      );
      final track = await _yt.videos.closedCaptions.get(english);
      if (track.captions.isEmpty) return null;
      return track.captions.map((c) => c.text).join('\n');
    } catch (e) {
      debugPrint('YouTubeMusicApi.getLyrics($videoId) failed: $e');
      return null;
    }
  }

  void dispose() => _yt.close();
}
