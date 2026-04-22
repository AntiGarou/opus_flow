import 'package:flutter/foundation.dart';

import '../../domain/model/track.dart';
import '../../domain/model/track_source.dart';
import '../../domain/repository/track_repository.dart';
import '../api/deezer_api.dart';
import '../api/jamendo_api.dart';
import '../api/soundcloud_api.dart';
import '../api/spotify_api.dart';
import '../api/yandex_music_api.dart';
import '../mapper/deezer_mapper.dart';
import '../mapper/jamendo_mapper.dart';
import '../mapper/soundcloud_mapper.dart';
import '../mapper/spotify_mapper.dart';
import '../mapper/yandex_music_mapper.dart';

class TrackRepositoryImpl implements TrackRepository {
  final SoundCloudApi _soundCloudApi;
  final JamendoApi _jamendoApi;
  final DeezerApi _deezerApi;
  final YandexMusicApi _yandexMusicApi;
  final SpotifyApi _spotifyApi;

  TrackRepositoryImpl(
    this._soundCloudApi,
    this._jamendoApi,
    this._deezerApi,
    this._yandexMusicApi,
    this._spotifyApi,
  );

  @override
  Future<List<Track>> searchTracks(
    String query, {
    SearchSource source = SearchSource.all,
  }) async {
    if (query.trim().isEmpty) return [];

    final futures = <Future<List<Track>>>[];

    if (source == SearchSource.all || source == SearchSource.soundcloud) {
      futures.add(_safeFetch(() => _searchSoundCloud(query)));
    }
    if (source == SearchSource.all) {
      futures.add(_safeFetch(() => _searchJamendo(query)));
      futures.add(_safeFetch(() => _searchDeezer(query)));
    }
    if (source == SearchSource.all || source == SearchSource.yandex) {
      futures.add(_safeFetch(() => _searchYandex(query)));
    }
    if (source == SearchSource.all || source == SearchSource.spotify) {
      futures.add(_safeFetch(() => _searchSpotify(query)));
    }

    final results = await Future.wait(futures);
    final combined = results.expand((x) => x).toList();
    return _deduplicateAndSort(combined);
  }

  @override
  Future<List<Track>> getTrendingTracks() async {
    final results = await Future.wait([
      _safeFetch(() async =>
          (await _soundCloudApi.getTrending(limit: 20))
              .map(SoundCloudMapper.toTrack)
              .toList()),
      _safeFetch(() async =>
          (await _jamendoApi.getTrending(limit: 20))
              .map(JamendoMapper.toTrack)
              .toList()),
      _safeFetch(() async =>
          (await _deezerApi.getTrending(limit: 20))
              .map(DeezerMapper.toTrack)
              .toList()),
      _safeFetch(() async {
        final chart = await _yandexMusicApi.chart();
        final chartTracks = chart?['chart']?['tracks'] as List?;
        if (chartTracks == null) return <Track>[];
        return chartTracks
            .cast<Map<String, dynamic>>()
            .map((e) => (e['track'] ?? e) as Map<String, dynamic>)
            .map(YandexMusicMapper.toTrack)
            .toList();
      }),
      _safeFetch(() async {
        final items = await _spotifyApi.getTrending(limit: 20);
        return items
            .map(SpotifyMapper.toTrack)
            .whereType<Track>()
            .toList();
      }),
    ]);
    final combined = results.expand((x) => x).toList();
    return _deduplicateAndSort(combined);
  }

  @override
  Future<Track?> getTrack(String id) async {
    if (id.startsWith('sc_')) {
      final raw = await _soundCloudApi.getTrack(id.substring(3));
      return raw == null ? null : SoundCloudMapper.toTrack(raw);
    }
    if (id.startsWith('jm_')) {
      final raw = await _jamendoApi.getTrack(id.substring(3));
      return raw == null ? null : JamendoMapper.toTrack(raw);
    }
    if (id.startsWith('dz_')) {
      final raw = await _deezerApi.getTrack(id.substring(3));
      return raw == null ? null : DeezerMapper.toTrack(raw);
    }
    if (id.startsWith('ym_')) {
      final trackPart = id.substring(3).split(':').first;
      final raws = await _yandexMusicApi.tracks([trackPart]);
      if (raws.isEmpty) return null;
      return YandexMusicMapper.toTrack(raws.first);
    }
    if (id.startsWith('sp_')) {
      final raw = await _spotifyApi.getTrack(id.substring(3));
      return raw == null ? null : SpotifyMapper.toTrack(raw);
    }
    return null;
  }

