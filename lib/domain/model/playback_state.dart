import 'package:equatable/equatable.dart';

import 'track.dart';

enum PlaybackRepeatMode { off, one, all }

class PlaybackState extends Equatable {
  final Track? currentTrack;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final PlaybackRepeatMode repeatMode;
  final bool shuffleEnabled;
  final List<Track> queue;
  final int queueIndex;

  const PlaybackState({
    this.currentTrack,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.repeatMode = PlaybackRepeatMode.off,
    this.shuffleEnabled = false,
    this.queue = const [],
    this.queueIndex = 0,
  });

  const PlaybackState.empty()
      : currentTrack = null,
        isPlaying = false,
        position = Duration.zero,
        duration = Duration.zero,
        repeatMode = PlaybackRepeatMode.off,
        shuffleEnabled = false,
        queue = const [],
        queueIndex = 0;

  PlaybackState copyWith({
    Track? currentTrack,
    bool clearCurrentTrack = false,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    PlaybackRepeatMode? repeatMode,
    bool? shuffleEnabled,
    List<Track>? queue,
    int? queueIndex,
  }) {
    return PlaybackState(
      currentTrack:
          clearCurrentTrack ? null : (currentTrack ?? this.currentTrack),
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      repeatMode: repeatMode ?? this.repeatMode,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      queue: queue ?? this.queue,
      queueIndex: queueIndex ?? this.queueIndex,
    );
  }

  @override
  List<Object?> get props => [
        currentTrack,
        isPlaying,
        position,
        duration,
        repeatMode,
        shuffleEnabled,
        queue,
        queueIndex,
      ];
}
