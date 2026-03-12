import 'dart:math';
import 'dart:async';
import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/particles.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'player_component.dart';
import 'meteor_component.dart';
import 'bullet_component.dart';
import 'component_pool.dart';
import 'difficulty_manager.dart';
import 'power_up_component.dart';
import 'power_up_state.dart';
import 'score_manager.dart';
import 'platform_utils.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
  ),
);

class SkyDefenderGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  late Player player;

  // Shared sprites for components
  Sprite? meteorSprite;
  Sprite? bulletSprite;
  Sprite? playerSprite;
  Sprite? rapidFireSprite;
  Sprite? shieldSprite;

  // Component pools
  ComponentPool<Bullet>? bulletPool;
  ComponentPool<Meteor>? meteorPool;

  // Timer components
  late TimerComponent meteorSpawnTimerComponent;
  late TimerComponent bulletFireTimerComponent;
  late TimerComponent powerUpSpawnTimerComponent;

  final Random random = Random();

  // Difficulty manager
  final DifficultyManager difficultyManager = DifficultyManager();

  // Power-up system
  final PowerUpState powerUpState = PowerUpState();

  // High score system
  final ScoreManager scoreManager = ScoreManager();
  int _highScore = 0;
  bool _isNewHighScore = false;

  // Add stream controllers for UI updates
  final StreamController<int> _scoreController =
      StreamController<int>.broadcast();
  final StreamController<int> _livesController =
      StreamController<int>.broadcast();
  final StreamController<int> _waveController =
      StreamController<int>.broadcast();
  final StreamController<int> _highScoreController =
      StreamController<int>.broadcast();

  Stream<int> get scoreStream => _scoreController.stream;
  Stream<int> get livesStream => _livesController.stream;
  Stream<int> get waveStream => _waveController.stream;
  Stream<int> get highScoreStream => _highScoreController.stream;
  Stream<PowerUpState> get powerUpStream => powerUpState.stateStream;

  int _score = 0;
  int _lives = 3;
  bool isGameOver = false;
  bool hasGameStarted = false; // Add game state
  bool isPaused = false; // Pause state

  // Add getters and setters to trigger stream updates
  int get score => _score;
  set score(int value) {
    int previousWave = difficultyManager.currentWave;
    _score = value;
    _scoreController.add(_score);

    // Update difficulty based on new score
    difficultyManager.updateDifficulty(_score);

    // If wave changed, notify listeners and update meteor spawn timer
    if (difficultyManager.currentWave != previousWave) {
      _waveController.add(difficultyManager.currentWave);
      // Update meteor spawn timer period for new difficulty
      meteorSpawnTimerComponent.timer.limit = difficultyManager
          .getMeteorSpawnInterval();
      logger.i('Wave ${difficultyManager.currentWave} started!');
    }
  }

  int get lives => _lives;
  set lives(int value) {
    _lives = value;
    _livesController.add(_lives);
  }

  int get highScore => _highScore;
  set highScore(int value) {
    _highScore = value;
    _highScoreController.add(_highScore);
  }

  bool get isNewHighScore => _isNewHighScore;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load high score from storage
    _highScore = await scoreManager.getHighScore();

    // Load common sprites once at game level
    await _loadSharedSprites();

    // Initialize component pools
    bulletPool = ComponentPool<Bullet>(
      factory: () => Bullet(),
      initialSize: 20,
      maxSize: 100,
    );

    meteorPool = ComponentPool<Meteor>(
      factory: () => Meteor(),
      initialSize: 15,
      maxSize: 50,
    );

    // Initialize timer components
    meteorSpawnTimerComponent = TimerComponent(
      period: difficultyManager.getMeteorSpawnInterval(),
      repeat: true,
      autoStart: false, // Don't start until game begins
      onTick: () => spawnMeteor(),
    );

    bulletFireTimerComponent = TimerComponent(
      period: 0.3,
      repeat: true,
      autoStart: false, // Don't start until game begins
      onTick: () => fireBullet(),
    );

    powerUpSpawnTimerComponent = TimerComponent(
      period: 15.0,
      repeat: true,
      autoStart: false, // Don't start until game begins
      onTick: () {
        spawnPowerUp();
        // Randomize next spawn interval (10-20 seconds)
        powerUpSpawnTimerComponent.timer.limit =
            10.0 + random.nextDouble() * 10.0;
      },
    );

    // Add timer components to game
    await add(meteorSpawnTimerComponent);
    await add(bulletFireTimerComponent);
    await add(powerUpSpawnTimerComponent);

    // Set up rapid fire callback to update bullet fire timer
    powerUpState.onRapidFireChanged = (bool isRapidFire) {
      if (isRapidFire) {
        // 50% faster firing (half the interval)
        bulletFireTimerComponent.timer.limit = 0.15;
      } else {
        // Restore normal firing rate
        bulletFireTimerComponent.timer.limit = 0.3;
      }
    };

    // Add player component and await its initialization
    player = Player();
    await add(player);

    // Show start screen initially
    overlays.add('StartScreen');

    // Initialize streams
    _scoreController.add(_score);
    _livesController.add(_lives);
    _waveController.add(difficultyManager.currentWave);
    _highScoreController.add(_highScore);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Don't update game logic if paused
    if (isPaused) return;

    // Timers are now handled by TimerComponent - no manual timer updates needed
    // Collisions handled by Flame's collision detection system
  }

  /// Called when player collides with a meteor
  void onPlayerHitMeteor(Meteor meteor) {
    // Spawn particle effect at collision point
    spawnParticleEffect(
      position: meteor.position,
      color: meteor.getColor(),
      particleCount: 15,
    );

    // Trigger screen shake effect
    triggerScreenShake(intensity: 15.0, duration: 0.4);

    // Check if shield is active
    if (powerUpState.shieldActive) {
      // Shield prevents life loss and is consumed
      powerUpState.consumeShield();
      logger.i('Shield absorbed meteor collision!');
    } else {
      // Decrease lives (this will trigger stream update)
      lives--;
      logger.w('Player hit by meteor! Lives remaining: $lives');

      if (lives <= 0) {
        gameOver();
      }
    }

    // Destroy the meteor
    meteor.destroy();
  }

  void startGame() {
    hasGameStarted = true;
    overlays.remove('StartScreen');
    overlays.add('ScoreDisplay');

    // Start all timer components
    meteorSpawnTimerComponent.timer.start();
    bulletFireTimerComponent.timer.start();
    powerUpSpawnTimerComponent.timer.start();

    logger.i('Game started');
  }

  void spawnMeteor() {
    // Get current difficulty speed
    double currentSpeed = difficultyManager.getMeteorSpeed();

    // Acquire meteor from pool
    final meteor = meteorPool!.acquire();

    // Determine random meteor type with weighted selection
    final roll = random.nextDouble();
    MeteorType selectedType;
    if (roll < 0.6) {
      selectedType = MeteorType.small; // 60% chance
    } else if (roll < 0.9) {
      selectedType = MeteorType.medium; // 30% chance
    } else {
      selectedType = MeteorType.large; // 10% chance
    }

    // Reset meteor with new position, speed, and type
    meteor.reset(
      newPosition: Vector2(random.nextDouble() * size.x, -meteor.size.y),
      newSpeed: currentSpeed,
      newType: selectedType,
    );

    // Add meteor to game (no need to await in timer callback)
    add(meteor);
  }

  void spawnPowerUp() {
    // Randomly select power-up type (50/50 chance)
    final type = random.nextBool() ? PowerUpType.rapidFire : PowerUpType.shield;
    final powerUp = PowerUp(type: type);

    // Random X position across screen width
    powerUp.position = Vector2(random.nextDouble() * size.x, -powerUp.size.y);
    add(powerUp);

    logger.i('Power-up spawned: ${type.name}');
  }

  void fireBullet() {
    final bullet = bulletPool!.acquire();
    bullet.reset(newPosition: player.centerPosition);
    add(bullet);
  }

  // Called when a meteor reaches the bottom
  void onMeteorMissed() {
    if (isGameOver || !hasGameStarted) return;

    // Trigger screen shake effect
    triggerScreenShake(intensity: 10.0, duration: 0.3);

    // Check if shield is active
    if (powerUpState.shieldActive) {
      // Shield prevents life loss and is consumed
      powerUpState.consumeShield();
      logger.i('Shield absorbed meteor hit!');
      return;
    }

    // Decrease lives (this will trigger stream update)
    lives--;

    if (lives <= 0) {
      gameOver();
    }
  }

  // Called when player collects a power-up
  void onPlayerCollectPowerUp(PowerUp powerUp) {
    // Spawn particle effect at collection point
    spawnParticleEffect(
      position: powerUp.position,
      color: powerUp.getColor(),
      particleCount: 12,
    );

    // Activate power-up effect
    powerUp.activate();

    // Remove power-up
    powerUp.onCollected();

    logger.i('Power-up collected: ${powerUp.type.name}');
  }

  /// Spawn a particle effect at the specified position using Flame's particle system
  void spawnParticleEffect({
    required Vector2 position,
    required Color color,
    int particleCount = 10,
    double lifetime = 0.4,
  }) {
    // Reduce particle count on mobile to improve GPU performance.
    final adaptiveCount = PlatformUtils.adaptiveParticleCount(particleCount);

    // Use Flame's particle system
    final particle = Particle.generate(
      count: adaptiveCount,
      lifespan: lifetime,
      generator: (i) {
        final angle = random.nextDouble() * 2 * pi;
        final speed = 50.0 + random.nextDouble() * 100.0;

        return AcceleratedParticle(
          acceleration: Vector2(0, 100), // Gravity effect
          speed: Vector2(cos(angle), sin(angle)) * speed,
          position: Vector2.zero(),
          child: CircleParticle(radius: 3.0, paint: Paint()..color = color),
        );
      },
    );

    add(
      ParticleSystemComponent(
        particle: particle,
        position: position,
        priority: 8, // Render particles above most entities but below player
      ),
    );
  }

  /// Trigger screen shake effect using Flame's effect system
  void triggerScreenShake({
    required double intensity,
    required double duration,
  }) {
    // Scale intensity down on mobile to avoid jarring small-screen experience.
    final effectiveIntensity = PlatformUtils.adaptiveShakeIntensity(intensity);

    // Limit the number of MoveEffect steps for performance.
    // Fewer allocations = less GC pressure, especially on mobile.
    final shakeCount = min(
      PlatformUtils.maxShakeSteps,
      (duration * 20).toInt().clamp(1, PlatformUtils.maxShakeSteps),
    );
    final effects = <Effect>[];

    // Generate random shake movements
    for (int i = 0; i < shakeCount; i++) {
      effects.add(
        MoveEffect.by(
          Vector2(
            (random.nextDouble() - 0.5) * effectiveIntensity * 2,
            (random.nextDouble() - 0.5) * effectiveIntensity * 2,
          ),
          EffectController(duration: duration / shakeCount),
        ),
      );
    }

    // Add final move effect to return camera to center
    effects.add(MoveEffect.to(Vector2.zero(), EffectController(duration: 0.1)));

    // Apply the sequence effect to the camera viewfinder
    camera.viewfinder.add(SequenceEffect(effects));
  }

  /// Pause the game
  void pauseGame() {
    // Only allow pausing during active gameplay
    if (!hasGameStarted || isGameOver || isPaused) return;

    isPaused = true;
    paused = true; // Flame's built-in pause
    overlays.remove('ScoreDisplay');
    overlays.add('PauseMenu');
    logger.i('Game paused');
  }

  /// Resume the game from pause
  void resumeGame() {
    if (!isPaused) return;

    isPaused = false;
    paused = false; // Flame's built-in resume
    overlays.remove('PauseMenu');
    overlays.add('ScoreDisplay');
    logger.i('Game resumed');
  }

  void gameOver() {
    isGameOver = true;

    // Check for new high score
    if (scoreManager.isNewHighScore(score, highScore)) {
      _isNewHighScore = true;
      highScore = score; // Update high score in memory
      scoreManager.saveHighScore(score); // Save to storage
      logger.i('New high score achieved: $score');
    } else {
      _isNewHighScore = false;
    }

    // Remove score display and show game over overlay
    overlays.remove('ScoreDisplay');
    overlays.add('GameOver');

    logger.i('Game over - Final score: $score');
  }

  void restartGame() {
    // Reset game state
    isGameOver = false;
    hasGameStarted = true; // Start game immediately
    _isNewHighScore = false; // Reset new high score flag

    // Reset difficulty manager
    difficultyManager.reset();

    // Reset power-up state
    powerUpState.reset();

    // Reset camera position (clear any active shake effects)
    camera.viewfinder.position = Vector2.zero();

    score = 0; // This will trigger stream update
    lives = 3; // This will trigger stream update

    // Reset timer components
    meteorSpawnTimerComponent.timer.reset();
    bulletFireTimerComponent.timer.reset();
    powerUpSpawnTimerComponent.timer.reset();

    // Reset timer periods to initial values
    meteorSpawnTimerComponent.timer.limit = difficultyManager
        .getMeteorSpawnInterval();
    bulletFireTimerComponent.timer.limit = 0.3;
    powerUpSpawnTimerComponent.timer.limit = 15.0;

    // Start timers
    meteorSpawnTimerComponent.timer.start();
    bulletFireTimerComponent.timer.start();
    powerUpSpawnTimerComponent.timer.start();

    // Clear component pools
    bulletPool?.clear();
    meteorPool?.clear();

    // Remove all game objects except player
    removeWhere(
      (component) =>
          component is Meteor ||
          component is Bullet ||
          component is PowerUp ||
          component is ParticleSystemComponent,
    );

    // Go directly to game (skip start screen)
    overlays.remove('GameOver');
    overlays.add('ScoreDisplay');

    logger.i('Game restarted');
  }

  void goToStartScreen() {
    // Check and save high score before resetting game state
    if (scoreManager.isNewHighScore(score, highScore)) {
      highScore = score; // Update high score in memory
      scoreManager.saveHighScore(score); // Save to storage
      logger.i('High score saved when returning home: $score');
    }

    // Reset game state
    isGameOver = false;
    hasGameStarted = false; // Return to start screen
    isPaused = false; // Reset pause state
    _isNewHighScore = false; // Reset new high score flag

    // Reset difficulty manager
    difficultyManager.reset();

    // Reset power-up state
    powerUpState.reset();

    // Reset camera position (clear any active shake effects)
    camera.viewfinder.position = Vector2.zero();

    score = 0; // This will trigger stream update
    lives = 3; // This will trigger stream update

    // Stop and reset timer components
    meteorSpawnTimerComponent.timer.stop();
    bulletFireTimerComponent.timer.stop();
    powerUpSpawnTimerComponent.timer.stop();
    meteorSpawnTimerComponent.timer.reset();
    bulletFireTimerComponent.timer.reset();
    powerUpSpawnTimerComponent.timer.reset();

    // Reset timer periods to initial values
    meteorSpawnTimerComponent.timer.limit = difficultyManager
        .getMeteorSpawnInterval();
    bulletFireTimerComponent.timer.limit = 0.3;
    powerUpSpawnTimerComponent.timer.limit = 15.0;

    // Clear component pools
    bulletPool?.clear();
    meteorPool?.clear();

    // Remove all game objects except player
    removeWhere(
      (component) =>
          component is Meteor ||
          component is Bullet ||
          component is PowerUp ||
          component is ParticleSystemComponent,
    );

    // Go back to start screen
    overlays.remove('GameOver');
    overlays.remove('PauseMenu'); // Ensure PauseMenu is removed if present
    overlays.add('StartScreen');

    logger.i('Returned to start screen');
  }

  /// Load shared sprites once at game level for reuse across components
  Future<void> _loadSharedSprites() async {
    // Load player sprite
    try {
      playerSprite = await Sprite.load('plane.jpg');
    } catch (e) {
      logger.w('Failed to load player sprite, using fallback');
      playerSprite = await _createFallbackPlayerSprite();
    }

    // Load meteor sprite
    try {
      meteorSprite = await Sprite.load('meteor.png');
    } catch (e) {
      logger.w('Failed to load meteor sprite, using fallback');
      meteorSprite = await _createFallbackMeteorSprite();
    }

    // Load bullet sprite
    try {
      bulletSprite = await Sprite.load('bullet.webp');
    } catch (e) {
      logger.w('Failed to load bullet sprite, using fallback');
      bulletSprite = await _createFallbackBulletSprite();
    }

    // Load power-up sprites
    try {
      rapidFireSprite = await Sprite.load('rapidfire.png');
    } catch (e) {
      logger.w('Failed to load rapid fire sprite, using fallback');
      rapidFireSprite = await _createFallbackRapidFireSprite();
    }

    try {
      shieldSprite = await Sprite.load('shield.png');
    } catch (e) {
      logger.w('Failed to load shield sprite, using fallback');
      shieldSprite = await _createFallbackShieldSprite();
    }
  }

  /// Create fallback player sprite
  Future<Sprite> _createFallbackPlayerSprite() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = Colors.blue;

    canvas.drawRect(Rect.fromLTWH(0, 0, 50, 50), paint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(50, 50);

    return Sprite(image);
  }

  /// Create fallback meteor sprite
  Future<Sprite> _createFallbackMeteorSprite() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = Colors.red;

    canvas.drawCircle(const Offset(30, 30), 30, paint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(60, 60);

    return Sprite(image);
  }

  /// Create fallback bullet sprite
  Future<Sprite> _createFallbackBulletSprite() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = Colors.yellow;

    canvas.drawRect(Rect.fromLTWH(0, 0, 5, 10), paint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(5, 10);

    return Sprite(image);
  }

  /// Create fallback rapid fire sprite
  Future<Sprite> _createFallbackRapidFireSprite() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw yellow star
    _drawStar(canvas, 20, 20, 5, 20, 10, Colors.yellow);

    final picture = recorder.endRecording();
    final image = await picture.toImage(40, 40);

    return Sprite(image);
  }

  /// Create fallback shield sprite
  Future<Sprite> _createFallbackShieldSprite() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(const Offset(20, 20), 18, paint);
    canvas.drawCircle(const Offset(20, 20), 18, borderPaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(40, 40);

    return Sprite(image);
  }

  /// Helper method to draw a star shape
  void _drawStar(
    Canvas canvas,
    double cx,
    double cy,
    int points,
    double outerRadius,
    double innerRadius,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final angle = pi / points;

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = cx + radius * cos(i * angle - pi / 2);
      final y = cy + radius * sin(i * angle - pi / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  void onRemove() {
    // Close stream controllers
    _scoreController.close();
    _livesController.close();
    _waveController.close();
    _highScoreController.close();

    // Dispose power-up state (includes timers)
    powerUpState.dispose();

    // Clear component pools
    bulletPool?.clear();
    meteorPool?.clear();

    // Stop and remove timer components
    meteorSpawnTimerComponent.timer.stop();
    bulletFireTimerComponent.timer.stop();
    powerUpSpawnTimerComponent.timer.stop();

    // Remove any active effects from camera
    camera.viewfinder.children.whereType<Effect>().forEach((effect) {
      effect.removeFromParent();
    });

    super.onRemove();
  }
}
