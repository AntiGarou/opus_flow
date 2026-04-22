/// Spotify OAuth scopes.
/// Dart port of spotify-api.js `Scopes` enum (in `Interface.ts`).
class Scopes {
  static const imageUpload = 'ugc-image-upload';
  static const readRecentlyPlayed = 'user-read-recently-played';
  static const readPlaybackState = 'user-read-playback-state';
  static const readTopArtistsAndUsers = 'user-top-read';
  static const remoteControl = 'app-remote-control';
  static const modifyPublicPlaylists = 'playlist-modify-public';
  static const writePlaybackState = 'user-modify-playback-state';
  static const modifyPrivatePlaylists = 'playlist-modify-private';
  static const readCurrentlyPlaying = 'user-read-currently-playing';
  static const readPlaybackPosition = 'user-read-playback-position';
  static const readPrivatePlaylists = 'playlist-read-private';
  static const readCollaborativePlaylists = 'playlist-read-collaborative';
  static const modifyLibrary = 'user-library-modify';
  static const readLibrary = 'user-library-read';
  static const readEmail = 'user-read-email';
  static const readPrivate = 'user-read-private';
  static const readFollow = 'user-follow-read';
  static const modifyFollow = 'user-follow-modify';
  static const streaming = 'streaming';
}
