import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/preferences/playlist_storage.dart';
import '../../../domain/model/playlist.dart';
import '../../../domain/model/track.dart';

class LibraryState extends Equatable {
  final int selectedTab;
  final List<Playlist> playlists;
  final List<Track> favorites;

  const LibraryState({
    this.selectedTab = 0,
    this.playlists = const [],
    this.favorites = const [],
  });

  LibraryState copyWith({
    int? selectedTab,
    List<Playlist>? playlists,
    List<Track>? favorites,
  }) {
    return LibraryState(
      selectedTab: selectedTab ?? this.selectedTab,
      playlists: playlists ?? this.playlists,
      favorites: favorites ?? this.favorites,
    );
  }

  @override
  List<Object?> get props => [selectedTab, playlists, favorites];
}

class LibraryCubit extends Cubit<LibraryState> {
  final PlaylistStorage _storage;

  LibraryCubit(this._storage) : super(const LibraryState()) {
    _load();
  }

  Future<void> _load() async {
    final playlists = await _storage.getPlaylists();
    final favorites = await _storage.getFavorites();
    emit(state.copyWith(playlists: playlists, favorites: favorites));
  }

  void setTab(int tab) {
    emit(state.copyWith(selectedTab: tab));
  }

  Future<void> createPlaylist(String name) async {
    final now = DateTime.now();
    final playlist = Playlist(
      id: 'pl_${now.millisecondsSinceEpoch}',
      name: name,
      createdAt: now,
      updatedAt: now,
    );
    final updated = [...state.playlists, playlist];
    await _storage.savePlaylists(updated);
    emit(state.copyWith(playlists: updated));
  }

  Future<void> deletePlaylist(String id) async {
    final updated = state.playlists.where((p) => p.id != id).toList();
    await _storage.savePlaylists(updated);
    emit(state.copyWith(playlists: updated));
  }

  Future<void> renamePlaylist(String id, String newName) async {
    final updated = state.playlists
        .map((p) => p.id == id
            ? p.copyWith(name: newName, updatedAt: DateTime.now())
            : p)
        .toList();
    await _storage.savePlaylists(updated);
    emit(state.copyWith(playlists: updated));
  }

  Future<void> addTrackToPlaylist(String playlistId, Track track) async {
    final updated = state.playlists.map((p) {
      if (p.id != playlistId) return p;
      if (p.tracks.any((t) => t.id == track.id)) return p;
      return p.copyWith(
        tracks: [...p.tracks, track],
        updatedAt: DateTime.now(),
      );
    }).toList();
    await _storage.savePlaylists(updated);
    emit(state.copyWith(playlists: updated));
  }

  Future<void> removeTrackFromPlaylist(
    String playlistId,
    String trackId,
  ) async {
    final updated = state.playlists.map((p) {
      if (p.id != playlistId) return p;
      return p.copyWith(
        tracks: p.tracks.where((t) => t.id != trackId).toList(),
        updatedAt: DateTime.now(),
      );
    }).toList();
    await _storage.savePlaylists(updated);
    emit(state.copyWith(playlists: updated));
  }

  Future<void> toggleFavorite(Track track) async {
    final exists = state.favorites.any((t) => t.id == track.id);
    final updated = exists
        ? state.favorites.where((t) => t.id != track.id).toList()
        : [...state.favorites, track.copyWith(isFavorite: true)];
    await _storage.saveFavorites(updated);
    emit(state.copyWith(favorites: updated));
  }

  bool isFavorite(String trackId) {
    return state.favorites.any((t) => t.id == trackId);
  }
}
