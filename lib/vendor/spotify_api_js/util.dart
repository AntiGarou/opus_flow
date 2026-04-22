/// Utility functions. Dart port of spotify-api.js `Util.ts`.

/// Converts a hex string into an `[r, g, b, a]` tuple.
/// Alpha is `1.0` if not part of the hex string.
/// Accepts 3, 4, 6, or 8-char hex (optionally prefixed by `#`).
List<num> hexToRgb(String hexString) {
  var hex = hexString.startsWith('#') ? hexString.substring(1) : hexString;
  num alpha = 1;
  final valid = RegExp(r'^[0-9A-Fa-f]+$');
  if (!valid.hasMatch(hex)) {
    throw ArgumentError('Invalid hex code provided: $hexString');
  }

  if (hex.length == 8) {
    alpha = int.parse(hex.substring(6, 8), radix: 16) / 255;
    hex = hex.substring(0, 6);
  }
  if (hex.length == 4) {
    final ch = hex.substring(3, 4);
    alpha = int.parse('$ch$ch', radix: 16) / 255;
    hex = hex.substring(0, 3);
  }
  if (hex.length == 3) {
    hex = '${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}';
  }
  if (hex.length != 6) {
    throw ArgumentError('Invalid hex code provided: $hexString');
  }

  final value = int.parse(hex, radix: 16);
  return [value >> 16, (value >> 8) & 255, value & 255, alpha];
}

/// Spotify scannable code image URL.
/// Dart port of the shared `makeCodeImage` behaviour in the TypeScript structures.
String makeCodeImage(String uri, [String color = '1DB954']) {
  final rgb = hexToRgb(color);
  final fg = rgb[0] > 150 ? 'black' : 'white';
  return 'https://scannables.scdn.co/uri/plain/jpeg/#$color/$fg/1080/$uri';
}
