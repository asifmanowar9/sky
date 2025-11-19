import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Bullet extends PositionComponent with HasGameReference {
  static const double speed = 400.0;
  late double gameHeight;
  Sprite? sprite;
  final Paint paint = Paint()..color = Colors.yellow;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set size and anchor
    size = Vector2(5, 10);
    anchor = Anchor.center;

    // Get game dimensions
    gameHeight = game.size.y;

    // Try to load sprite, fall back to colored rectangle
    try {
      sprite = await game.loadSprite('bullet.webp');
    } catch (e) {
      // Fallback to colored rectangle if sprite not found
      sprite = null;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move upward
    position.y -= speed * dt;

    // Remove when off screen (exits top)
    if (position.y < -size.y) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (sprite != null) {
      // Render sprite if available
      sprite!.render(canvas, size: size);
    } else {
      // Render as yellow rectangle if no sprite
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
    }
  }

  // Method to destroy bullet (called when it hits something)
  void destroy() {
    removeFromParent();
  }
}
