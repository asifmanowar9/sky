import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Bullet extends RectangleComponent with HasGameRef {
  static const double speed = 400.0;
  late double gameHeight;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set size and anchor
    size = Vector2(5, 10);
    anchor = Anchor.center;

    // Get game dimensions
    gameHeight = gameRef.size.y;

    // Use colored rectangle (no sprite loading)
    paint = Paint()..color = Colors.yellow;
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

  // Method to destroy bullet (called when it hits something)
  void destroy() {
    removeFromParent();
  }
}
