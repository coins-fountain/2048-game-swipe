import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static Future<void> saveGameState(List<int> grid, int score, int highScore) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('grid', jsonEncode(grid));
    await prefs.setInt('score', score);
    await prefs.setInt('highScore', highScore);
  }

  static Future<Map<String, dynamic>> loadGameState() async {
    final prefs = await SharedPreferences.getInstance();
    String? gridRaw = prefs.getString('grid');
    return {
      'grid': gridRaw != null ? List<int>.from(jsonDecode(gridRaw)) : null,
      'score': prefs.getInt('score') ?? 0,
      'highScore': prefs.getInt('highScore') ?? 0,
    };
  }
}