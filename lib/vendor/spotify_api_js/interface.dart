import 'structures/album.dart';
import 'structures/artist.dart';
import 'structures/episode.dart';
import 'structures/playlist.dart';
import 'structures/show.dart';
import 'structures/track.dart';
import 'structures/user.dart';

/// HTTP verbs supported by the Spotify Web API.
typedef Methods = String;

/// Options for the Spotify REST fetch function.
class FetchOptions {
  const FetchOptions({
    this.headers,
    this.method = 'GET',
    this.params,
    this.body,
  });

  final Map<String, String>? headers;
  final String method;
  final Map<String, dynamic>? params;
  final Object? body;
}

/// Cache-control flags per entity kind.
class CacheSettings {
  const CacheSettings({
    this.users = false,
    this.artists = false,
    this.tracks = false,
    this.playlists = false,
    this.albums = false,
    this.episodes = false,
    this.shows = false,
  });

  final bool users;
  final bool artists;
  final bool tracks;
  final bool playlists;
  final bool albums;
  final bool episodes;
  final bool shows;

  static const enabled = CacheSettings(
    users: true,
    artists: true,
    tracks: true,
    playlists: true,
    albums: true,
    episodes: true,
    shows: true,
  );

  bool byKey(String key) {
    switch (key) {
      case 'users':
        return users;
      case 'artists':
        return artists;
      case 'tracks':
        return tracks;
      case 'playlists':
        return playlists;
      case 'albums':
        return albums;
      case 'episodes':
        return episodes;
      case 'shows':
        return shows;
    }
    return false;
  }
}

/// Metadata for refreshing the token after it expires.
class ClientRefreshMeta {
  ClientRefreshMeta({
    required this.clientID,
    required this.clientSecret,
    this.refreshToken,
    this.redirectURL,
  });

  final String clientID;
  final String clientSecret;
  String? refreshToken;
  final String? redirectURL;
}

/// Token-with-refresh combined option.
class TokenWithRefreshOptions extends ClientRefreshMeta {
  TokenWithRefreshOptions({
    required this.token,
    required super.clientID,
    required super.clientSecret,
    super.refreshToken,
    super.redirectURL,
  });

  final String token;
}

/// Options to obtain a user-scoped access token.
class GetUserTokenOptions {
  GetUserTokenOptions({
    required this.clientID,
    required this.clientSecret,
    required this.redirectURL,
    this.refreshToken,
    this.code,
  });

  final String clientID;
  final String clientSecret;
  final String redirectURL;
  final String? refreshToken;
  final String? code;
}

/// The returned token context after an OAuth call.
class UserTokenContext {
  const UserTokenContext({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.scope,
    this.refreshToken,
  });

  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final String scope;
  final String? refreshToken;
}

/// The search options shared across all manager `search` methods.
class SearchOptions {
  const SearchOptions({
    this.includeExternalAudio,
    this.offset,
    this.limit,
    this.market,
  });

  final bool? includeExternalAudio;
  final int? offset;
  final int? limit;
  final String? market;
}

/// Search options specific to the top-level `Client.search`.
class ClientSearchOptions extends SearchOptions {
  const ClientSearchOptions({
    required this.types,
    super.includeExternalAudio,
    super.offset,
    super.limit,
    super.market,
  });

  final List<String> types;
}

/// Object returned by `Client.search`.
class SearchContent {
  SearchContent({
    this.episodes,
    this.shows,
    this.tracks,
    this.artists,
    this.albums,
  });

  List<Episode>? episodes;
  List<Show>? shows;
  List<Track>? tracks;
  List<Artist>? artists;
  List<Album>? albums;
}

/// The linked-track object referenced by Track.linkedFrom.
class LinkedTrack {
  const LinkedTrack({
    required this.externalURL,
    required this.id,
    required this.type,
    required this.uri,
  });

  final Map<String, String> externalURL;
  final String id;
  final String type;
  final String uri;
}

