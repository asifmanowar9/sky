import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Player extends PositionComponent with HasGameReference {
  static const double speed = 300.0;
  late double gameWidth;
  late double gameHeight;
  Sprite? sprite;
  final Paint paint = Paint()..color = Colors.blue;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set size and anchor
    size = Vector2(50, 50);
    anchor = Anchor.center;

    // Get game dimensions
    gameWidth = game.size.x;
    gameHeight = game.size.y;

    // Position at bottom center
    position = Vector2(gameWidth / 2, gameHeight - size.y / 2 - 50);

    // Try to load sprite, fall back to colored rectangle
    try {
      sprite = await game.loadSprite('plane.jpg');
    } catch (e) {
      // Fallback to colored rectangle if sprite not found
      sprite = null;
    }
  }

  @override
  void render(Canvas canvas) {
    if (sprite != null) {
      // Render sprite if available
      sprite!.render(canvas, size: size);
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
