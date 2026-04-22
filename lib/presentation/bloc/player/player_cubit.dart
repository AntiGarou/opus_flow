import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/model/playback_state.dart';
import '../../../domain/model/track.dart';
import '../../../services/audio_player_service.dart';

class PlayerCubit extends Cubit<PlaybackState> {
  final AudioPlayerService _service;
  StreamSubscription<PlaybackState>? _sub;

  PlayerCubit(this._service) : super(const PlaybackState.empty()) {
    _sub = _service.stateStream.listen(emit);
  }

  Future<void> play(Track track) => _service.play(track);

  Future<void> playTracks(List<Track> tracks, {int startIndex = 0}) =>
      _service.playTracks(tracks, startIndex: startIndex);

  Future<void> pause() => _service.pause();

  Future<void> resume() => _service.resume();

  Future<void> stop({bool clearQueue = false}) =>
      _service.stop(clearQueue: clearQueue);

  Future<void> next() => _service.next();

  Future<void> previous() => _service.previous();

  Future<void> seekTo(Duration position) => _service.seekTo(position);

  Future<void> setRepeatMode(PlaybackRepeatMode mode) =>
      _service.setRepeatMode(mode);

  Future<void> setShuffle(bool enabled) => _service.setShuffle(enabled);

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
