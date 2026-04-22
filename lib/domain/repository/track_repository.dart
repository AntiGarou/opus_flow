import '../model/track.dart';
import '../model/track_source.dart';

abstract class TrackRepository {
  Future<List<Track>> searchTracks(
    String query, {
    SearchSource source = SearchSource.all,
  });

  Future<List<Track>> getTrendingTracks();

  Future<Track?> getTrack(String id);

  Future<List<Track>> getTracksByGenre(
    String genre, {
    SearchSource source = SearchSource.all,
  });
}
