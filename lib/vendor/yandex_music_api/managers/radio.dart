import '../client.dart';
import '../structures/station.dart';
import '../structures/track.dart';

/// Rotor / radio endpoints.
/// Dart port of `yandex_music._client.radio.RadioMixin`.
class RadioManager {
  RadioManager(this._client);

  final YandexClient _client;

  Future<Map<String, dynamic>?> accountStatus() async {
    final data = await _client.fetch('/rotor/account/status');
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> dashboard() async {
    final data = await _client.fetch('/rotor/stations/dashboard');
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<List<YStationResult>> stationsList({String? language}) async {
    final data = await _client.fetch('/rotor/stations/list',
        params: {if (language != null) 'language': language});
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => YStationResult(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<YStationResult>> stationInfo(String station) async {
    final data = await _client.fetch('/rotor/station/$station/info');
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => YStationResult(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<YTrack>> stationTracks(String station,
      {bool settings2 = true, String? queue}) async {
    final data = await _client.fetch('/rotor/station/$station/tracks',
        params: {
          'settings2': settings2,
          if (queue != null) 'queue': queue,
        });
    if (data is! Map) return const [];
    final sequence = data['sequence'];
    if (sequence is! List) return const [];
    return sequence
        .whereType<Map>()
        .map((item) {
          final track = item['track'];
          return track is Map
              ? YTrack(Map<String, dynamic>.from(track))
              : null;
        })
        .whereType<YTrack>()
        .toList();
  }

  Future<bool> feedback(
    String station,
    String type, {
    String? trackId,
    String? batchId,
    Object? totalPlayedSeconds,
    Object? timestamp,
    String? from,
  }) async {
    final body = <String, dynamic>{
      'type': type,
      if (trackId != null) 'trackId': trackId,
      if (batchId != null) 'batchId': batchId,
      if (totalPlayedSeconds != null) 'totalPlayedSeconds': totalPlayedSeconds,
      if (timestamp != null) 'timestamp': timestamp,
      if (from != null) 'from': from,
    };
    final data = await _client.postForm('/rotor/station/$station/feedback', body);
    return data is Map && (data['result'] == 'ok' || data.isNotEmpty);
  }

  Future<bool> feedbackRadioStarted(String station, {String? from}) =>
      feedback(station, 'radioStarted', from: from);

  Future<bool> feedbackTrackStarted(String station, String trackId) =>
      feedback(station, 'trackStarted', trackId: trackId);

  Future<bool> feedbackTrackFinished(String station, String trackId,
          Object totalPlayedSeconds) =>
      feedback(station, 'trackFinished',
          trackId: trackId, totalPlayedSeconds: totalPlayedSeconds);

  Future<bool> feedbackSkip(String station, String trackId,
          Object totalPlayedSeconds) =>
      feedback(station, 'skip',
          trackId: trackId, totalPlayedSeconds: totalPlayedSeconds);

  Future<Map<String, dynamic>?> settings2(String station,
      {String? mood, String? diversity, String? language}) async {
    final body = <String, dynamic>{
      if (mood != null) 'moodEnergy': mood,
      if (diversity != null) 'diversity': diversity,
      if (language != null) 'language': language,
    };
    final data = await _client.postForm('/rotor/station/$station/settings2', body);
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }
}
