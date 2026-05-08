import 'dart:ui' show Color;

Color hexColor(String hex) {
  hex = hex.replaceAll('#', '');
  return Color(int.parse('FF$hex', radix: 16));
}

int parseHexColor(String hex) {
  hex = hex.replaceAll('#', '');
  return int.parse('FF$hex', radix: 16);
}
