import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'sky_defender_game.dart';

class Meteor extends SpriteComponent with HasGameRef<SkyDefenderGame> {
  static const double speed = 200.0;
  late double gameHeight;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set size and anchor
    size = Vector2(30, 30);
    anchor = Anchor.center;

    // Get game dimensions
    gameHeight = gameRef.size.y;

    // Try to load sprite, fall back to colored circle
    try {
      sprite = await gameRef.loadSprite('m.png');
    } catch (e) {
      // Fallback to colored circle if sprite not found
      paint = Paint()..color = Colors.red;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move down
    position.y += speed * dt;

    // Check if meteor reached bottom
    if (position.y > gameHeight + size.y) {
      // Notify game that meteor was missed
      gameRef.onMeteorMissed();
      // Remove from parent
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (sprite != null) {
      // Render sprite if available
      super.render(canvas);
    } else {
      // Render as circle if no sprite
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
    }
  }

  // Method to destroy meteor (called when hit by bullet)
  void destroy() {
    removeFromParent();
  }
}
