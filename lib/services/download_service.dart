import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../data/api/soundcloud_api.dart';
import '../data/api/yandex_music_api.dart';
import '../data/api/youtube_music_api.dart';
import '../domain/model/album.dart';
import '../domain/model/artist.dart';
import '../domain/model/track.dart';
import '../domain/model/track_source.dart';

/// Represents the progress of a single download.
class DownloadProgress {
  final String trackId;
  final int received;
  final int total;
  final bool done;
  final bool failed;

  const DownloadProgress({
    required this.trackId,
    this.received = 0,
    this.total = 0,
    this.done = false,
    this.failed = false,
  });

  double get fraction => total > 0 ? received / total : 0;
}

/// Resolves a playable stream URL for a Track and persists downloads on disk.
///
/// Quality restrictions are removed — the highest-quality variant returned by
/// each backend is always used.
class DownloadService {
  final Dio _dio;
  final SoundCloudApi? _soundCloudApi;
  final YandexMusicApi? _yandexMusicApi;
  final YouTubeMusicApi? _youTubeMusicApi;

  final StreamController<DownloadProgress> _progressController =
      StreamController<DownloadProgress>.broadcast();

  final Map<String, CancelToken> _cancellers = {};

  DownloadService({
    Dio? dio,
    SoundCloudApi? soundCloudApi,
    YandexMusicApi? yandexMusicApi,
    YouTubeMusicApi? youTubeMusicApi,
  })  : _dio = dio ?? Dio(),
        _soundCloudApi = soundCloudApi,
        _yandexMusicApi = yandexMusicApi,
        _youTubeMusicApi = youTubeMusicApi;

  Stream<DownloadProgress> get progressStream => _progressController.stream;

