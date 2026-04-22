import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/model/album.dart';
import '../../domain/model/artist.dart';
import '../../domain/model/playlist.dart';
import '../../domain/model/track.dart';
import '../../domain/model/track_source.dart';

class PlaylistStorage {
  static const _playlistsKey = 'playlists';
  static const _favoritesKey = 'favorites';

  Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  Future<List<Playlist>> getPlaylists() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_playlistsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .cast<Map<String, dynamic>>()
          .map(_playlistFromJson)
          .toList();
    } catch (e) {
      debugPrint('PlaylistStorage.getPlaylists failed: $e');
      return [];
    }
  }

  Future<void> savePlaylists(List<Playlist> playlists) async {
    final prefs = await _prefs;
    final encoded = jsonEncode(playlists.map(_playlistToJson).toList());
    await prefs.setString(_playlistsKey, encoded);
  }

  Future<List<Track>> getFavorites() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_favoritesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.cast<Map<String, dynamic>>().map(_trackFromJson).toList();
    } catch (e) {
      debugPrint('PlaylistStorage.getFavorites failed: $e');
      return [];
    }
  }

  Future<void> saveFavorites(List<Track> favorites) async {
    final prefs = await _prefs;
    final encoded = jsonEncode(favorites.map(_trackToJson).toList());
    await prefs.setString(_favoritesKey, encoded);
  }

  Map<String, dynamic> _playlistToJson(Playlist p) => {
        'id': p.id,
        'name': p.name,
        'description': p.description,
        'coverUrl': p.coverUrl,
        'createdAt': p.createdAt.toIso8601String(),
        'updatedAt': p.updatedAt.toIso8601String(),
        'tracks': p.tracks.map(_trackToJson).toList(),
      };

  Playlist _playlistFromJson(Map<String, dynamic> json) {
    final tracks = (json['tracks'] as List?)
            ?.cast<Map<String, dynamic>>()
            .map(_trackFromJson)
            .toList() ??
        <Track>[];
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      coverUrl: json['coverUrl'] as String?,
      tracks: tracks,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
              DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> _trackToJson(Track t) => {
        'id': t.id,
        'title': t.title,
        'artist_id': t.artist.id,
        'artist_name': t.artist.name,
        'artist_avatar': t.artist.avatarUrl,
        'album_id': t.album?.id,
        'album_title': t.album?.title,
        'album_artwork': t.album?.artworkUrl,
        'duration_ms': t.duration.inMilliseconds,
        'streamUrl': t.streamUrl,
        'artworkUrl': t.artworkUrl,
        'genre': t.genre,
        'source': t.source,
        'isDownloadable': t.isDownloadable,
        'isFavorite': t.isFavorite,
        'isExplicit': t.isExplicit,
      };

  Track _trackFromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      artist: Artist(
        id: json['artist_id'] as String? ?? '',
        name: json['artist_name'] as String? ?? 'Unknown',
        avatarUrl: json['artist_avatar'] as String?,
      ),
      album: json['album_id'] != null
          ? Album(
              id: json['album_id'] as String,
              title: json['album_title'] as String? ?? '',
              artworkUrl: json['album_artwork'] as String?,
            )
          : null,
      duration: Duration(milliseconds: (json['duration_ms'] as int?) ?? 0),
      streamUrl: json['streamUrl'] as String?,
      artworkUrl: json['artworkUrl'] as String?,
      genre: json['genre'] as String?,
      source: json['source'] as String? ?? TrackSource.local,
      isDownloadable: json['isDownloadable'] == true,
      isFavorite: json['isFavorite'] == true,
      isExplicit: json['isExplicit'] == true,
    );
  }
}
