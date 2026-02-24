import 'package:flutter/material.dart';

class GameColors {
  static const Color gridBackground = Color(0xFFBBADA0);
  static const Color emptyTile = Color(0xFFCDC1B4);
  static const Color textDark = Color(0xFF776E65);
  static const Color textLight = Colors.white;

  static Color getTileColor(int value) {
    switch (value) {
      case 2: return const Color(0xFFEEE4DA);
      case 4: return const Color(0xFFEDE0C8);
      case 8: return const Color(0xFFF2B179);
      case 16: return const Color(0xFFF59563);
      case 32: return const Color(0xFFF67C5F);
      case 64: return const Color(0xFFF65E3B);
      case 128: return const Color(0xFFEDCF72);
      case 256: return const Color(0xFFEDCC61);
      case 512: return const Color(0xFFEDC850);
      case 1024: return const Color(0xFFEDC53F);
      case 2048: return const Color(0xFFEDC22E);
      default:
        return value == 0 ? emptyTile : const Color(0xFF3C3A32);
    }
  }

  static Color getTextColor(int value) {
    return value <= 4 ? textDark : textLight;
  }
}