import 'dart:math';
import 'dart:async';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/events.dart';
import 'player.dart';
import 'meteor.dart';
import 'bullet.dart';

class SkyDefenderGame extends FlameGame
    with TapDetector, PanDetector, HasCollisionDetection {
  late Player player;

  double meteorSpawnTimer = 0;
  final double meteorSpawnInterval = 1.5;

  // Add auto-firing variables
  double bulletFireTimer = 0;
  final double bulletFireInterval = 0.3;

  final Random random = Random();

  // Add stream controllers for UI updates
  final StreamController<int> _scoreController =
      StreamController<int>.broadcast();
  final StreamController<int> _livesController =
      StreamController<int>.broadcast();

  Stream<int> get scoreStream => _scoreController.stream;
  Stream<int> get livesStream => _livesController.stream;

  int _score = 0;
  int _lives = 3;
  bool isGameOver = false;
  bool hasGameStarted = false; // Add game state

  // Add getters and setters to trigger stream updates
  int get score => _score;
  set score(int value) {
    _score = value;
    _scoreController.add(_score);
  }

  int get lives => _lives;
  set lives(int value) {
    _lives = value;
    _livesController.add(_lives);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add player component
    player = Player();
    add(player);

    // Show start screen initially
    overlays.add('StartScreen');

    // Initialize streams
    _scoreController.add(_score);
    _livesController.add(_lives);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Don't update game logic if game hasn't started or is over
    if (!hasGameStarted || isGameOver) return;

    // Spawn meteors every 1.5 seconds
    meteorSpawnTimer += dt;
    if (meteorSpawnTimer >= meteorSpawnInterval) {
      spawnMeteor();
      meteorSpawnTimer = 0;
    }

    // Auto-fire bullets continuously
    bulletFireTimer += dt;
    if (bulletFireTimer >= bulletFireInterval) {
      fireBullet();
      bulletFireTimer = 0;
    }

    // Check for collisions between bullets and meteors
    checkCollisions();
  }

  void checkCollisions() {
    final bullets = children.whereType<Bullet>().toList();
    final meteors = children.whereType<Meteor>().toList();

    for (final bullet in bullets) {
      for (final meteor in meteors) {
        if (bullet.toRect().overlaps(meteor.toRect())) {
          // Collision detected!
          bullet.destroy();
          meteor.destroy();

          // Increment score (this will trigger stream update)
          score += 10;

          break; // Exit inner loop since bullet is destroyed
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
    print('Game Started!');
  }

  void spawnMeteor() {
    final meteor = Meteor();
    // Random X position across screen width
    meteor.position = Vector2(random.nextDouble() * size.x, -meteor.size.y);
    add(meteor);
  }

  void fireBullet() {
    final bullet = Bullet();
    bullet.position = player.centerPosition;
    add(bullet);
  }

  // Called when a meteor reaches the bottom
  void onMeteorMissed() {
    if (isGameOver || !hasGameStarted) return;

    // Decrease lives (this will trigger stream update)
    lives--;

    if (lives <= 0) {
      gameOver();
    }
  }

  void gameOver() {
    isGameOver = true;

    // Remove score display and show game over overlay
    overlays.remove('ScoreDisplay');
    overlays.add('GameOver');

    print('Game Over! Final Score: $score');
  }

  void restartGame() {
    // Reset game state
    isGameOver = false;
    hasGameStarted = true; // Start game immediately
    score = 0; // This will trigger stream update
    lives = 3; // This will trigger stream update
    meteorSpawnTimer = 0;
    bulletFireTimer = 0;

    // Remove all game objects except player
    removeWhere((component) => component is Meteor || component is Bullet);

    // Go directly to game (skip start screen)
    overlays.remove('GameOver');
    overlays.add('ScoreDisplay');

    print('Game Restarted!');
  }

  void goToStartScreen() {
    // Reset game state
    isGameOver = false;
    hasGameStarted = false; // Return to start screen
    score = 0; // This will trigger stream update
    lives = 3; // This will trigger stream update
    meteorSpawnTimer = 0;
    bulletFireTimer = 0;

    // Remove all game objects except player
    removeWhere((component) => component is Meteor || component is Bullet);

    // Go back to start screen
    overlays.remove('GameOver');
    overlays.add('StartScreen');

    print('Returned to Start Screen!');
  }

  @override
  void onRemove() {
    _scoreController.close();
    _livesController.close();
    super.onRemove();
  }
}
