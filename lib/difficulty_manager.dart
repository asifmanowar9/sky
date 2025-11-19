import 'dart:math';

/// Manages difficulty progression based on player score
/// Wave advances every 100 points, increasing spawn rate and meteor speed
class DifficultyManager {
  static const int pointsPerWave = 100;
  static const int maxWave = 10;

  // Base values
  static const double baseSpawnInterval = 1.5;
  static const double baseSpeed = 200.0;

  // Progression rates
  static const double spawnIntervalDecreasePerWave = 0.1;
  static const double speedIncreasePerWave = 20.0;

  // Limits
  static const double minSpawnInterval = 0.5;
  static const double maxSpeed = 400.0;

  int _currentWave = 1;

  /// Get the current wave number
  int get currentWave => _currentWave;

  /// Update difficulty based on current score
  void updateDifficulty(int score) {
    // Calculate wave from score (every 100 points = 1 wave)
    int calculatedWave = (score ~/ pointsPerWave) + 1;

    // Cap at max wave
    _currentWave = min(calculatedWave, maxWave);
  }

  /// Get the meteor spawn interval for current wave
  double getMeteorSpawnInterval() {
    double interval =
        baseSpawnInterval - ((_currentWave - 1) * spawnIntervalDecreasePerWave);
    return max(interval, minSpawnInterval);
  }

  /// Get the meteor speed for current wave
  double getMeteorSpeed() {
    double speed = baseSpeed + ((_currentWave - 1) * speedIncreasePerWave);
    return min(speed, maxSpeed);
  }

  /// Get the current wave number
  int getCurrentWave() {
    return _currentWave;
  }

  /// Reset difficulty to initial state
  void reset() {
    _currentWave = 1;
  }
}
