import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'sky_defender_game.dart';

enum PowerUpType {
  rapidFire, // Increases fire rate by 50% for 5s
  shield, // Prevents 1 life loss for 8s
}

class PowerUp extends PositionComponent with HasGameReference<SkyDefenderGame> {
  final PowerUpType type;
  final double fallSpeed = 150.0;
  late double gameHeight;
  Sprite? sprite;

  PowerUp({required this.type});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set size and anchor
    size = Vector2(40, 40);
    anchor = Anchor.center;

    // Get game dimensions
    gameHeight = game.size.y;

    // Try to load sprite, fall back to colored shapes
    try {
      final spriteName = type == PowerUpType.rapidFire
          ? 'rapidfire.png'
          : 'shield.png';
      sprite = await game.loadSprite(spriteName);
    } catch (e) {
      // Fallback to colored shapes if sprite not found
      sprite = null;
    }
  }

  Color _getColor() {
    switch (type) {
      case PowerUpType.rapidFire:
        return Colors.yellow;
      case PowerUpType.shield:
        return Colors.blue;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move down at fall speed
    position.y += fallSpeed * dt;

    // Auto-remove if reaches bottom
    if (position.y > gameHeight + size.y) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (sprite != null) {
      // Render sprite if available
      canvas.save();
      sprite!.render(canvas, size: size);
      canvas.restore();
    } else {
      // Render fallback shapes
      canvas.save();
      if (type == PowerUpType.rapidFire) {
        // Draw yellow star
        _drawStar(canvas, size.x / 2, size.y / 2, 5, size.x / 2, size.x / 4);
      } else {
        // Draw blue shield (circle with border)
        final paint = Paint()
          ..color = _getColor()
          ..style = PaintingStyle.fill;
        final borderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

        canvas.drawCircle(
          Offset(size.x / 2, size.y / 2),
          size.x / 2 - 2,
          paint,
        );
        canvas.drawCircle(
          Offset(size.x / 2, size.y / 2),
          size.x / 2 - 2,
          borderPaint,
        );
      }
      canvas.restore();
    }
  }

  void _drawStar(
    Canvas canvas,
    double cx,
    double cy,
    int points,
    double outerRadius,
    double innerRadius,
  ) {
    final paint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;

    final path = Path();
    final angle = 3.14159 / points;

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = cx + radius * math.cos(i * angle - 3.14159 / 2);
      final y = cy + radius * math.sin(i * angle - 3.14159 / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  // Called when collected by player
  void onCollected() {
    removeFromParent();
  }

  // Get the color for this power-up type (for particle effects)
  Color getColor() {
    return _getColor();
  }
}
