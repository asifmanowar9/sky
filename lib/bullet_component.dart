import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'component_pool.dart';
import 'sky_defender_game.dart';
import 'meteor_component.dart';

/// Bullet projectile fired by the player
///
/// Extends [SpriteComponent] for optimized sprite rendering and implements
/// [Poolable] for efficient object reuse. Uses Flame's collision detection
/// system with [RectangleHitbox] for collision boundaries.
///
/// **Flame Features Used:**
/// - SpriteComponent: Automatic sprite rendering
/// - CollisionCallbacks: Component-level collision handling
/// - HasGameReference: Type-safe game reference
/// - Component pooling: Reused instead of created/destroyed
///
/// **Performance:**
/// - Pooled to reduce GC pressure (pool size: 20-100)
/// - Shared sprite instance reduces memory usage
/// - Automatic off-screen removal
class Bullet extends SpriteComponent
    with HasGameReference<SkyDefenderGame>, CollisionCallbacks
    implements Poolable {
  /// Speed at which bullets travel upward (pixels per second)
  static const double speed = 400.0;

  /// Cached game height for off-screen detection
  double? gameHeight;

  /// Collision hitbox for bullet-meteor collision detection
  RectangleHitbox? _hitbox;

  /// Creates a new bullet component
  ///
  /// Bullets are small (5x10) projectiles with priority 3 for render ordering.
  /// They are typically acquired from a pool rather than constructed directly.
  Bullet()
    : super(
        size: Vector2(5, 10),
        anchor: Anchor.center,
        priority: 3, // Render bullets below meteors and player
      );

  /// Initialize bullet resources
  ///
  /// Loads the shared sprite instance from the game and adds a collision hitbox.
  /// This is called once when the bullet is first created, not on every pool reuse.
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Reuse shared sprite instance from game (reduces memory usage)
    sprite = game.bulletSprite;

    // Add rectangular hitbox for collision detection with meteors
    _hitbox = RectangleHitbox();
    await add(_hitbox!);
  }

  /// Called when bullet is added to the game world
  ///
  /// Caches the game height for efficient off-screen detection.
  @override
  void onMount() {
    super.onMount();

    // Get game dimensions after mounting (when game reference is guaranteed)
    gameHeight = game.size.y;
  }

  /// Clean up bullet resources
  ///
  /// Called when bullet is removed from the game world (returned to pool).
  @override
  void onRemove() {
    // Clean up hitbox reference
    _hitbox = null;
    super.onRemove();
  }

  /// Update bullet position each frame
  ///
  /// Moves the bullet upward and returns it to the pool when it exits the screen.
  /// This automatic cleanup prevents memory leaks from off-screen bullets.
  @override
  void update(double dt) {
    super.update(dt);

    // Move upward at constant speed
    position.y -= speed * dt;

    // Return to pool when off screen (exits top)
    // Only check if gameHeight is initialized (after onMount)
    if (gameHeight != null && position.y < -size.y) {
      returnToPool();
    }
  }

  /// Handle collision with other components
  ///
  /// Detects collisions with meteors using Flame's collision detection system.
  /// On collision, spawns particle effects, awards points, and destroys both
  /// the bullet and meteor by returning them to their respective pools.
  ///
  /// **Flame Feature:** CollisionCallbacks mixin provides this callback
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Meteor) {
      // Spawn particle effect at collision point using Flame's particle system
      game.spawnParticleEffect(
        position: other.position,
        color: other.getColor(),
        particleCount: 10,
      );

      // Award points based on meteor type (10-30 points)
      game.score += other.pointValue;

      // Destroy both bullet and meteor (returns to pools)
      destroy();
      other.destroy();
    }
  }

  /// Reset the bullet state for pool reuse
  @override
  void reset({Vector2? newPosition}) {
    if (newPosition != null) {
      position = newPosition.clone();
    }
  }

  /// Return this bullet to the pool
  @override
  void returnToPool() {
    game.bulletPool?.release(this);
  }

  /// Destroy bullet (called when it hits something)
  /// Now uses pooling instead of removal
  void destroy() {
    returnToPool();
  }
}
