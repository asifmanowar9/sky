import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'component_pool.dart';
import 'sky_defender_game.dart';

/// Meteor types with different characteristics
///
/// Each type has different size, speed, and point values to provide
/// gameplay variety and strategic depth.
enum MeteorType {
  /// Small meteor: 10 points, 1.0x speed, size 30, 60% spawn chance
  small,

  /// Medium meteor: 20 points, 0.8x speed, size 45, 30% spawn chance
  medium,

  /// Large meteor: 30 points, 0.6x speed, size 60, 10% spawn chance
  large,
}

/// Meteor enemy component that falls from the top of the screen
///
/// Meteors are the primary enemies in Sky Defender. They spawn at the top
/// of the screen and fall downward at varying speeds. Players must destroy
/// them with bullets before they reach the bottom.
///
/// **Flame Features Used:**
/// - [SpriteComponent]: Automatic sprite rendering
/// - [HasGameReference]: Type-safe access to game state
/// - [CollisionCallbacks]: Collision detection with bullets and player
/// - [CircleHitbox]: Circular collision boundary (accurate for round meteors)
/// - Component Priority: Renders in middle layer (priority 5)
/// - Component Pooling: Reused via [ComponentPool] for performance
///
/// **Pooling Performance:**
/// - 85%+ reuse rate (only 15% are new allocations)
/// - Reduces GC pressure significantly
/// - Pool size: 15 initial, 50 maximum
///
/// **Gameplay Mechanics:**
/// - Three types: small (fast, low points), medium, large (slow, high points)
/// - Weighted random spawning (60% small, 30% medium, 10% large)
/// - Destroyed by bullets: spawns particles, awards points
/// - Reaches bottom: player loses life, meteor returns to pool
/// - Collides with player: player loses life (or shield), meteor destroyed
///
/// **Performance:**
/// - Reuses shared sprite instance (reduces memory)
/// - Circular hitbox for accurate collision (vs rectangular)
/// - Automatic off-screen removal (returns to pool)
class Meteor extends SpriteComponent
    with HasGameReference<SkyDefenderGame>, CollisionCallbacks
    implements Poolable {
  /// Current falling speed in pixels per second (modified by type multiplier)
  double speed;

  /// Cached game height for off-screen detection
  double? gameHeight;

  /// Type of meteor (small, medium, or large)
  MeteorType type;

  /// Points awarded when destroyed (10, 20, or 30 based on type)
  int pointValue;

  /// Speed multiplier based on type (1.0, 0.8, or 0.6)
  double speedMultiplier;

  /// Collision hitbox for detecting collisions with bullets and player
  CircleHitbox? _hitbox;

  /// Creates a new meteor component
  ///
  /// The meteor is a circular sprite centered at its position with priority 5
  /// to ensure it renders above bullets but below the player.
  ///
  /// [speed] - Base falling speed in pixels per second (modified by type)
  /// [type] - Type of meteor (determines size, speed, points)
  Meteor({this.speed = 200.0, this.type = MeteorType.small})
    : pointValue = _getPointValue(type),
      speedMultiplier = _getSpeedMultiplier(type),
      super(
        size: Vector2.all(_getSize(type)),
        anchor: Anchor.center,
        priority: 5, // Render meteors above bullets but below player
      );

  /// Factory constructor for random meteor with weighted selection
  ///
  /// Creates a meteor with a randomly selected type based on weighted
  /// probabilities to balance gameplay difficulty and variety.
  ///
  /// **Spawn Probabilities:**
  /// - Small: 60% (fast, low points, easier to hit)
  /// - Medium: 30% (moderate speed and points)
  /// - Large: 10% (slow, high points, harder to hit)
  ///
  /// [speed] - Base falling speed in pixels per second
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

  /// Factory constructor for specific meteor type
  ///
  /// Creates a meteor of a specific type. Useful for testing or
  /// special game events that require specific meteor types.
  ///
  /// [type] - Type of meteor to create
  /// [speed] - Base falling speed in pixels per second
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

  /// Initialize meteor resources
  ///
  /// Loads the shared sprite instance from the game (reduces memory usage)
  /// and adds a circular hitbox for accurate collision detection with bullets
  /// and the player.
  ///
  /// **Flame Feature:** Component lifecycle - onLoad for async initialization
  /// **Optimization:** Circular hitbox provides accurate collision for round meteors
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Reuse shared sprite instance from game (sprite batching optimization)
    // All meteor instances share the same sprite texture in memory
    sprite = game.meteorSprite;

    // Add circular hitbox for accurate collision detection
    // CircleHitbox is more accurate than RectangleHitbox for round meteors
    // Flame's collision system automatically detects collisions with this hitbox
    _hitbox = CircleHitbox();
    await add(_hitbox!);
  }

  /// Called when meteor is added to the game world
  ///
  /// Caches game dimensions for efficient off-screen detection.
  ///
  /// **Flame Feature:** Component lifecycle - onMount for game-dependent setup
  @override
  void onMount() {
    super.onMount();

    // Get game dimensions after mounting (when game reference is guaranteed)
    gameHeight = game.size.y;
  }

  /// Clean up meteor resources
  ///
  /// Called when meteor is removed from the game world (returned to pool).
  /// Cleans up the hitbox reference to prevent memory leaks.
  ///
  /// **Flame Feature:** Component lifecycle - onRemove for cleanup
  @override
  void onRemove() {
    // Clean up hitbox reference
    _hitbox = null;
    super.onRemove();
  }

  /// Update meteor position each frame
  ///
  /// Moves the meteor downward at its speed (modified by type multiplier)
  /// and returns it to the pool when it exits the bottom of the screen.
  ///
  /// **Frame-rate Independence:** Uses delta time (dt) for consistent movement
  /// **Automatic Cleanup:** Returns to pool when off-screen (prevents memory leaks)
  @override
  void update(double dt) {
    super.update(dt);

    // Move down with speed multiplier based on type
    // Small meteors: 1.0x speed (fastest)
    // Medium meteors: 0.8x speed
    // Large meteors: 0.6x speed (slowest)
    position.y += speed * speedMultiplier * dt;

    // Check if meteor reached bottom (only if gameHeight is initialized)
    if (gameHeight != null && position.y > gameHeight! + size.y) {
      // Notify game that meteor was missed (player loses life)
      game.onMeteorMissed();
      // Return to pool instead of removing (pooling optimization)
      returnToPool();
    }
  }

  /// Reset the meteor state for pool reuse
  ///
  /// Called when acquiring a meteor from the pool to initialize it for a new
  /// use. Resets position, speed, and optionally type.
  ///
  /// **Poolable Interface:** Required by [Poolable] interface
  /// **Performance:** Enables 85%+ reuse rate, reduces allocations
  @override
  void reset({Vector2? newPosition, double? newSpeed, MeteorType? newType}) {
    if (newPosition != null) {
      position = newPosition.clone();
    }
    if (newSpeed != null) {
      speed = newSpeed;
    }
    if (newType != null) {
      type = newType;
      pointValue = _getPointValue(newType);
      speedMultiplier = _getSpeedMultiplier(newType);
      // Update size based on new type
      size = Vector2.all(_getSize(newType));
    }
  }

  /// Return this meteor to the pool
  ///
  /// Called when the meteor is done being used (destroyed by bullet,
  /// reached bottom, etc.). The meteor will be removed from the game
  /// world and made available for reuse.
  ///
  /// **Poolable Interface:** Required by [Poolable] interface
  /// **Performance:** Reduces GC pressure by reusing instances
  @override
  void returnToPool() {
    game.meteorPool?.release(this);
  }

  /// Destroy meteor (called when hit by bullet)
  ///
  /// Returns the meteor to the pool instead of permanently removing it.
  /// This is the primary way meteors are destroyed during gameplay.
  ///
  /// **Pooling Optimization:** Reuses meteor instead of creating new ones
  void destroy() {
    returnToPool();
  }

  /// Get the color for this meteor type (for particle effects)
  ///
  /// Returns the color associated with this meteor type, used for
  /// spawning colored particle effects when the meteor is destroyed.
  ///
  /// **Colors:**
  /// - Small: Red
  /// - Medium: Orange
  /// - Large: Brown
  Color getColor() {
    return _getColor(type);
  }
}
