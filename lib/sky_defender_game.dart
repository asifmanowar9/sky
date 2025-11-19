import 'dart:math';
import 'dart:async';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'player.dart';
import 'meteor.dart';
import 'bullet.dart';
import 'difficulty_manager.dart';
import 'power_up.dart';
import 'power_up_state.dart';
import 'particle_effect.dart';
import 'score_manager.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
  ),
);

class SkyDefenderGame extends FlameGame
    with TapDetector, PanDetector, HasCollisionDetection {
  late Player player;

  double meteorSpawnTimer = 0;

  // Add auto-firing variables
  double bulletFireTimer = 0;
  double bulletFireInterval = 0.3;

  final Random random = Random();

  // Difficulty manager
  final DifficultyManager difficultyManager = DifficultyManager();

  // Power-up system
  final PowerUpState powerUpState = PowerUpState();
  double powerUpSpawnTimer = 0;
  double nextPowerUpSpawn = 15.0; // Random 10-20s

  // High score system
  final ScoreManager scoreManager = ScoreManager();
  int _highScore = 0;
  bool _isNewHighScore = false;

  // Add stream controllers for UI updates
  final StreamController<int> _scoreController =
      StreamController<int>.broadcast();
  final StreamController<int> _livesController =
      StreamController<int>.broadcast();
  final StreamController<int> _waveController =
      StreamController<int>.broadcast();
  final StreamController<int> _highScoreController =
      StreamController<int>.broadcast();

  Stream<int> get scoreStream => _scoreController.stream;
  Stream<int> get livesStream => _livesController.stream;
  Stream<int> get waveStream => _waveController.stream;
  Stream<int> get highScoreStream => _highScoreController.stream;
  Stream<PowerUpState> get powerUpStream => powerUpState.stateStream;

  int _score = 0;
  int _lives = 3;
  bool isGameOver = false;
  bool hasGameStarted = false; // Add game state
  bool isPaused = false; // Pause state

  // Screen shake variables
  Vector2 _cameraOffset = Vector2.zero();
  double _shakeIntensity = 0.0;
  double _shakeDuration = 0.0;

  // Add getters and setters to trigger stream updates
  int get score => _score;
  set score(int value) {
    int previousWave = difficultyManager.currentWave;
    _score = value;
    _scoreController.add(_score);

    // Update difficulty based on new score
    difficultyManager.updateDifficulty(_score);

    // If wave changed, notify listeners
    if (difficultyManager.currentWave != previousWave) {
      _waveController.add(difficultyManager.currentWave);
      logger.i('Wave ${difficultyManager.currentWave} started!');
    }
  }

  int get lives => _lives;
  set lives(int value) {
    _lives = value;
    _livesController.add(_lives);
  }

  int get highScore => _highScore;
  set highScore(int value) {
    _highScore = value;
    _highScoreController.add(_highScore);
  }

  bool get isNewHighScore => _isNewHighScore;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load high score from storage
    _highScore = await scoreManager.getHighScore();

    // Add player component
    player = Player();
    add(player);

    // Show start screen initially
    overlays.add('StartScreen');

    // Initialize streams
    _scoreController.add(_score);
    _livesController.add(_lives);
    _waveController.add(difficultyManager.currentWave);
    _highScoreController.add(_highScore);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Don't update game logic if paused
    if (isPaused) return;

    // Update screen shake
    if (_shakeDuration > 0) {
      _shakeDuration -= dt;
      // Random offset for shake effect
      _cameraOffset = Vector2(
        (random.nextDouble() - 0.5) * _shakeIntensity * 2,
        (random.nextDouble() - 0.5) * _shakeIntensity * 2,
      );
      camera.viewfinder.position = _cameraOffset;

      if (_shakeDuration <= 0) {
        // Reset camera when shake ends
        _cameraOffset = Vector2.zero();
        camera.viewfinder.position = _cameraOffset;
      }
    }

    // Don't update game logic if game hasn't started or is over
    if (!hasGameStarted || isGameOver) return;

    // Spawn meteors based on difficulty
    meteorSpawnTimer += dt;
    double currentSpawnInterval = difficultyManager.getMeteorSpawnInterval();
    if (meteorSpawnTimer >= currentSpawnInterval) {
      spawnMeteor();
      meteorSpawnTimer = 0;
    }

    // Spawn power-ups at random intervals
    powerUpSpawnTimer += dt;
    if (powerUpSpawnTimer >= nextPowerUpSpawn) {
      spawnPowerUp();
      powerUpSpawnTimer = 0;
      // Set next spawn time randomly between 10-20 seconds
      nextPowerUpSpawn = 10.0 + random.nextDouble() * 10.0;
    }

    // Auto-fire bullets continuously with modified rate if rapid fire is active
    double currentFireInterval = powerUpState.rapidFireActive
        ? bulletFireInterval *
              0.5 // 50% faster (half the interval)
        : bulletFireInterval;

    bulletFireTimer += dt;
    if (bulletFireTimer >= currentFireInterval) {
      fireBullet();
      bulletFireTimer = 0;
    }

    // Check for collisions
    checkCollisions();
  }

  void checkCollisions() {
    final bullets = children.whereType<Bullet>().toList();
    final meteors = children.whereType<Meteor>().toList();
    final powerUps = children.whereType<PowerUp>().toList();

    // Check bullet-meteor collisions
    for (final bullet in bullets) {
      for (final meteor in meteors) {
        if (bullet.toRect().overlaps(meteor.toRect())) {
          // Collision detected!

          // Spawn particle effect at collision point
          spawnParticleEffect(
            position: meteor.position,
            color: meteor.getColor(),
            particleCount: 10,
          );

          bullet.destroy();

          // Award points based on meteor type
          score += meteor.pointValue;

          meteor.destroy();

          break; // Exit inner loop since bullet is destroyed
        }
      }
    }

    // Check player-meteor collisions
    for (final meteor in meteors) {
      if (player.toRect().overlaps(meteor.toRect())) {
        // Collision detected with player!

        // Spawn particle effect at collision point
        spawnParticleEffect(
          position: meteor.position,
          color: meteor.getColor(),
          particleCount: 15,
        );

        // Trigger screen shake effect
        triggerScreenShake(intensity: 15.0, duration: 0.4);

        // Check if shield is active
        if (powerUpState.shieldActive) {
          // Shield prevents life loss and is consumed
          powerUpState.consumeShield();
          logger.i('Shield absorbed meteor collision!');
        } else {
          // Decrease lives (this will trigger stream update)
          lives--;
          logger.w('Player hit by meteor! Lives remaining: $lives');

          if (lives <= 0) {
            gameOver();
          }
        }

        // Destroy the meteor
        meteor.destroy();
      }
    }

    // Check player-powerup collisions
    for (final powerUp in powerUps) {
      if (player.toRect().overlaps(powerUp.toRect())) {
        // Spawn particle effect at collection point
        spawnParticleEffect(
          position: powerUp.position,
          color: powerUp.getColor(),
          particleCount: 12,
        );

        // Collect power-up
        powerUp.onCollected();

        // Activate power-up effect
        switch (powerUp.type) {
          case PowerUpType.rapidFire:
            powerUpState.activateRapidFire();
            logger.i('Rapid Fire activated!');
            break;
          case PowerUpType.shield:
            powerUpState.activateShield();
            logger.i('Shield activated!');
            break;
        }
      }
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    // Remove manual firing since we now auto-fire
  }

  @override
  void onPanStart(DragStartInfo info) {
    if (hasGameStarted && !isGameOver) {
      player.moveTo(info.eventPosition.global.x);
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (hasGameStarted && !isGameOver) {
      player.moveTo(info.eventPosition.global.x);
    }
  }

  void startGame() {
    hasGameStarted = true;
    overlays.remove('StartScreen');
    overlays.add('ScoreDisplay');
    logger.i('Game started');
  }

  void spawnMeteor() {
    // Get current difficulty speed
    double currentSpeed = difficultyManager.getMeteorSpeed();
    final meteor = Meteor.random(speed: currentSpeed);
    // Random X position across screen width
    meteor.position = Vector2(random.nextDouble() * size.x, -meteor.size.y);
    add(meteor);
  }

  void spawnPowerUp() {
    // Randomly select power-up type (50/50 chance)
    final type = random.nextBool() ? PowerUpType.rapidFire : PowerUpType.shield;
    final powerUp = PowerUp(type: type);

    // Random X position across screen width
    powerUp.position = Vector2(random.nextDouble() * size.x, -powerUp.size.y);
    add(powerUp);

    logger.i('Power-up spawned: ${type.name}');
  }

  void fireBullet() {
    final bullet = Bullet();
    bullet.position = player.centerPosition;
    add(bullet);
  }

  // Called when a meteor reaches the bottom
  void onMeteorMissed() {
    if (isGameOver || !hasGameStarted) return;

    // Trigger screen shake effect
    triggerScreenShake(intensity: 10.0, duration: 0.3);

    // Check if shield is active
    if (powerUpState.shieldActive) {
      // Shield prevents life loss and is consumed
      powerUpState.consumeShield();
      logger.i('Shield absorbed meteor hit!');
      return;
    }

    // Decrease lives (this will trigger stream update)
    lives--;

    if (lives <= 0) {
      gameOver();
    }
  }

  /// Spawn a particle effect at the specified position
  void spawnParticleEffect({
    required Vector2 position,
    required Color color,
    int particleCount = 10,
    double lifetime = 0.4,
  }) {
    final effect = ParticleEffect(color: color, position: position);
    effect.spawn(count: particleCount, lifetime: lifetime);
    add(effect);
  }

  /// Trigger screen shake effect
  void triggerScreenShake({
    required double intensity,
    required double duration,
  }) {
    _shakeIntensity = intensity;
    _shakeDuration = duration;
  }

  /// Pause the game
  void pauseGame() {
    // Only allow pausing during active gameplay
    if (!hasGameStarted || isGameOver || isPaused) return;

    isPaused = true;
    paused = true; // Flame's built-in pause
    overlays.remove('ScoreDisplay');
    overlays.add('PauseMenu');
    logger.i('Game paused');
  }

  /// Resume the game from pause
  void resumeGame() {
    if (!isPaused) return;

    isPaused = false;
    paused = false; // Flame's built-in resume
    overlays.remove('PauseMenu');
    overlays.add('ScoreDisplay');
    logger.i('Game resumed');
  }

  void gameOver() {
    isGameOver = true;

    // Check for new high score
    if (scoreManager.isNewHighScore(score, highScore)) {
      _isNewHighScore = true;
      highScore = score; // Update high score in memory
      scoreManager.saveHighScore(score); // Save to storage
      logger.i('New high score achieved: $score');
    } else {
      _isNewHighScore = false;
    }

    // Remove score display and show game over overlay
    overlays.remove('ScoreDisplay');
    overlays.add('GameOver');

    logger.i('Game over - Final score: $score');
  }

  void restartGame() {
    // Reset game state
    isGameOver = false;
    hasGameStarted = true; // Start game immediately
    _isNewHighScore = false; // Reset new high score flag

    // Reset difficulty manager
    difficultyManager.reset();

    // Reset power-up state
    powerUpState.reset();

    // Reset screen shake
    _shakeDuration = 0;
    _shakeIntensity = 0;
    _cameraOffset = Vector2.zero();
    camera.viewfinder.position = _cameraOffset;

    score = 0; // This will trigger stream update
    lives = 3; // This will trigger stream update
    meteorSpawnTimer = 0;
    bulletFireTimer = 0;
    powerUpSpawnTimer = 0;
    nextPowerUpSpawn = 15.0;

    // Remove all game objects except player
    removeWhere(
      (component) =>
          component is Meteor ||
          component is Bullet ||
          component is PowerUp ||
          component is ParticleEffect,
    );

    // Go directly to game (skip start screen)
    overlays.remove('GameOver');
    overlays.add('ScoreDisplay');

    logger.i('Game restarted');
  }

  void goToStartScreen() {
    // Check and save high score before resetting game state
    if (scoreManager.isNewHighScore(score, highScore)) {
      highScore = score; // Update high score in memory
      scoreManager.saveHighScore(score); // Save to storage
      logger.i('High score saved when returning home: $score');
    }

    // Reset game state
    isGameOver = false;
    hasGameStarted = false; // Return to start screen
    isPaused = false; // Reset pause state
    _isNewHighScore = false; // Reset new high score flag

    // Reset difficulty manager
    difficultyManager.reset();

    // Reset power-up state
    powerUpState.reset();

    // Reset screen shake
    _shakeDuration = 0;
    _shakeIntensity = 0;
    _cameraOffset = Vector2.zero();
    camera.viewfinder.position = _cameraOffset;

    score = 0; // This will trigger stream update
    lives = 3; // This will trigger stream update
    meteorSpawnTimer = 0;
    bulletFireTimer = 0;
    powerUpSpawnTimer = 0;
    nextPowerUpSpawn = 15.0;

    // Remove all game objects except player
    removeWhere(
      (component) =>
          component is Meteor ||
          component is Bullet ||
          component is PowerUp ||
          component is ParticleEffect,
    );

    // Go back to start screen
    overlays.remove('GameOver');
    overlays.remove('PauseMenu'); // Ensure PauseMenu is removed if present
    overlays.add('StartScreen');

    logger.i('Returned to start screen');
  }

  @override
  void onRemove() {
    _scoreController.close();
    _livesController.close();
    _waveController.close();
    _highScoreController.close();
    powerUpState.dispose();
    super.onRemove();
  }
}
