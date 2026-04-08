import 'package:flutter/material.dart';

/// Lightweight replacement for the `hexcolor` package.
///
/// Accepts strings like: `#RRGGBB`, `RRGGBB`, `#AARRGGBB`, `AARRGGBB`.
class HexColor extends Color {
  HexColor(final String hex) : super(_parse(hex));

  static int _parse(String input) {
    var hex = input.trim();
    if (hex.startsWith('#')) hex = hex.substring(1);

    // Support short forms: RGB / ARGB.
    if (hex.length == 3) {
      hex = '${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}';
    } else if (hex.length == 4) {
      hex =
          '${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}${hex[3]}${hex[3]}';
    }

    if (hex.length == 6) {
      hex = 'FF$hex';
    }

    if (hex.length != 8) {
      throw FormatException('Invalid hex color: $input');
    }

    return int.parse(hex, radix: 16);
  }
}

