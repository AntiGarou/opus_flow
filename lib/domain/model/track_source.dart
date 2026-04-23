class TrackSource {
  static const soundcloud = 'SOUNDCLOUD';
  static const jamendo = 'JAMENDO';
  static const deezer = 'DEEZER';
  static const yandex = 'YANDEX';
  static const spotify = 'SPOTIFY';
  static const youtube = 'YOUTUBE';
  static const local = 'LOCAL';

  static String displayName(String source) {
    switch (source) {
      case soundcloud:
        return 'SoundCloud';
      case jamendo:
        return 'Jamendo';
      case deezer:
        return 'Deezer';
      case yandex:
        return 'Yandex Music';
      case spotify:
        return 'Spotify';
      case youtube:
        return 'YouTube Music';
      case local:
        return 'Local';
      default:
        return source;
    }
  }

  static String shortName(String source) {
    switch (source) {
      case soundcloud:
        return 'SC';
      case jamendo:
        return 'JM';
      case deezer:
        return 'DZ';
      case yandex:
        return 'YM';
      case spotify:
        return 'SP';
      case youtube:
        return 'YT';
      case local:
        return 'L';
      default:
        return source;
    }
  }
}

enum SearchSource { all, soundcloud, youtube, yandex, spotify }
