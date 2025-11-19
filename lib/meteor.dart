import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'sky_defender_game.dart';

enum MeteorType {
  small, // 10 points, 1.0x speed, size 30
  medium, // 20 points, 0.8x speed, size 45
  large, // 30 points, 0.6x speed, size 60
}

class Meteor extends PositionComponent with HasGameReference<SkyDefenderGame> {
  double speed;
  late double gameHeight;
  MeteorType type;
  int pointValue;
  double speedMultiplier;
  Sprite? sprite;
  late Paint paint;

  Meteor({this.speed = 200.0, this.type = MeteorType.small})
    : pointValue = _getPointValue(type),
      speedMultiplier = _getSpeedMultiplier(type);

  // Factory constructor for random meteor with weighted selection
  factory Meteor.random({double speed = 200.0}) {
    final random = Random();
    final roll = random.nextDouble();

    MeteorType selectedType;
    if (roll < 0.6) {
      selectedType = MeteorType.small; // 60% chance
    } else if (roll < 0.9) {
      selectedType = MeteorType.medium; // 30% chance
    } else {
      selectedType = MeteorType.large; // 10% chance
    }

    return Meteor(speed: speed, type: selectedType);
  }

  // Factory constructor for specific type
  factory Meteor.ofType(MeteorType type, {double speed = 200.0}) {
    return Meteor(speed: speed, type: type);
  }

  static int _getPointValue(MeteorType type) {
    switch (type) {
      case MeteorType.small:
        return 10;
      case MeteorType.medium:
        return 20;
      case MeteorType.large:
        return 30;
    }
  }

  static double _getSpeedMultiplier(MeteorType type) {
    switch (type) {
      case MeteorType.small:
        return 1.0;
      case MeteorType.medium:
        return 0.8;
      case MeteorType.large:
        return 0.6;
    }
  }

  static double _getSize(MeteorType type) {
    switch (type) {
      case MeteorType.small:
        return 30.0;
      case MeteorType.medium:
        return 45.0;
      case MeteorType.large:
        return 60.0;
    }
  }

  static Color _getColor(MeteorType type) {
    switch (type) {
      case MeteorType.small:
        return Colors.red;
      case MeteorType.medium:
        return Colors.orange;
      case MeteorType.large:
        return Colors.brown;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set size based on type
    final meteorSize = _getSize(type);
    size = Vector2(meteorSize, meteorSize);
    anchor = Anchor.center;

    // Get game dimensions
    gameHeight = game.size.y;

    // Initialize paint with type-specific color
    paint = Paint()..color = _getColor(type);

    // Try to load sprite, fall back to colored circle
    try {
      sprite = await game.loadSprite('meteor.png');
    } catch (e) {
      // Fallback to colored circle with type-specific color
      sprite = null;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move down with speed multiplier based on type
    position.y += speed * speedMultiplier * dt;

    // Check if meteor reached bottom
    if (position.y > gameHeight + size.y) {
      // Notify game that meteor was missed
      game.onMeteorMissed();
      // Remove from parent
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (sprite != null) {
      // Render sprite if available
      sprite!.render(canvas, size: size);
    } else {
      // Render as colored circle if no sprite
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
    }
  }

  // Method to destroy meteor (called when hit by bullet)
  void destroy() {
    removeFromParent();
  }

  // Get the color for this meteor type (for particle effects)
  Color getColor() {
    return _getColor(type);
  }
}
