import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Player extends SpriteComponent with HasGameRef {
  static const double speed = 300.0;
  late double gameWidth;
  late double gameHeight;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set size and anchor
    size = Vector2(50, 50);
    anchor = Anchor.center;

    // Get game dimensions
    gameWidth = gameRef.size.x;
    gameHeight = gameRef.size.y;

    // Position at bottom center
    position = Vector2(gameWidth / 2, gameHeight - size.y / 2 - 50);

    // Try to load sprite, fall back to colored rectangle
    try {
      sprite = await gameRef.loadSprite('plane.jpg');
    } catch (e) {
      // Fallback to colored rectangle if sprite not found
      paint = Paint()..color = Colors.blue;
    }
  }

  @override
  void render(Canvas canvas) {
    if (sprite != null) {
      // Render sprite if available
      super.render(canvas);
    } else {
      // Render as blue rectangle if no sprite
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
    }
  }

  void moveLeft(double dt) {
    position.x -= speed * dt;
    // Clamp to left screen bound
    if (position.x - size.x / 2 < 0) {
      position.x = size.x / 2;
    }
  }

  void moveRight(double dt) {
    position.x += speed * dt;
    // Clamp to right screen bound
    if (position.x + size.x / 2 > gameWidth) {
      position.x = gameWidth - size.x / 2;
    }
  }

  void moveTo(double targetX) {
    position.x = targetX.clamp(size.x / 2, gameWidth - size.x / 2);
  }

  Vector2 get centerPosition => Vector2(position.x, position.y - size.y / 2);
}
