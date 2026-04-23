import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/model/track.dart';
import '../../../services/download_service.dart';

class DownloadsState extends Equatable {
  final List<Track> tracks;
  final Map<String, DownloadProgress> inProgress;
  final String? lastError;

  const DownloadsState({
    this.tracks = const [],
    this.inProgress = const {},
    this.lastError,
  });

  DownloadsState copyWith({
    List<Track>? tracks,
    Map<String, DownloadProgress>? inProgress,
    String? lastError,
    bool clearLastError = false,
  }) {
    return DownloadsState(
      tracks: tracks ?? this.tracks,
      inProgress: inProgress ?? this.inProgress,
      lastError: clearLastError ? null : (lastError ?? this.lastError),
    );
  }

  bool isDownloaded(String trackId) => tracks.any((t) => t.id == trackId);

  bool isDownloading(String trackId) {
    final p = inProgress[trackId];
    return p != null && !p.done && !p.failed;
  }

  @override
  List<Object?> get props => [tracks, inProgress, lastError];
}

class DownloadsCubit extends Cubit<DownloadsState> {
  final DownloadService _service;
  StreamSubscription<DownloadProgress>? _sub;

  DownloadsCubit(this._service) : super(const DownloadsState()) {
    _sub = _service.progressStream.listen(_onProgress);
    refresh();
  }

  Future<void> refresh() async {
    final tracks = await _service.getDownloadedTracks();
    emit(state.copyWith(tracks: tracks));
  }

  Future<void> download(Track track) async {
    if (state.isDownloaded(track.id) || state.isDownloading(track.id)) return;
    final updated = Map<String, DownloadProgress>.from(state.inProgress);
    updated[track.id] = DownloadProgress(trackId: track.id);
    emit(state.copyWith(inProgress: updated));
    await _service.downloadTrack(track);
  }

  Future<void> cancel(String trackId) async {
    await _service.cancel(trackId);
    final updated = Map<String, DownloadProgress>.from(state.inProgress)
      ..remove(trackId);
    emit(state.copyWith(inProgress: updated));
  }

  Future<void> delete(String trackId) async {
    await _service.deleteDownload(trackId);
    await refresh();
  }

  void _onProgress(DownloadProgress p) {
    final updated = Map<String, DownloadProgress>.from(state.inProgress);
    if (p.done || p.failed) {
      updated.remove(p.trackId);
    } else {
      updated[p.trackId] = p;
    }
    if (p.failed) {
      emit(state.copyWith(inProgress: updated, lastError: 'Download failed'));
    } else if (p.done) {
      emit(state.copyWith(inProgress: updated, clearLastError: true));
      refresh();
    } else {
      emit(state.copyWith(inProgress: updated));
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
