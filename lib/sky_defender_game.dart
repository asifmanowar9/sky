import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'player.dart';
import 'meteor.dart';
import 'bullet.dart';

class SkyDefenderGame extends FlameGame
    with TapCallbacks, HasCollisionDetection {
  late Player player;

  double meteorSpawnTimer = 0;
  final double meteorSpawnInterval = 1.5;
  final Random random = Random();
  int score = 0;
  int lives = 3;
  bool isGameOver = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add player component
    player = Player();
    add(player);

    // Show score display overlay
    overlays.add('ScoreDisplay');
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Don't update game logic if game is over
    if (isGameOver) return;

    // Spawn meteors every 1.5 seconds
    meteorSpawnTimer += dt;
    if (meteorSpawnTimer >= meteorSpawnInterval) {
      spawnMeteor();
      meteorSpawnTimer = 0;
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

          // Increment score
          score += 10;

          break; // Exit inner loop since bullet is destroyed
        }
      }
    }
  }

  @override
  bool onTapDown(TapDownEvent event) {
    if (isGameOver) {
      // Game over handling is now done by the overlay button
      return true;
    } else {
      // Fire a bullet from player's position
      fireBullet();
    }
    return true;
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
    if (isGameOver) return;

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
    score = 0;
    lives = 3;
    meteorSpawnTimer = 0;

    // Remove all game objects except player
    removeWhere((component) => component is Meteor || component is Bullet);

    print('Game Restarted!');
  }
}