  Future<Directory> _downloadsDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/downloads');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> _audioFile(String trackId) async {
    final dir = await _downloadsDir();
    final safeId = trackId.replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '_');
    return File('${dir.path}/$safeId.mp3');
  }

  Future<File> _metadataFile(String trackId) async {
    final dir = await _downloadsDir();
    final safeId = trackId.replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '_');
    return File('${dir.path}/$safeId.json');
  }

  Future<bool> isDownloaded(String trackId) async {
    final f = await _audioFile(trackId);
    return f.exists();
  }

  Future<String?> localPath(String trackId) async {
    final f = await _audioFile(trackId);
    if (await f.exists()) return f.path;
    return null;
  }

  /// Resolve a streamable URL for the given track. Mirrors the resolution
  /// logic used by AudioPlayerService so downloads always work when playback
  /// does.
  Future<String?> resolveStreamUrl(Track track) async {
    if (track.source == TrackSource.yandex && _yandexMusicApi != null) {
      final id = track.id.startsWith('ym_')
          ? track.id.substring(3).split(':').first
          : track.id;
      return _yandexMusicApi.getTrackStreamUrl(id);
    }
    if (track.source == TrackSource.soundcloud &&
        track.streamUrl != null &&
        track.streamUrl!.contains('api-v2.soundcloud.com') &&
        _soundCloudApi != null) {
      return _soundCloudApi.resolveStreamUrl(track.streamUrl!);
    }
    if (track.source == TrackSource.youtube && _youTubeMusicApi != null) {
      final id = track.id.startsWith('yt_') ? track.id.substring(3) : track.id;
      return _youTubeMusicApi.getStreamUrl(id);
    }
    return track.streamUrl;
  }

  Future<File?> downloadTrack(Track track) async {
    final file = await _audioFile(track.id);
    if (await file.exists()) {
      debugPrint('DownloadService: already downloaded ${track.id}');
      _progressController.add(DownloadProgress(
        trackId: track.id,
        received: 1,
        total: 1,
        done: true,
      ));
      return file;
    }

    final url = await resolveStreamUrl(track);
    if (url == null || url.isEmpty) {
      debugPrint('DownloadService: no stream URL for ${track.id}');
      _progressController.add(DownloadProgress(
        trackId: track.id,
        failed: true,
      ));
      return null;
    }

    final cancel = CancelToken();
    _cancellers[track.id] = cancel;
    try {
      await _dio.download(
        url,
        file.path,
        cancelToken: cancel,
        onReceiveProgress: (received, total) {
          _progressController.add(DownloadProgress(
            trackId: track.id,
            received: received,
            total: total,
          ));
        },
      );
      await _persistMetadata(track);
      _progressController.add(DownloadProgress(
        trackId: track.id,
        received: 1,
        total: 1,
        done: true,
      ));
      return file;
    } catch (e) {
      debugPrint('DownloadService.downloadTrack failed: $e');
      if (await file.exists()) {
        await file.delete();
      }
      _progressController.add(DownloadProgress(
        trackId: track.id,
        failed: true,
      ));
      return null;
    } finally {
      _cancellers.remove(track.id);
    }
  }

  Future<void> cancel(String trackId) async {
    _cancellers[trackId]?.cancel('user_cancelled');
  }

  Future<void> _persistMetadata(Track track) async {
    final f = await _metadataFile(track.id);
    await f.writeAsString(jsonEncode({
      'id': track.id,
      'title': track.title,
      'artist': track.artist.name,
      'artistId': track.artist.id,
      'album': track.album?.title,
      'artworkUrl': track.artworkUrl,
      'source': track.source,
      'durationMs': track.duration.inMilliseconds,
      'genre': track.genre,
      'isExplicit': track.isExplicit,
    }));
  }

  Future<List<Track>> getDownloadedTracks() async {
    final dir = await _downloadsDir();
    if (!await dir.exists()) return [];
    final audioFiles = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.mp3'));
    final tracks = <Track>[];
    for (final audio in audioFiles) {
      final name = audio.uri.pathSegments.last.replaceAll(
          RegExp(r'\.mp3$'), '');
      final metaFile = File('${dir.path}/$name.json');
      final t = await _loadMetadata(metaFile, audio);
      tracks.add(t);
    }
    tracks.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return tracks;
  }

  Future<Track> _loadMetadata(File metaFile, File audioFile) async {
    try {
      if (await metaFile.exists()) {
        final raw = await metaFile.readAsString();
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final albumTitle = map['album'] as String?;
        final artworkUrl = map['artworkUrl'] as String?;
        return Track(
          id: (map['id'] ?? '').toString(),
          title: (map['title'] ?? '').toString(),
          artist: Artist(
            id: (map['artistId'] ?? 'unknown').toString(),
            name: (map['artist'] ?? 'Unknown').toString(),
          ),
          album: albumTitle != null
              ? Album(
                  id: 'dl_${map['id']}',
                  title: albumTitle,
                  artworkUrl: artworkUrl,
                )
              : null,
          duration: Duration(
              milliseconds: (map['durationMs'] as num?)?.toInt() ?? 0),
          streamUrl: audioFile.path,
          artworkUrl: artworkUrl,
          genre: map['genre'] as String?,
          source: (map['source'] ?? TrackSource.local).toString(),
          isDownloadable: true,
          isExplicit: map['isExplicit'] == true,
        );
      }
    } catch (e) {
      debugPrint('DownloadService._loadMetadata failed: $e');
    }
    final name = audioFile.uri.pathSegments.last
        .replaceAll(RegExp(r'\.mp3$'), '');
    return Track(
      id: name,
      title: name,
      artist: const Artist(id: 'local', name: 'Local'),
      streamUrl: audioFile.path,
      source: TrackSource.local,
      isDownloadable: true,
    );
  }

  Future<bool> deleteDownload(String trackId) async {
    final audio = await _audioFile(trackId);
    final meta = await _metadataFile(trackId);
    var deleted = false;
    if (await audio.exists()) {
      await audio.delete();
      deleted = true;
    }
    if (await meta.exists()) {
      await meta.delete();
    }
    return deleted;
  }

  Future<void> dispose() async {
    for (final c in _cancellers.values) {
      c.cancel('dispose');
    }
    _cancellers.clear();
    await _progressController.close();
  }

}
