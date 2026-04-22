import 'interface.dart';
import 'structures/album.dart';
import 'structures/artist.dart';
import 'structures/episode.dart';
import 'structures/playlist.dart';
import 'structures/show.dart';
import 'structures/track.dart';
import 'structures/user.dart';

/// Process-wide cache, analog of the `Cache` const in spotify-api.js.
class SpotifyCache {
  static final users = <String, User>{};
  static final artists = <String, Artist>{};
  static final tracks = <String, Track>{};
  static final albums = <String, Album>{};
  static final playlists = <String, Playlist>{};
  static final episodes = <String, Episode>{};
  static final shows = <String, Show>{};

  static Map<String, Object> _mapFor(String key) {
    switch (key) {
      case 'users':
        return users;
      case 'artists':
        return artists;
      case 'tracks':
        return tracks;
      case 'albums':
        return albums;
      case 'playlists':
        return playlists;
      case 'episodes':
        return episodes;
      case 'shows':
        return shows;
    }
    throw ArgumentError('Unknown cache key: $key');
  }

  static bool has(String key, String id) => _mapFor(key).containsKey(id);
  static Object? get(String key, String id) => _mapFor(key)[id];
  static void put(String key, String id, Object value) {
    _mapFor(key)[id] = value;
  }
}

/// Builds a structure object from raw JSON based on the [key].
Object _build(String key, Map<String, dynamic> data) {
  switch (key) {
    case 'users':
      return User(data);
    case 'artists':
      return Artist(data);
    case 'tracks':
      return Track(data);
    case 'albums':
      return Album(data);
    case 'playlists':
      return Playlist(data);
    case 'episodes':
      return Episode(data);
    case 'shows':
      return Show(data);
  }
  throw ArgumentError('Unknown structure key: $key');
}

/// Create a single structure and respect cache settings.
T createCacheStruct<T>(
    String key, CacheSettings settings, Map<String, dynamic> data) {
  final struct = _build(key, data) as T;
  if (settings.byKey(key) && data['id'] is String) {
    SpotifyCache.put(key, data['id'] as String, struct as Object);
  }
  return struct;
}

/// Create a structure and always cache it, ignoring settings.
T createForcedCacheStruct<T>(String key, Map<String, dynamic> data) {
  final struct = _build(key, data) as T;
  if (data['id'] is String) {
    SpotifyCache.put(key, data['id'] as String, struct as Object);
  }
  return struct;
}

/// Create an array of cached structures.
List<T> createCacheStructArray<T>(
  String key,
  CacheSettings settings,
  List data, {
  bool fromCache = false,
}) {
  return data.map((raw) {
    final map = Map<String, dynamic>.from(raw as Map);
    final struct = _build(key, map) as T;
    if (settings.byKey(key) && !fromCache && map['id'] is String) {
      SpotifyCache.put(key, map['id'] as String, struct as Object);
    }
    return struct;
  }).toList();
}

/// Create an array of Saved<T> wrappers from raw `{added_at, <key-single>: ...}` rows.
List<Saved<T>> createCacheSavedStructArray<T>(
  String key,
  CacheSettings settings,
  List data, {
  bool fromCache = false,
}) {
  final normalKey = key.endsWith('s') ? key.substring(0, key.length - 1) : key;
  return data.map((raw) {
    final row = Map<String, dynamic>.from(raw as Map);
    final inner = Map<String, dynamic>.from(row[normalKey] as Map);
    final struct = _build(key, inner) as T;
    if (settings.byKey(key) && !fromCache && inner['id'] is String) {
      SpotifyCache.put(key, inner['id'] as String, struct as Object);
    }
    return Saved<T>(addedAt: row['added_at'] as String? ?? '', item: struct);
  }).toList();
}
