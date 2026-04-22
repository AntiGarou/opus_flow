import 'common.dart';

/// Lyrics block attached to a track supplement.
class YLyrics {
  YLyrics(Map<String, dynamic> data)
      : id = (data['id'] as num?)?.toInt() ?? 0,
        lyrics = data['lyrics'] as String? ?? '',
        fullLyrics = data['full_lyrics'] as String? ?? '',
        hasRights = data['has_rights'] as bool? ?? false,
        textLanguage = data['text_language'] as String?,
        showTranslation = data['show_translation'] as bool? ?? false,
        url = data['url'] as String?;

  final int id;
  final String lyrics;
  final String fullLyrics;
  final bool hasRights;
  final String? textLanguage;
  final bool showTranslation;
  final String? url;
}

/// Supplement envelope — track extras including lyrics and videos.
class YSupplement {
  YSupplement(Map<String, dynamic> data)
      : raw = data,
        id = (data['id'] as num?)?.toInt() ?? 0,
        lyrics = data['lyrics'] is Map
            ? YLyrics(Map<String, dynamic>.from(data['lyrics'] as Map))
            : null,
        videos = data['videos'] is Map
            ? decodeMapList((data['videos'] as Map)['items'])
            : decodeMapList(data['videos']),
        radioIsAvailable = data['radio_is_available'] as bool?,
        description = data['description'] as String?;

  final Map<String, dynamic> raw;
  final int id;
  final YLyrics? lyrics;
  final List<Map<String, dynamic>> videos;
  final bool? radioIsAvailable;
  final String? description;
}

/// Single download-info record (codec, bitrate, URL).
class YDownloadInfo {
  YDownloadInfo(Map<String, dynamic> data)
      : raw = data,
        codec = data['codec'] as String? ?? 'mp3',
        gain = data['gain'] as bool? ?? false,
        preview = data['preview'] as bool? ?? false,
        direct = data['direct'] as bool? ?? false,
        downloadInfoUrl = data['download_info_url'] as String? ?? '',
        bitrateInKbps = (data['bitrate_in_kbps'] as num?)?.toInt() ?? 0;

  final Map<String, dynamic> raw;
  final String codec;
  final bool gain;
  final bool preview;
  final bool direct;
  final String downloadInfoUrl;
  final int bitrateInKbps;
}

/// Search result envelope.
class YSearchResult {
  YSearchResult(Map<String, dynamic> data)
      : raw = data,
        searchRequestId = data['search_request_id'] as String?,
        text = data['text'] as String?,
        best = data['best'] is Map
            ? Map<String, dynamic>.from(data['best'] as Map)
            : null,
        albums = _block(data['albums']),
        artists = _block(data['artists']),
        tracks = _block(data['tracks']),
        playlists = _block(data['playlists']),
        videos = _block(data['videos']),
        podcasts = _block(data['podcasts']),
        podcastEpisodes = _block(data['podcast_episodes']),
        users = _block(data['users']),
        misspellOriginal = data['misspell_original'] as String?,
        misspellCorrected = data['misspell_corrected'] as String?,
        misspellResult = data['misspell_result'] as String?,
        nothingFound = data['nothing_found'] as bool? ?? false,
        type = data['type'] as String?,
        page = (data['page'] as num?)?.toInt(),
        perPage = (data['per_page'] as num?)?.toInt();

  static Map<String, dynamic>? _block(dynamic raw) =>
      raw is Map ? Map<String, dynamic>.from(raw) : null;

  final Map<String, dynamic> raw;
  final String? searchRequestId;
  final String? text;
  final Map<String, dynamic>? best;
  final Map<String, dynamic>? albums;
  final Map<String, dynamic>? artists;
  final Map<String, dynamic>? tracks;
  final Map<String, dynamic>? playlists;
  final Map<String, dynamic>? videos;
  final Map<String, dynamic>? podcasts;
  final Map<String, dynamic>? podcastEpisodes;
  final Map<String, dynamic>? users;
  final String? misspellOriginal;
  final String? misspellCorrected;
  final String? misspellResult;
  final bool nothingFound;
  final String? type;
  final int? page;
  final int? perPage;
}
