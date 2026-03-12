import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'meteor_component.dart';
import 'power_up_component.dart';
import 'sky_defender_game.dart';

/// Player spaceship component controlled by user input
///
/// The player is the main character in Sky Defender, positioned at the bottom
/// of the screen and controlled via drag input. It automatically fires bullets
/// and can collect power-ups for enhanced abilities.
///
/// **Flame Features Used:**
/// - [SpriteComponent]: Automatic sprite rendering (no manual render method)
/// - [HasGameReference]: Type-safe access to game state and methods
/// - [DragCallbacks]: Component-level drag input handling
/// - [CollisionCallbacks]: Collision detection with meteors and power-ups
/// - [RectangleHitbox]: Rectangular collision boundary
/// - Component Priority: Renders on top (priority 10)
///
/// **Input Handling:**
/// - Drag to move horizontally across screen
/// - Clamped to screen bounds (can't move off-screen)
/// - Input disabled when game is paused or over
///
/// **Collision Behavior:**
/// - Colliding with meteor: Loses life (or consumes shield if active)
/// - Colliding with power-up: Activates power-up effect
///
/// **Performance:**
/// - Reuses shared sprite instance (reduces memory)
/// - Single hitbox for efficient collision detection
/// - Priority-based rendering (no manual z-ordering)
class Player extends SpriteComponent
    with
        HasGameReference<SkyDefenderGame>,
        DragCallbacks,
        CollisionCallbacks,
        KeyboardHandler {
  /// Movement speed in pixels per second (used for keyboard/programmatic movement)
  static const double speed = 300.0;

  /// Cached game dimensions for boundary clamping
  late double gameWidth;
  late double gameHeight;

  /// Collision hitbox for detecting collisions with meteors and power-ups
  RectangleHitbox? _hitbox;

  /// Whether the player is currently moving left via keyboard/gamepad.
  bool _keyLeft = false;

  /// Whether the player is currently moving right via keyboard/gamepad.
  bool _keyRight = false;

  /// Creates a new player component
  ///
  /// The player is a 50x50 sprite centered at its position with priority 10
  /// to ensure it renders on top of other game entities (meteors, bullets).
  Player()
    : super(
        size: Vector2(50, 50),
        anchor: Anchor.center,
        priority: 10, // Render player on top of other game entities
      );

  /// Initialize player resources
  ///
  /// Loads the shared sprite instance from the game (reduces memory usage)
  /// and adds a rectangular hitbox for collision detection with meteors
  /// and power-ups.
  ///
  /// **Flame Feature:** Component lifecycle - onLoad for async initialization
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Reuse shared sprite instance from game (sprite batching optimization)
    // All player instances share the same sprite texture in memory
    sprite = game.playerSprite;

    // Add rectangular hitbox for collision detection
    // Flame's collision system automatically detects collisions with this hitbox
    _hitbox = RectangleHitbox();
    await add(_hitbox!);
  }

  /// Called when player is added to the game world
  ///
  /// Caches game dimensions for efficient boundary clamping and positions
  /// the player at the bottom center of the screen.
  ///
  /// **Flame Feature:** Component lifecycle - onMount for game-dependent setup
  @override
  void onMount() {
    super.onMount();

    // Get game dimensions after mounting (when game reference is guaranteed)
    gameWidth = game.size.x;
    gameHeight = game.size.y;

    // Position at bottom center (50 pixels from bottom)
    position = Vector2(gameWidth / 2, gameHeight - size.y / 2 - 50);
  }

  /// Clean up player resources
  ///
  /// Called when player is removed from the game world. Cleans up the
  /// hitbox reference to prevent memory leaks.
  ///
  /// **Flame Feature:** Component lifecycle - onRemove for cleanup
  @override
  void onRemove() {
    // Clean up hitbox reference
    _hitbox = null;
    super.onRemove();
  }

  /// Handle hardware keyboard input (web & desktop).
  ///
  /// Maps Arrow Left / A → move left, Arrow Right / D → move right.
  /// Escape / P pauses the game. Returns `true` to allow event propagation.
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (!game.hasGameStarted || game.isGameOver) {
      _keyLeft = false;
      _keyRight = false;
      return true;
    }

    // Pause / resume on Escape or P key press.
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape ||
          event.logicalKey == LogicalKeyboardKey.keyP) {
        if (game.isPaused) {
          game.resumeGame();
        } else {
          game.pauseGame();
        }
        return true;
      }
    }

    if (game.isPaused) {
      _keyLeft = false;
      _keyRight = false;
      return true;
    }

    _keyLeft =
        keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA);
    _keyRight =
        keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD);

    return true;
  }

  /// Update player position each frame.
  ///
  /// Applies keyboard-driven movement when arrow keys / WASD are held.
  /// Drag movement is handled separately via [onDragUpdate].
  @override
  void update(double dt) {
    super.update(dt);
    if (_keyLeft) moveLeft(dt);
    if (_keyRight) moveRight(dt);
  }

  /// Handle drag start event
  ///
  /// Only processes drag input when the game is active (started, not paused,
  /// not game over). This prevents player movement during pause or game over.
  ///
  /// **Flame Feature:** DragCallbacks mixin provides this callback
  @override
  void onDragStart(DragStartEvent event) {
    // Only handle drag if game is active
    if (!game.hasGameStarted || game.isGameOver || game.isPaused) {
      return;
    }
    super.onDragStart(event);
  }

  /// Handle drag update event
  ///
  /// Moves the player horizontally based on drag delta, clamped to screen
  /// bounds. This provides smooth, responsive touch/mouse control.
  ///
  /// **Flame Feature:** DragCallbacks mixin provides this callback
  /// **Optimization:** Component-level input handling (vs global game-level)
  @override
  void onDragUpdate(DragUpdateEvent event) {
    // Only handle drag if game is active
    if (!game.hasGameStarted || game.isGameOver || game.isPaused) {
      return;
    }

    // Handle drag directly on component using localDelta
    // localDelta provides the change in position since last frame
    position.x += event.localDelta.x;

    // Clamp to screen bounds (prevents moving off-screen)
    // Player stays within [size.x/2, gameWidth - size.x/2]
    position.x = position.x.clamp(size.x / 2, gameWidth - size.x / 2);
  }

  /// Move player left (for keyboard/programmatic control)
  ///
  /// Moves the player left at [speed] pixels per second, clamped to the
  /// left screen boundary. Uses delta time for frame-rate independent movement.
  void moveLeft(double dt) {
    position.x -= speed * dt;
    // Clamp to left screen bound
    if (position.x - size.x / 2 < 0) {
      position.x = size.x / 2;
    }
  }

  /// Move player right (for keyboard/programmatic control)
  ///
  /// Moves the player right at [speed] pixels per second, clamped to the
  /// right screen boundary. Uses delta time for frame-rate independent movement.
  void moveRight(double dt) {
    position.x += speed * dt;
    // Clamp to right screen bound
    if (position.x + size.x / 2 > gameWidth) {
      position.x = gameWidth - size.x / 2;
    }
  }

  /// Move player to specific x position (for programmatic control)
  ///
  /// Instantly moves the player to the target x position, clamped to screen
  /// bounds. Useful for testing or special game events.
  void moveTo(double targetX) {
    position.x = targetX.clamp(size.x / 2, gameWidth - size.x / 2);
  }

  /// Get the position where bullets should spawn (top center of player)
  ///
  /// Returns a position at the top center of the player sprite, which is
  /// where bullets are spawned when firing.
  Vector2 get centerPosition => Vector2(position.x, position.y - size.y / 2);

  /// Handle collision with other components
  ///
  /// Detects collisions with meteors and power-ups using Flame's collision
  /// detection system. Delegates to game methods for handling collision logic.
  ///
  /// **Collision Behavior:**
  /// - Meteor: Loses life (or consumes shield), triggers screen shake
  /// - PowerUp: Activates power-up effect (shield or rapid fire)
  ///
  /// **Flame Feature:** CollisionCallbacks mixin provides this callback
  /// **Performance:** O(n log n) collision detection via spatial hashing
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Meteor) {
      // Player hit by meteor - lose life or consume shield
      game.onPlayerHitMeteor(other);
    } else if (other is PowerUp) {
      // Player collected power-up - activate effect
      game.onPlayerCollectPowerUp(other);
    }
  }
}