  @override
  Future<List<Track>> getTracksByGenre(String genre) async {
    final results = await Future.wait([
      _safeFetch(() async =>
          (await _jamendoApi.getByGenre(genre, limit: 20))
              .map(JamendoMapper.toTrack)
              .toList()),
      _safeFetch(() async {
        final items = await _spotifyApi.searchByGenre(genre, limit: 20);
        return items.map(SpotifyMapper.toTrack).whereType<Track>().toList();
      }),
      _safeFetch(() => _searchSoundCloud(genre)),
      _safeFetch(() => _searchDeezer(genre)),
      _safeFetch(() => _searchYandex(genre)),
    ]);
    final combined = results.expand((x) => x).toList();
    return _deduplicateAndSort(combined);
  }

  Future<List<Track>> _safeFetch(Future<List<Track>> Function() fn) async {
    try {
      return await fn();
    } catch (e) {
      debugPrint('TrackRepositoryImpl: fetch failed: $e');
      return [];
    }
  }

  Future<List<Track>> _searchSoundCloud(String q) async {
    final raws = await _soundCloudApi.searchTracks(q, limit: 20);
    return raws.map(SoundCloudMapper.toTrack).toList();
  }

  Future<List<Track>> _searchJamendo(String q) async {
    final raws = await _jamendoApi.searchTracks(q, limit: 20);
    return raws.map(JamendoMapper.toTrack).toList();
  }

  Future<List<Track>> _searchDeezer(String q) async {
    final raws = await _deezerApi.searchTracks(q, limit: 20);
    return raws.map(DeezerMapper.toTrack).toList();
  }

  Future<List<Track>> _searchYandex(String q) async {
    final searchResult = await _yandexMusicApi.search(q);
    final tracksBlock = searchResult?['tracks'] as Map<String, dynamic>?;
    final results = tracksBlock?['results'] as List?;
    if (results == null) return [];
    return results
        .cast<Map<String, dynamic>>()
        .map(YandexMusicMapper.toTrack)
        .toList();
  }

  Future<List<Track>> _searchSpotify(String q) async {
    final raws = await _spotifyApi.searchTracks(q, limit: 20);
    return raws.map(SpotifyMapper.toTrack).whereType<Track>().toList();
  }

  List<Track> _deduplicateAndSort(List<Track> tracks) {
    final byId = <String, Track>{};
    for (final t in tracks) {
      byId.putIfAbsent(t.id, () => t);
    }
    final unique = byId.values.toList();

    String normalizeTitle(String title) {
      var t = title.toLowerCase();
      t = t.replaceAll(RegExp(r'\([^)]*\)'), ' ');
      t = t.replaceAll(RegExp(r'\[[^\]]*\]'), ' ');
      t = t.replaceAll(
          RegExp(r'\b(explicit|clean|radio edit|remastered)\b'), ' ');
      t = t.replaceAll(RegExp(r'\s+'), ' ').trim();
      return t;
    }

    String normalizeArtist(String name) {
      var a = name.toLowerCase();
      a = a.replaceAll(RegExp(r'\bfeat\.?\s+[^,]*'), ' ');
      a = a.replaceAll(RegExp(r'\s+x\s+'), ' ');
      a = a.replaceAll(RegExp(r'\s+'), ' ').trim();
      return a;
    }

    int sourcePriority(String s) {
      switch (s) {
        case TrackSource.yandex:
          return 4;
        case TrackSource.soundcloud:
          return 3;
        case TrackSource.jamendo:
          return 2;
        case TrackSource.deezer:
          return 1;
        case TrackSource.spotify:
          return 0;
        default:
          return -1;
      }
    }

    int score(Track t) {
      var s = 0;
      if (t.streamUrl != null && t.streamUrl!.isNotEmpty) s += 100;
      if (!t.isExplicit) s += 20;
      s += sourcePriority(t.source);
      if (t.artworkUrl != null && t.artworkUrl!.isNotEmpty) s += 1;
      return s;
    }

    final groups = <String, List<Track>>{};
    for (final t in unique) {
      final key =
          '${normalizeTitle(t.title)}|${normalizeArtist(t.artist.name)}';
      groups.putIfAbsent(key, () => []).add(t);
    }

    final picked = <Track>[];
    for (final group in groups.values) {
      group.sort((a, b) => score(b).compareTo(score(a)));
      picked.add(group.first);
    }

    picked.sort((a, b) {
      final diff = score(b).compareTo(score(a));
      if (diff != 0) return diff;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return picked;
  }
}
