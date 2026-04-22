import 'common.dart';

/// Individual block inside the landing page (chart, new-releases, mixes…).
class YLandingBlock {
  YLandingBlock(Map<String, dynamic> data)
      : raw = data,
        id = data['id']?.toString() ?? '',
        type = data['type'] as String? ?? '',
        typeForFrom = data['type_for_from'] as String?,
        title = data['title'] as String?,
        description = data['description'] as String?,
        entities = decodeMapList(data['entities']);

  final Map<String, dynamic> raw;
  final String id;
  final String type;
  final String? typeForFrom;
  final String? title;
  final String? description;
  final List<Map<String, dynamic>> entities;
}

/// Landing page (collection of blocks).
class YLanding {
  YLanding(Map<String, dynamic> data)
      : raw = data,
        pumpkin = data['pumpkin'] as bool? ?? false,
        contentId = data['content_id']?.toString(),
        blocks = (data['blocks'] as List?)
                ?.whereType<Map>()
                .map((b) => YLandingBlock(Map<String, dynamic>.from(b)))
                .toList() ??
            const [];

  final Map<String, dynamic> raw;
  final bool pumpkin;
  final String? contentId;
  final List<YLandingBlock> blocks;
}

/// Feed envelope returned by `/feed`.
class YFeed {
  YFeed(Map<String, dynamic> data)
      : raw = data,
        canGetMoreEvents = data['can_get_more_events'] as bool? ?? false,
        pumpkin = data['pumpkin'] as bool? ?? false,
        isWizardPassed = data['is_wizard_passed'] as bool? ?? false,
        nextRevision = data['next_revision'] as String?,
        today = data['today'] as String?,
        days = decodeMapList(data['days']),
        headlines = decodeMapList(data['headlines']),
        generatedPlaylists = decodeMapList(data['generated_playlists']),
        events = decodeMapList(data['events']);

  final Map<String, dynamic> raw;
  final bool canGetMoreEvents;
  final bool pumpkin;
  final bool isWizardPassed;
  final String? nextRevision;
  final String? today;
  final List<Map<String, dynamic>> days;
  final List<Map<String, dynamic>> headlines;
  final List<Map<String, dynamic>> generatedPlaylists;
  final List<Map<String, dynamic>> events;
}
