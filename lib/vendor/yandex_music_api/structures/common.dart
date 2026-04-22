/// Shared helpers + tiny data classes used across the Yandex port.
///
/// The Python client has many nearly-identical dataclasses. The Dart port
/// collapses the small helper ones here to keep the tree manageable while
/// retaining the shape of the JSON surface.

/// Generic JSON → `List<Map<String, dynamic>>` decoder.
List<Map<String, dynamic>> decodeMapList(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

/// Generic JSON → `List<int>` decoder.
List<int> decodeIntList(dynamic raw) {
  if (raw is! List) return const [];
  return raw.whereType<num>().map((e) => e.toInt()).toList();
}

/// Shared cover/image info.
class Cover {
  Cover(Map<String, dynamic> data)
      : type = data['type'] as String?,
        uri = data['uri'] as String?,
        itemsUri = (data['items_uri'] as List?)
            ?.whereType<String>()
            .toList() ??
            const [],
        dir = data['dir'] as String?,
        version = data['version'] as String?,
        custom = data['custom'] as bool?,
        isCustom = data['is_custom'] as bool?,
        copyrightName = data['copyright_name'] as String?,
        copyrightCline = data['copyright_cline'] as String?,
        prefix = data['prefix'] as String?,
        error = data['error'] as String?;

  final String? type;
  final String? uri;
  final List<String> itemsUri;
  final String? dir;
  final String? version;
  final bool? custom;
  final bool? isCustom;
  final String? copyrightName;
  final String? copyrightCline;
  final String? prefix;
  final String? error;

  /// Generate a full-size image URL (Yandex templates end with `%%`).
  String? imageUrl([String size = '200x200']) {
    if (uri == null) return null;
    final u = uri!.replaceAll('%%', size);
    return u.startsWith('http') ? u : 'https://$u';
  }
}

/// Icon with background/foreground URIs.
class Icon {
  Icon(Map<String, dynamic> data)
      : backgroundColor = data['background_color'] as String?,
        imageUrl = data['image_url'] as String?;

  final String? backgroundColor;
  final String? imageUrl;
}

/// Ad hoc price (used by various billing-adjacent entities).
class Price {
  Price(Map<String, dynamic> data)
      : amount = (data['amount'] as num?)?.toDouble(),
        currency = data['currency'] as String?;

  final double? amount;
  final String? currency;
}

/// Major/minor sample track shape used in rotor + charts.
class PagerInfo {
  PagerInfo(Map<String, dynamic> data)
      : total = data['total'] as int? ?? 0,
        page = data['page'] as int? ?? 0,
        perPage = data['per_page'] as int? ?? 0;

  final int total;
  final int page;
  final int perPage;
}
