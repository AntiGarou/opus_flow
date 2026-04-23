import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../data/api/soundcloud_api.dart';
import '../data/api/yandex_music_api.dart';
import '../data/api/youtube_music_api.dart';
import '../domain/model/playback_state.dart';
import '../domain/model/track.dart';
import '../domain/model/track_source.dart';
import 'download_service.dart';
import 'youtube_match_resolver.dart';

class AudioPlayerService {
  final AudioPlayer _player;
  final SoundCloudApi _soundCloudApi;
  final YandexMusicApi? _yandexMusicApi;
  final YouTubeMusicApi? _youTubeMusicApi;
  final YouTubeMatchResolver? _youTubeMatchResolver;
  final DownloadService? _downloadService;

  final StreamController<PlaybackState> _stateController =
      StreamController<PlaybackState>.broadcast();

  PlaybackState _state = const PlaybackState.empty();
  List<Track> _queue = [];
  int _queueIndex = 0;
  StreamSubscription<dynamic>? _playerStateSub;
  StreamSubscription<dynamic>? _positionSub;
  StreamSubscription<dynamic>? _durationSub;

  AudioPlayerService(
    this._soundCloudApi, {
    AudioPlayer? player,
    YandexMusicApi? yandexMusicApi,
    YouTubeMusicApi? youTubeMusicApi,
    YouTubeMatchResolver? youTubeMatchResolver,
    DownloadService? downloadService,
  })  : _player = player ?? AudioPlayer(),
        _yandexMusicApi = yandexMusicApi,
        _youTubeMusicApi = youTubeMusicApi,
        _youTubeMatchResolver = youTubeMatchResolver,
        _downloadService = downloadService {
    _listenToPlayer();
  }

  /// Raw, unthrottled playback state stream. The previous implementation
  /// debounced this by 200ms which caused visible jank in the scrubber and
  /// play/pause button. We now emit at native cadence — consumers that want
  /// lower rates should use BlocBuilder.buildWhen.
  Stream<PlaybackState> get stateStream => _stateController.stream;

  /// Convenience: direct position stream from just_audio (~100 Hz on Android
  /// for smooth seek bars). Use this in hot UI paths to avoid rebuilding the
  /// full PlayerCubit tree.
  Stream<Duration> get positionStream => _player.positionStream;

  PlaybackState get currentState => _state;

  void _listenToPlayer() {
    _playerStateSub = _player.playerStateStream.listen((s) {
      _state = _state.copyWith(isPlaying: s.playing);
      _emit();

      if (s.processingState == ProcessingState.completed) {
        _onCompleted();
      }
    });

    _positionSub = _player.positionStream.listen((p) {
      _state = _state.copyWith(position: p);
      _emit();
    });

    _durationSub = _player.durationStream.listen((d) {
      if (d != null) {
        _state = _state.copyWith(duration: d);
        _emit();
      }
    });
  }

  void _emit() {
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  Future<void> play(Track track) async {
    await playTracks([track], startIndex: 0);
  }

  Future<void> playTracks(List<Track> tracks, {int startIndex = 0}) async {
    if (tracks.isEmpty) return;
    _queue = List.of(tracks);
    _queueIndex = startIndex.clamp(0, tracks.length - 1);
    await _playCurrent();
  }

  Future<void> _playCurrent() async {
    if (_queue.isEmpty) return;
    final track = _queue[_queueIndex];
    final url = await _resolveStreamUrl(track);
    if (url == null) {
      debugPrint('AudioPlayerService: no stream URL for ${track.title}');
      return;
    }
    _state = _state.copyWith(
      currentTrack: track,
      queue: _queue,
      queueIndex: _queueIndex,
      position: Duration.zero,
    );
    _emit();
    try {
      if (url.startsWith('/') || url.startsWith('file:')) {
        await _player.setFilePath(
          url.startsWith('file:') ? Uri.parse(url).toFilePath() : url,
        );
      } else {
        await _player.setUrl(url);
      }
      await _player.play();
    } catch (e) {
      debugPrint('AudioPlayerService.setUrl failed: $e');
    }
  }

  Future<String?> _resolveStreamUrl(Track track) async {
    // Offline-first: if the track is downloaded locally, always play from disk.
    final local = await _downloadService?.localPath(track.id);
    if (local != null) return local;

    if (track.source == TrackSource.yandex) {
      final id = track.id.startsWith('ym_')
          ? track.id.substring(3).split(':').first
          : track.id;
      return _yandexMusicApi?.getTrackStreamUrl(id);
    }
    if (track.source == TrackSource.soundcloud &&
        track.streamUrl != null &&
        track.streamUrl!.contains('api-v2.soundcloud.com')) {
      return _soundCloudApi.resolveStreamUrl(track.streamUrl!);
    }
    if (track.source == TrackSource.youtube && _youTubeMusicApi != null) {
      final id = track.id.startsWith('yt_') ? track.id.substring(3) : track.id;
      return _youTubeMusicApi.getStreamUrl(id);
    }
    // Spotube-style fallback: Spotify and Deezer only expose ~30s previews via
    // their public APIs. When we have a YouTube client available, look up the
    // same song on YouTube and stream the full-length version instead.
    if ((track.source == TrackSource.spotify ||
            track.source == TrackSource.deezer) &&
        _youTubeMatchResolver != null) {
      final matched = await _youTubeMatchResolver.resolveStreamFor(track);
      if (matched != null && matched.isNotEmpty) return matched;
    }
    return track.streamUrl;
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.play();
  }

  Future<void> stop({bool clearQueue = false}) async {
    await _player.stop();
    if (clearQueue) {
      _queue = [];
      _queueIndex = 0;
      _state = const PlaybackState.empty();
    } else {
      _state = _state.copyWith(isPlaying: false, position: Duration.zero);
    }
    _emit();
  }

  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  Future<void> next() async {
    if (_queue.isEmpty) return;
    if (_queueIndex < _queue.length - 1) {
      _queueIndex++;
      await _playCurrent();
    } else if (_state.repeatMode == PlaybackRepeatMode.all) {
      _queueIndex = 0;
      await _playCurrent();
    } else {
      await stop();
    }
  }

  Future<void> previous() async {
    if (_queue.isEmpty) return;
    if (_state.position > const Duration(seconds: 3)) {
      await seekTo(Duration.zero);
      return;
    }
    if (_queueIndex > 0) {
      _queueIndex--;
      await _playCurrent();
    } else {
      await seekTo(Duration.zero);
    }
  }

  Future<void> setRepeatMode(PlaybackRepeatMode mode) async {
    _state = _state.copyWith(repeatMode: mode);
    final loop = switch (mode) {
      PlaybackRepeatMode.off => LoopMode.off,
      PlaybackRepeatMode.one => LoopMode.one,
      PlaybackRepeatMode.all => LoopMode.all,
    };
    await _player.setLoopMode(loop);
    _emit();
  }

  Future<void> setShuffle(bool enabled) async {
    _state = _state.copyWith(shuffleEnabled: enabled);
    await _player.setShuffleModeEnabled(enabled);
    _emit();
  }

  Future<void> _onCompleted() async {
    await next();
  }

  Future<void> dispose() async {
    await _playerStateSub?.cancel();
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _player.dispose();
    await _stateController.close();
  }
}
