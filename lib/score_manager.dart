import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
  ),
);

class ScoreManager {
  static const String _highScoreKey = 'high_score';

  /// Get the stored high score from local storage
  /// Returns 0 if no high score exists or if loading fails
  Future<int> getHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final highScore = prefs.getInt(_highScoreKey) ?? 0;
      logger.i('High score loaded: $highScore');
      return highScore;
    } catch (e) {
      logger.e('Failed to load high score: $e');
      return 0; // Default to 0 on error
    }
  }

  /// Save a new high score to local storage
  Future<void> saveHighScore(int score) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_highScoreKey, score);
      logger.i('High score saved: $score');
    } catch (e) {
      logger.e('Failed to save high score: $e');
      // Don't throw - graceful degradation
    }
  }

  /// Check if the current score is a new high score
  bool isNewHighScore(int currentScore, int highScore) {
    return currentScore > highScore;
  }
}
