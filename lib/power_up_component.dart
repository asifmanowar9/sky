import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'sky_defender_game.dart';
import 'player_component.dart';

enum PowerUpType {
  rapidFire, // Increases fire rate by 50% for 5s
  shield, // Prevents 1 life loss for 8s
}

class PowerUp extends SpriteComponent
    with HasGameReference<SkyDefenderGame>, CollisionCallbacks {
  final PowerUpType type;
  final double fallSpeed = 150.0;
  double? gameHeight;
  CircleHitbox? _hitbox;

  PowerUp({required this.type})
    : super(
        size: Vector2(40, 40),
        anchor: Anchor.center,
        priority: 7, // Render power-ups above meteors but below player
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Reuse shared sprite instance from game based on type
    sprite = type == PowerUpType.rapidFire
        ? game.rapidFireSprite
        : game.shieldSprite;

    // Add circular hitbox for collision detection
    _hitbox = CircleHitbox();
    await add(_hitbox!);
  }

  @override
  void onMount() {
    super.onMount();

    // Get game dimensions after mounting (when game reference is guaranteed)
    gameHeight = game.size.y;
  }

  @override
  void onRemove() {
    // Clean up hitbox reference
    _hitbox = null;
    super.onRemove();
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

    // Auto-remove if reaches bottom (only if gameHeight is initialized)
    if (gameHeight != null && position.y > gameHeight! + size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Player) {
      // Handle collision with player
      game.onPlayerCollectPowerUp(this);
    }
  }

  // Called when collected by player
  void onCollected() {
    removeFromParent();
  }

  // Activate the power-up effect
  void activate() {
    switch (type) {
      case PowerUpType.rapidFire:
        game.powerUpState.activateRapidFire();
        break;
      case PowerUpType.shield:
        game.powerUpState.activateShield();
        break;
    }
  }

  // Get the color for this power-up type (for particle effects)
  Color getColor() {
    return _getColor();
  }
}
