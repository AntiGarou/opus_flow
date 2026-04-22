import 'package:flutter/foundation.dart';

import 'deezer_api.dart';

class VideoApi {
  final DeezerApi _deezerApi;

  VideoApi(this._deezerApi);

  Future<String?> getVideoUrlForTrack(String query) async {
    try {
      final tracks = await _deezerApi.searchTracks(query, limit: 1);
      if (tracks.isEmpty) return null;
      return tracks.first['preview'] as String?;
    } catch (e) {
      debugPrint('VideoApi.getVideoUrlForTrack failed: $e');
      return null;
    }
  }
}
