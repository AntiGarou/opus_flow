/// Yandex user / account info.
class YUser {
  YUser(Map<String, dynamic> data)
      : raw = data,
        uid = data['uid']?.toString() ?? '',
        login = data['login'] as String?,
        fullName = data['full_name'] as String?,
        firstName = data['first_name'] as String?,
        secondName = data['second_name'] as String?,
        displayName = data['display_name'] as String?,
        sex = data['sex'] as String?,
        verified = data['verified'] as bool? ?? false,
        hasInfoForAppMetrica = data['has_info_for_app_metrica'] as bool? ?? false,
        avatarHash = data['avatar_hash'] as String?,
        serviceAvailable = data['service_available'] as bool? ?? true,
        hostedUser = data['hosted_user'] as bool? ?? false,
        birthday = data['birthday'] as String?,
        registeredAt = data['registered_at'] as String?,
        hasEmail = data['has_email'] as bool? ?? false,
        region = data['region'] as int?;

  final Map<String, dynamic> raw;
  final String uid;
  final String? login;
  final String? fullName;
  final String? firstName;
  final String? secondName;
  final String? displayName;
  final String? sex;
  final bool verified;
  final bool hasInfoForAppMetrica;
  final String? avatarHash;
  final bool serviceAvailable;
  final bool hostedUser;
  final String? birthday;
  final String? registeredAt;
  final bool hasEmail;
  final int? region;
}

/// Account envelope returned by `/account/status`.
class YStatus {
  YStatus(Map<String, dynamic> data)
      : raw = data,
        account = data['account'] is Map
            ? YUser(Map<String, dynamic>.from(data['account'] as Map))
            : null,
        permissions = data['permissions'] is Map
            ? Map<String, dynamic>.from(data['permissions'] as Map)
            : const {},
        subscription = data['subscription'] is Map
            ? Map<String, dynamic>.from(data['subscription'] as Map)
            : null,
        plus = data['plus'] is Map
            ? Map<String, dynamic>.from(data['plus'] as Map)
            : null,
        defaultEmail = data['default_email'] is Map
            ? Map<String, dynamic>.from(data['default_email'] as Map)
            : null,
        skipsPerHour = data['skips_per_hour'] as int?,
        stationExists = data['station_exists'] as bool? ?? false,
        premiumRegion = data['premium_region'] as int?,
        premiumRegionSet = data['premium_region_set'] as bool? ?? false;

  final Map<String, dynamic> raw;
  final YUser? account;
  final Map<String, dynamic> permissions;
  final Map<String, dynamic>? subscription;
  final Map<String, dynamic>? plus;
  final Map<String, dynamic>? defaultEmail;
  final int? skipsPerHour;
  final bool stationExists;
  final int? premiumRegion;
  final bool premiumRegionSet;
}
