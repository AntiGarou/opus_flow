/// Dart port of [spotify-api.js](https://github.com/spotify-api/spotify-api.js).
///
/// Exposes a [Client] facade plus the same set of managers and structures
/// as the TypeScript library. The public API surface matches the original
/// library where meaningful for Dart (methods are camelCase, constructors
/// take a `Map<String, dynamic>` of raw JSON, options are passed as typed
/// dataclasses under `interface.dart`).
library spotify_api_js;

export 'cache.dart';
export 'client.dart';
export 'error.dart';
export 'interface.dart';
export 'scopes.dart';
export 'util.dart';
export 'managers/album.dart';
export 'managers/artist.dart';
export 'managers/auth.dart';
export 'managers/browse.dart';
export 'managers/episode.dart';
export 'managers/player.dart';
export 'managers/playlist.dart';
export 'managers/show.dart';
export 'managers/track.dart';
export 'managers/user.dart';
export 'managers/user_client.dart';
export 'structures/album.dart';
export 'structures/artist.dart';
export 'structures/episode.dart';
export 'structures/playlist.dart';
export 'structures/show.dart';
export 'structures/track.dart';
export 'structures/user.dart';
