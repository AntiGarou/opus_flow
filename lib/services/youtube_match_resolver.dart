import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

import '../data/api/youtube_music_api.dart';
import '../domain/model/track.dart';

/// Resolves a full-length stream URL for a track whose native source only
/// provides short previews (Spotify ~30 s, Deezer ~30 s) by looking up the
/// same song on YouTube.
///
/// This is the "Spotube trick": show the Spotify/Deezer catalog, but play
/// the audio from YouTube so users get the full track without Premium.
class YouTubeMatchResolver {
  final YouTubeMusicApi _youTubeMusicApi;

  /// Session cache: track.id -> resolved YouTube videoId. Avoids re-searching
  /// the same preview-source track on every play.
  final Map<String, String> _matchCache = {};

  YouTubeMatchResolver(this._youTubeMusicApi);

  /// Returns a full-length stream URL or null if no suitable match is found.
  Future<String?> resolveStreamFor(Track track) async {
    final cachedId = _matchCache[track.id];
    if (cachedId != null) {
      final url = await _youTubeMusicApi.getStreamUrl(cachedId);
      if (url != null && url.isNotEmpty) return url;
      _matchCache.remove(track.id);
    }

    final video = await _findMatch(track);
    if (video == null) return null;
    _matchCache[track.id] = video.id.value;

    final url = await _youTubeMusicApi.getStreamUrl(video.id.value);
    if (url != null && url.isNotEmpty) {
      debugPrint(
          'YouTubeMatchResolver matched "${track.title}" → ${video.id.value}');
    }
    return url;
  }

  Future<yt.Video?> _findMatch(Track track) async {
    final artist = track.artist.name.trim();
    final queries = <String>[
      if (artist.isNotEmpty) '${track.title} $artist audio',
      if (artist.isNotEmpty) '${track.title} $artist',
      track.title,
    ];

    for (final q in queries) {
      final results = await _youTubeMusicApi.searchTracks(q, limit: 5);
      if (results.isEmpty) continue;
      final best = _pickBest(track, results);
      if (best != null) return best;
    }
    return null;
  }

  /// Pick the candidate whose duration is closest to the source track's
  /// duration (within ±15 s) and whose title/artist words overlap with the
  /// source. Falls back to the first candidate if no track has a known
  /// duration.
  yt.Video? _pickBest(Track track, List<yt.Video> candidates) {
    final srcTitleTokens = _tokens(track.title);
    final srcArtistTokens = _tokens(track.artist.name);
    final srcDuration = track.duration;

    yt.Video? best;
    int bestScore = -1;
    for (final v in candidates) {
      final title = _tokens(v.title);
      final channel = _tokens(v.author);
      var score = 0;
      score += title.intersection(srcTitleTokens).length * 4;
      score += channel.intersection(srcArtistTokens).length * 3;

      final vd = v.duration;
      if (vd != null && srcDuration > Duration.zero) {
        final delta = (vd.inSeconds - srcDuration.inSeconds).abs();
        if (delta <= 15) {
          score += 5;
        } else if (delta <= 30) {
          score += 2;
        }
      }

      // Penalise covers/karaoke/8-bit/slowed variants when the source track
      // wasn't explicitly one of those.
      final lowerTitle = v.title.toLowerCase();
      for (final bad in const ['karaoke', 'cover by', '8-bit', 'slowed']) {
        if (lowerTitle.contains(bad) &&
            !track.title.toLowerCase().contains(bad)) {
          score -= 5;
        }
      }

      if (score > bestScore) {
        bestScore = score;
        best = v;
      }
    }
    return best ?? candidates.first;
  }

  Set<String> _tokens(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 1)
        .toSet();
  }
}
