import 'dart:ui';

class HexColor extends Color {
  HexColor(String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    var normalizedHex = hexColor.toUpperCase().replaceAll('#', '');
    if (normalizedHex.length == 6) {
      normalizedHex = 'FF$normalizedHex';
    }
    return int.parse(normalizedHex, radix: 16);
  }
}
