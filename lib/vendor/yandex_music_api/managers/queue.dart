import '../client.dart';

/// Queue (listening history) endpoints.
/// Dart port of `yandex_music._client.queue.QueueMixin`.
class QueueManager {
  QueueManager(this._client);

  final YandexClient _client;

  Future<List<Map<String, dynamic>>> list({String? deviceID}) async {
    final data = await _client.fetch('/queues',
        headers: {
          'X-Yandex-Music-Device': deviceID ?? (_client.device ?? ''),
        });
    if (data is Map && data['queues'] is List) {
      return (data['queues'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  Future<Map<String, dynamic>?> get(String queueID) async {
    final data = await _client.fetch('/queues/$queueID');
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> create(Map<String, dynamic> payload,
      {String? deviceID}) async {
    final data = await _client.fetch('/queues',
        method: 'POST',
        body: payload,
        headers: {
          if (deviceID != null) 'X-Yandex-Music-Device': deviceID,
        });
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<Map<String, dynamic>?> updatePosition(String queueID, int position,
      {String? deviceID, bool isInteractive = true}) async {
    final data = await _client.fetch('/queues/$queueID/update-position',
        method: 'POST',
        params: {
          'currentIndex': position,
          'isInteractive': isInteractive,
        },
        headers: {
          if (deviceID != null) 'X-Yandex-Music-Device': deviceID,
        });
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }
}
