import '../client.dart';
import '../interface.dart';
import '../structures/track.dart';

/// Dart port of spotify-api.js `managers/Player.ts`.
class PlayerManager {
  PlayerManager(this.client);

  final Client client;

  /// Current full playback snapshot.
  Future<CurrentPlayback?> getCurrentPlayback({String? additionalTypes}) async {
    final data = await client.fetch(
      '/me/player',
      FetchOptions(params: {
        if (additionalTypes != null) 'additional_types': additionalTypes
      }),
    );
    if (data is! Map) return null;
    return _makeCurrentPlayback(Map<String, dynamic>.from(data));
  }

  /// Currently playing track/episode (subset of playback).
  Future<CurrentPlayback?> getCurrentlyPlaying({String? additionalTypes}) async {
    final data = await client.fetch(
      '/me/player/currently-playing',
      FetchOptions(params: {
        if (additionalTypes != null) 'additional_types': additionalTypes
      }),
    );
    if (data is! Map) return null;
    return _makeCurrentPlayback(Map<String, dynamic>.from(data));
  }

  Future<RecentlyPlayed> getRecentlyPlayed(
      {String? before, String? after, int? limit}) async {
    final data = await client.fetch(
      '/me/player/recently-played',
      FetchOptions(params: {
        if (before != null) 'before': before,
        if (after != null) 'after': after,
        if (limit != null) 'limit': limit,
      }),
    );
    if (data is! Map) {
      return const RecentlyPlayed(cursors: Cursor(), items: []);
    }
    final items = ((data['items'] as List?) ?? [])
        .map((raw) {
          final m = Map<String, dynamic>.from(raw as Map);
          return RecentlyPlayedItem(
            track: Track(Map<String, dynamic>.from(m['track'] as Map)),
            playedAt: m['played_at'] as String? ?? '',
          );
        })
        .toList();
    final cursors = Map<String, dynamic>.from(
        (data['cursors'] as Map?) ?? const <String, dynamic>{});
    return RecentlyPlayed(
      cursors:
          Cursor(before: cursors['before'] as String?, after: cursors['after'] as String?),
      items: items,
    );
  }

  Future<List<Device>> getDevices() async {
    final data = await client.fetch('/me/player/devices');
    if (data is! Map) return [];
    return ((data['devices'] as List?) ?? [])
        .map((raw) => _makeDevice(Map<String, dynamic>.from(raw as Map)))
        .toList();
  }

  Future<bool> transferPlayback(String deviceID, {bool play = false}) async {
    final response = await client.fetch(
      '/me/player',
      FetchOptions(
        method: 'PUT',
        headers: {'Content-Type': 'application/json'},
        body: {
          'device_ids': [deviceID],
          'play': play,
        },
      ),
    );
    return response != null;
  }

  Future<bool> play(
      {String? deviceID,
      String? contextURI,
      List<String>? uris,
      int? offset,
      int? position}) async {
    final response = await client.fetch(
      '/me/player/play',
      FetchOptions(
        method: 'PUT',
        headers: {'Content-Type': 'application/json'},
        params: {if (deviceID != null) 'device_id': deviceID},
        body: {
          if (contextURI != null) 'context_uri': contextURI,
          if (uris != null) 'uris': uris,
          if (offset != null) 'offset': offset,
          if (position != null) 'position_ms': position,
        },
      ),
    );
    return response != null;
  }

  Future<bool> pause({String? deviceID}) async {
    final response = await client.fetch(
      '/me/player/pause',
      FetchOptions(
        method: 'PUT',
        params: {if (deviceID != null) 'device_id': deviceID},
      ),
    );
    return response != null;
  }

  Future<bool> next({String? deviceID}) async {
    final response = await client.fetch(
      '/me/player/next',
      FetchOptions(
        method: 'POST',
        params: {if (deviceID != null) 'device_id': deviceID},
      ),
    );
    return response != null;
  }

  Future<bool> previous({String? deviceID}) async {
    final response = await client.fetch(
      '/me/player/previous',
      FetchOptions(
        method: 'POST',
        params: {if (deviceID != null) 'device_id': deviceID},
      ),
    );
    return response != null;
  }

  Future<bool> seek(int positionMs, {String? deviceID}) async {
    final response = await client.fetch(
      '/me/player/seek',
      FetchOptions(
        method: 'PUT',
        params: {
          'position_ms': positionMs,
          if (deviceID != null) 'device_id': deviceID
        },
      ),
    );
    return response != null;
  }

  Future<bool> setRepeat(String state, {String? deviceID}) async {
    final response = await client.fetch(
      '/me/player/repeat',
      FetchOptions(
        method: 'PUT',
        params: {
          'state': state,
          if (deviceID != null) 'device_id': deviceID,
        },
      ),
    );
    return response != null;
  }

  Future<bool> setShuffle(bool state, {String? deviceID}) async {
    final response = await client.fetch(
      '/me/player/shuffle',
      FetchOptions(
        method: 'PUT',
        params: {
          'state': state,
          if (deviceID != null) 'device_id': deviceID,
        },
      ),
    );
    return response != null;
  }

  Future<bool> setVolume(int volumePercent, {String? deviceID}) async {
    final response = await client.fetch(
      '/me/player/volume',
      FetchOptions(
        method: 'PUT',
        params: {
          'volume_percent': volumePercent,
          if (deviceID != null) 'device_id': deviceID,
        },
      ),
    );
    return response != null;
  }

  static Device _makeDevice(Map<String, dynamic> data) => Device(
        id: data['id'] as String?,
        isActive: data['is_active'] as bool? ?? false,
        isPrivateSession: data['is_private_session'] as bool? ?? false,
        isRestricted: data['is_restricted'] as bool? ?? false,
        name: data['name'] as String? ?? '',
        type: data['type'] as String? ?? 'Unknown',
        volumePercent: data['volume_percent'] as int?,
      );

  static CurrentPlayback _makeCurrentPlayback(Map<String, dynamic> data) {
    final device = data['device'] is Map
        ? _makeDevice(Map<String, dynamic>.from(data['device'] as Map))
        : const Device(
            isActive: false,
            isPrivateSession: false,
            isRestricted: false,
            name: '',
            type: '',
          );
    final context = data['context'] is Map
        ? PlayerContext(
            externalURL: Map<String, String>.from(
                (data['context']['external_urls'] as Map?)
                        ?.cast<String, String>() ??
                    const <String, String>{}),
            href: data['context']['href'] as String? ?? '',
            type: data['context']['type'] as String? ?? '',
            uri: data['context']['uri'] as String? ?? '',
          )
        : null;

    return CurrentPlayback(
      timestamp: data['timestamp'] as int? ?? 0,
      progress: data['progress_ms'] as int?,
      isPlaying: data['is_playing'] as bool? ?? false,
      currentPlayingType: data['currently_playing_type'] as String? ?? 'track',
      item: data['item'] is Map
          ? Track(Map<String, dynamic>.from(data['item'] as Map))
          : null,
      context: context,
      shuffleState: data['shuffle_state'] as bool? ?? false,
      repeatState: data['repeat_state'] as String? ?? 'off',
      device: device,
    );
  }
}
