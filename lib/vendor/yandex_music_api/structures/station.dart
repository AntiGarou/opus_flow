import 'common.dart';

/// Rotor station identifier (tag + type).
class YStationId {
  YStationId(Map<String, dynamic> data)
      : type = data['type'] as String? ?? '',
        tag = data['tag'] as String? ?? '';

  final String type;
  final String tag;

  String get id => '$type:$tag';
}

/// Rotor station.
class YStation {
  YStation(Map<String, dynamic> data)
      : raw = data,
        id = data['id'] is Map
            ? YStationId(Map<String, dynamic>.from(data['id'] as Map))
            : YStationId(const {}),
        parentId = data['parent_id'] is Map
            ? YStationId(Map<String, dynamic>.from(data['parent_id'] as Map))
            : null,
        name = data['name'] as String? ?? '',
        icon = data['icon'] is Map
            ? Icon(Map<String, dynamic>.from(data['icon'] as Map))
            : null,
        mtsIcon = data['mts_icon'] is Map
            ? Icon(Map<String, dynamic>.from(data['mts_icon'] as Map))
            : null,
        idForFrom = data['id_for_from'] as String?,
        restrictions = data['restrictions'] is Map
            ? Map<String, dynamic>.from(data['restrictions'] as Map)
            : const {},
        restrictions2 = data['restrictions2'] is Map
            ? Map<String, dynamic>.from(data['restrictions2'] as Map)
            : const {};

  final Map<String, dynamic> raw;
  final YStationId id;
  final YStationId? parentId;
  final String name;
  final Icon? icon;
  final Icon? mtsIcon;
  final String? idForFrom;
  final Map<String, dynamic> restrictions;
  final Map<String, dynamic> restrictions2;
}

/// A station result (the wrapper the API usually returns).
class YStationResult {
  YStationResult(Map<String, dynamic> data)
      : station = data['station'] is Map
            ? YStation(Map<String, dynamic>.from(data['station'] as Map))
            : null,
        settings = data['settings'] is Map
            ? Map<String, dynamic>.from(data['settings'] as Map)
            : const {},
        settings2 = data['settings2'] is Map
            ? Map<String, dynamic>.from(data['settings2'] as Map)
            : const {},
        adParams = data['ad_params'] is Map
            ? Map<String, dynamic>.from(data['ad_params'] as Map)
            : null,
        explanation = data['explanation'] as String?,
        prerolls = decodeMapList(data['prerolls']),
        rupTitle = data['rup_title'] as String?,
        rupDescription = data['rup_description'] as String?;

  final YStation? station;
  final Map<String, dynamic> settings;
  final Map<String, dynamic> settings2;
  final Map<String, dynamic>? adParams;
  final String? explanation;
  final List<Map<String, dynamic>> prerolls;
  final String? rupTitle;
  final String? rupDescription;
}
