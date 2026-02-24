import 'package:shared_preferences/shared_preferences.dart';

class GameData {
  static Future<void> saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    int currentHigh = prefs.getInt('high_score') ?? 0;
    if (score > currentHigh) {
      await prefs.setInt('high_score', score);
    }
  }
}