/// A track/episode entry inside a playlist.
class PlaylistTrack {
  PlaylistTrack({
    this.addedAt,
    this.addedBy,
    this.isLocal = false,
    this.track,
  });

  String? addedAt;
  User? addedBy;
  bool isLocal;
  Object? track;
}

/// Returned by `Browse.getFeaturedPlaylists`.
class FeaturedPlaylistContent {
  const FeaturedPlaylistContent({
    required this.message,
    required this.playlists,
  });

  final String message;
  final List<Playlist> playlists;
}

/// Returned by `Browse.getRecommendations`.
class Recommendations {
  const Recommendations({required this.seeds, required this.tracks});

  final List<Map<String, dynamic>> seeds;
  final List<Track> tracks;
}

/// Options for `PlaylistManager.reorderItems`.
class PlaylistReorderOptions {
  const PlaylistReorderOptions({
    this.uris,
    this.rangeStart,
    this.insertBefore,
    this.rangeLength,
    this.snapshotID,
  });

  final List<String>? uris;
  final int? rangeStart;
  final int? insertBefore;
  final int? rangeLength;
  final String? snapshotID;
}

/// Generic saved wrapper (used for Saved<T> in library endpoints).
class Saved<T> {
  const Saved({required this.addedAt, required this.item});

  final String addedAt;
  final T item;
}

/// Player-related camel-cased structures.
class Device {
  const Device({
    this.id,
    required this.isActive,
    required this.isPrivateSession,
    required this.isRestricted,
    required this.name,
    required this.type,
    this.volumePercent,
  });

  final String? id;
  final bool isActive;
  final bool isPrivateSession;
  final bool isRestricted;
  final String name;
  final String type;
  final int? volumePercent;
}

class PlayerContext {
  const PlayerContext({
    required this.externalURL,
    required this.href,
    required this.type,
    required this.uri,
  });

  final Map<String, String> externalURL;
  final String href;
  final String type;
  final String uri;
}

class CurrentlyPlaying {
  const CurrentlyPlaying({
    required this.timestamp,
    required this.progress,
    required this.isPlaying,
    required this.currentPlayingType,
    this.item,
    this.context,
  });

  final int timestamp;
  final int? progress;
  final bool isPlaying;
  final String currentPlayingType;
  final Object? item;
  final PlayerContext? context;
}

class CurrentPlayback extends CurrentlyPlaying {
  const CurrentPlayback({
    required super.timestamp,
    required super.progress,
    required super.isPlaying,
    required super.currentPlayingType,
    super.item,
    super.context,
    required this.shuffleState,
    required this.repeatState,
    required this.device,
  });

  final bool shuffleState;
  final String repeatState;
  final Device device;
}

class Cursor {
  const Cursor({this.before, this.after});

  final String? before;
  final String? after;
}

class RecentlyPlayed {
  const RecentlyPlayed({required this.cursors, required this.items});

  final Cursor cursors;
  final List<RecentlyPlayedItem> items;
}

class RecentlyPlayedItem {
  const RecentlyPlayedItem({required this.track, required this.playedAt});

  final Track track;
  final String playedAt;
}

/// User top tracks/artists time range.
class TimeRange {
  static const shortTerm = 'short_term';
  static const mediumTerm = 'medium_term';
  static const longTerm = 'long_term';
}

/// Create-playlist payload (matches spotify-types `CreatePlaylistQuery`).
class CreatePlaylistQuery {
  const CreatePlaylistQuery({
    required this.name,
    this.isPublic,
    this.collaborative,
    this.description,
  });

  final String name;
  final bool? isPublic;
  final bool? collaborative;
  final String? description;

  Map<String, dynamic> toJson() => {
        'name': name,
        if (isPublic != null) 'public': isPublic,
        if (collaborative != null) 'collaborative': collaborative,
        if (description != null) 'description': description,
      };
}
