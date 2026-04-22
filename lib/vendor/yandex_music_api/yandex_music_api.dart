/// Dart port of [MarshalX/yandex-music-api](https://github.com/MarshalX/yandex-music-api).
///
/// Exposes a [YandexClient] facade plus the same grouping of REST endpoints
/// as the Python library: account, albums, artists, landing, likes, playlists,
/// queue, radio/rotor, search, tracks.
library yandex_music_api;

export 'client.dart';
export 'exceptions.dart';
export 'managers/account.dart';
export 'managers/albums.dart';
export 'managers/artists.dart';
export 'managers/landing.dart';
export 'managers/likes.dart';
export 'managers/playlists.dart';
export 'managers/queue.dart';
export 'managers/radio.dart';
export 'managers/search.dart';
export 'managers/tracks.dart';
export 'structures/album.dart';
export 'structures/artist.dart';
export 'structures/common.dart';
export 'structures/landing.dart';
export 'structures/playlist.dart';
export 'structures/station.dart';
export 'structures/supplement.dart';
export 'structures/track.dart';
export 'structures/user.dart';
