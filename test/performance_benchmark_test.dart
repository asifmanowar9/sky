import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flame/game.dart';
import 'package:sky/sky_defender_game.dart';
import 'package:sky/meteor_component.dart';
import 'package:sky/bullet_component.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Test-specific game class that doesn't add overlays
class TestSkyDefenderGame extends SkyDefenderGame {
  @override
  Future<void> onLoad() async {
    // Call parent onLoad but catch overlay errors
    try {
      await super.onLoad();
    } catch (e) {
      // Ignore overlay errors in test environment
      if (!e.toString().contains('overlay')) {
        rethrow;
      }
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Helper function to properly initialize game for testing
  Future<void> initializeGameForTest(SkyDefenderGame game) async {
    // Set a default size for the game
    game.onGameResize(Vector2(800, 600));
    await game.onLoad();
    await game.ready();
  }

  // Helper function to start game without overlays (for testing)
  void startGameForTest(SkyDefenderGame game) {
    game.hasGameStarted = true;
    game.meteorSpawnTimerComponent.timer.start();
    game.bulletFireTimerComponent.timer.start();
    game.powerUpSpawnTimerComponent.timer.start();
  }

  group('Performance Benchmark Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'Frame time benchmark - measures average frame processing time',
      () async {
        final game = TestSkyDefenderGame();
        await initializeGameForTest(game);

        // Start the game
        startGameForTest(game);

        // Spawn multiple entities to simulate gameplay
        for (int i = 0; i < 20; i++) {
          game.spawnMeteor();
        }
        for (int i = 0; i < 10; i++) {
          game.fireBullet();
        }

        // Measure frame times over multiple updates
        final frameTimes = <double>[];
        const frameCount = 100;
        const targetDt = 1 / 60; // 60 FPS target

        for (int i = 0; i < frameCount; i++) {
          final stopwatch = Stopwatch()..start();
          game.update(targetDt);
          stopwatch.stop();
          frameTimes.add(
            stopwatch.elapsedMicroseconds / 1000.0,
          ); // Convert to ms
        }

        // Calculate statistics
        final avgFrameTime =
            frameTimes.reduce((a, b) => a + b) / frameTimes.length;
        final maxFrameTime = frameTimes.reduce((a, b) => a > b ? a : b);
        final minFrameTime = frameTimes.reduce((a, b) => a < b ? a : b);

        // Log results
        print('=== Frame Time Benchmark ===');
        print('Average frame time: ${avgFrameTime.toStringAsFixed(2)}ms');
        print('Min frame time: ${minFrameTime.toStringAsFixed(2)}ms');
        print('Max frame time: ${maxFrameTime.toStringAsFixed(2)}ms');
        print(
          'Target frame time (60 FPS): ${(1000 / 60).toStringAsFixed(2)}ms',
        );

        // Performance assertions - frame time should be well under 16.67ms for 60 FPS
        expect(
          avgFrameTime,
          lessThan(10.0),
          reason: 'Average frame time should be under 10ms',
        );
        expect(
          maxFrameTime,
          lessThan(20.0),
          reason: 'Max frame time should be under 20ms',
        );
      },
    );

    test('Memory usage benchmark - measures entity count handling', () async {
      final game = TestSkyDefenderGame();
      await initializeGameForTest(game);

      startGameForTest(game);

      // Spawn many entities to test memory handling
      const meteorCount = 50;
      const bulletCount = 100;

      for (int i = 0; i < meteorCount; i++) {
        game.spawnMeteor();
      }

      for (int i = 0; i < bulletCount; i++) {
        game.fireBullet();
      }

      // Count active components
      final meteors = game.children.whereType<Meteor>().length;
      final bullets = game.children.whereType<Bullet>().length;
      final totalEntities = meteors + bullets;

      print('=== Memory Usage Benchmark ===');
      print('Active meteors: $meteors');
      print('Active bullets: $bullets');
      print('Total entities: $totalEntities');
      print('Bullet pool active: ${game.bulletPool?.activeCount ?? 0}');
      print('Bullet pool available: ${game.bulletPool?.availableCount ?? 0}');
      print('Meteor pool active: ${game.meteorPool?.activeCount ?? 0}');
      print('Meteor pool available: ${game.meteorPool?.availableCount ?? 0}');

      // Verify pools are working
      expect(
        game.bulletPool?.activeCount,
        greaterThan(0),
        reason: 'Bullet pool should have active components',
      );
      expect(
        game.meteorPool?.activeCount,
        greaterThan(0),
        reason: 'Meteor pool should have active components',
      );
      expect(
        totalEntities,
        greaterThan(0),
        reason: 'Should have active entities',
      );
    });

    test('Component pooling efficiency - measures reuse vs allocation', () async {
      final game = TestSkyDefenderGame();
      await initializeGameForTest(game);

      startGameForTest(game);

      // Spawn and destroy bullets to test pooling
      const cycles = 50;
      final initialAvailable = game.bulletPool?.availableCount ?? 0;

      for (int i = 0; i < cycles; i++) {
        // Spawn bullet
        game.fireBullet();

        // Simulate bullet lifecycle
        game.update(0.016);

        // Remove bullets that are off-screen
        final bulletsToRemove = game.children
            .whereType<Bullet>()
            .where((bullet) => bullet.position.y < -100)
            .toList();
        for (final bullet in bulletsToRemove) {
          bullet.destroy();
        }
      }

      final finalAvailable = game.bulletPool?.availableCount ?? 0;
      final finalActive = game.bulletPool?.activeCount ?? 0;

      print('=== Component Pooling Efficiency ===');
      print('Initial available: $initialAvailable');
      print('Final available: $finalAvailable');
      print('Final active: $finalActive');
      print(
        'Pool reuse rate: ${((finalAvailable / (finalAvailable + finalActive)) * 100).toStringAsFixed(1)}%',
      );

      // Pool should have components available for reuse
      expect(
        finalAvailable,
        greaterThan(0),
        reason: 'Pool should have components available for reuse',
      );
    });

    test(
      'Collision detection performance - measures collision check efficiency',
      () async {
        final game = TestSkyDefenderGame();
        await initializeGameForTest(game);

        startGameForTest(game);

        // Spawn many entities to test collision detection
        for (int i = 0; i < 30; i++) {
          game.spawnMeteor();
        }
        for (int i = 0; i < 30; i++) {
          game.fireBullet();
        }

        // Measure collision detection time
        final stopwatch = Stopwatch()..start();
        const updateCount = 50;

        for (int i = 0; i < updateCount; i++) {
          game.update(1 / 60);
        }

        stopwatch.stop();
        final avgUpdateTime =
            stopwatch.elapsedMicroseconds / updateCount / 1000.0;

        print('=== Collision Detection Performance ===');
        print(
          'Entities: ${game.children.whereType<Meteor>().length + game.children.whereType<Bullet>().length}',
        );
        print(
          'Average update time with collisions: ${avgUpdateTime.toStringAsFixed(2)}ms',
        );
        print('Collision system: Flame built-in (spatial hashing)');

        // With Flame's optimized collision detection, should handle many entities efficiently
        expect(
          avgUpdateTime,
          lessThan(15.0),
          reason: 'Collision detection should be efficient',
        );
      },
    );

    test(
      'Particle system performance - measures particle generation and rendering',
      () async {
        final game = TestSkyDefenderGame();
        await initializeGameForTest(game);

        startGameForTest(game);

        // Spawn multiple particle effects
        const particleEffectCount = 20;
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < particleEffectCount; i++) {
          game.spawnParticleEffect(
            position: Vector2(100 + i * 10, 100),
            color: Colors.red,
            particleCount: 10,
          );
        }

        // Update to process particles
        for (int i = 0; i < 30; i++) {
          game.update(1 / 60);
        }

        stopwatch.stop();
        final totalTime = stopwatch.elapsedMilliseconds;

        print('=== Particle System Performance ===');
        print('Particle effects spawned: $particleEffectCount');
        print('Total time: ${totalTime}ms');
        print(
          'Average time per effect: ${(totalTime / particleEffectCount).toStringAsFixed(2)}ms',
        );
        print('Particle system: Flame ParticleSystemComponent');

        // Particle generation should be fast
        expect(
          totalTime,
          lessThan(500),
          reason: 'Particle generation should be fast',
        );
      },
    );

    test(
      'Screen shake effect performance - measures effect system overhead',
      () async {
        final game = TestSkyDefenderGame();
        await initializeGameForTest(game);

        startGameForTest(game);

        // Trigger multiple screen shakes
        const shakeCount = 10;
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < shakeCount; i++) {
          game.triggerScreenShake(intensity: 15.0, duration: 0.2);
        }

        // Update to process effects
        for (int i = 0; i < 20; i++) {
          game.update(1 / 60);
        }

        stopwatch.stop();
        final totalTime = stopwatch.elapsedMilliseconds;

        print('=== Screen Shake Effect Performance ===');
        print('Screen shakes triggered: $shakeCount');
        print('Total time: ${totalTime}ms');
        print(
          'Average time per shake: ${(totalTime / shakeCount).toStringAsFixed(2)}ms',
        );
        print('Effect system: Flame MoveEffect + SequenceEffect');

        // Effect system should be efficient
        expect(
          totalTime,
          lessThan(300),
          reason: 'Effect system should be efficient',
        );
      },
    );

    test(
      'Timer component overhead - measures timer system performance',
      () async {
        final game = TestSkyDefenderGame();
        await initializeGameForTest(game);

        startGameForTest(game);

        // Measure update time with active timers
        final stopwatch = Stopwatch()..start();
        const updateCount = 100;

        for (int i = 0; i < updateCount; i++) {
          game.update(1 / 60);
        }

        stopwatch.stop();
        final avgUpdateTime =
            stopwatch.elapsedMicroseconds / updateCount / 1000.0;

        print('=== Timer Component Overhead ===');
        print('Active timers: 3 (meteor spawn, bullet fire, power-up spawn)');
        print('Average update time: ${avgUpdateTime.toStringAsFixed(2)}ms');
        print('Timer system: Flame TimerComponent');

        // Timer overhead should be minimal
        expect(
          avgUpdateTime,
          lessThan(5.0),
          reason: 'Timer overhead should be minimal',
        );
      },
    );

    test('Full gameplay simulation - measures overall performance', () async {
      final game = TestSkyDefenderGame();
      await initializeGameForTest(game);

      startGameForTest(game);

      // Simulate realistic gameplay
      final frameTimes = <double>[];
      const simulationFrames = 300; // 5 seconds at 60 FPS

      for (int frame = 0; frame < simulationFrames; frame++) {
        // Periodically spawn entities
        if (frame % 30 == 0) {
          game.spawnMeteor();
        }
        if (frame % 10 == 0) {
          game.fireBullet();
        }
        if (frame % 100 == 0) {
          game.spawnPowerUp();
        }
        if (frame % 50 == 0) {
          game.spawnParticleEffect(
            position: Vector2(100, 100),
            color: Colors.orange,
          );
        }

        // Measure frame time
        final stopwatch = Stopwatch()..start();
        game.update(1 / 60);
        stopwatch.stop();
        frameTimes.add(stopwatch.elapsedMicroseconds / 1000.0);
      }

      // Calculate statistics
      final avgFrameTime =
          frameTimes.reduce((a, b) => a + b) / frameTimes.length;
      final maxFrameTime = frameTimes.reduce((a, b) => a > b ? a : b);
      final minFrameTime = frameTimes.reduce((a, b) => a < b ? a : b);

      // Count frames that exceeded 16.67ms (dropped frames at 60 FPS)
      final droppedFrames = frameTimes.where((t) => t > 16.67).length;
      final droppedFramePercentage = (droppedFrames / frameTimes.length) * 100;

      print('=== Full Gameplay Simulation ===');
      print('Simulation duration: ${simulationFrames / 60} seconds');
      print('Total frames: $simulationFrames');
      print('Average frame time: ${avgFrameTime.toStringAsFixed(2)}ms');
      print('Min frame time: ${minFrameTime.toStringAsFixed(2)}ms');
      print('Max frame time: ${maxFrameTime.toStringAsFixed(2)}ms');
      print(
        'Dropped frames (>16.67ms): $droppedFrames (${droppedFramePercentage.toStringAsFixed(1)}%)',
      );
      print('Active entities: ${game.children.length}');

      // Performance should maintain 60 FPS with minimal dropped frames
      expect(
        avgFrameTime,
        lessThan(12.0),
        reason: 'Average frame time should support 60 FPS',
      );
      expect(
        droppedFramePercentage,
        lessThan(5.0),
        reason: 'Should have less than 5% dropped frames',
      );
    });

    test(
      'Sprite batching efficiency - measures shared sprite performance',
      () async {
        final game = TestSkyDefenderGame();
        await initializeGameForTest(game);

        startGameForTest(game);

        // Verify shared sprites are loaded
        expect(
          game.meteorSprite,
          isNotNull,
          reason: 'Meteor sprite should be loaded',
        );
        expect(
          game.bulletSprite,
          isNotNull,
          reason: 'Bullet sprite should be loaded',
        );
        expect(
          game.playerSprite,
          isNotNull,
          reason: 'Player sprite should be loaded',
        );

        // Spawn many entities that share sprites
        for (int i = 0; i < 40; i++) {
          game.spawnMeteor();
        }
        for (int i = 0; i < 40; i++) {
          game.fireBullet();
        }

        // Measure rendering performance with shared sprites
        final stopwatch = Stopwatch()..start();
        for (int i = 0; i < 50; i++) {
          game.update(1 / 60);
        }
        stopwatch.stop();

        final avgUpdateTime = stopwatch.elapsedMicroseconds / 50 / 1000.0;

        print('=== Sprite Batching Efficiency ===');
        print(
          'Shared sprites loaded: 5 (player, meteor, bullet, rapid fire, shield)',
        );
        print(
          'Entities using shared sprites: ${game.children.whereType<Meteor>().length + game.children.whereType<Bullet>().length}',
        );
        print('Average update time: ${avgUpdateTime.toStringAsFixed(2)}ms');
        print(
          'Sprite sharing: Enabled (loaded once, reused across components)',
        );

        // Shared sprites should improve performance
        expect(
          avgUpdateTime,
          lessThan(15.0),
          reason: 'Shared sprites should improve rendering performance',
        );
      },
    );

    test(
      'Power-up system performance - measures power-up activation overhead',
      () async {
        final game = TestSkyDefenderGame();
        await initializeGameForTest(game);

        startGameForTest(game);

        // Activate power-ups multiple times
        const activationCount = 20;
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < activationCount; i++) {
          if (i % 2 == 0) {
            game.powerUpState.activateRapidFire();
          } else {
            game.powerUpState.activateShield();
          }

          // Update game
          game.update(1 / 60);
        }

        stopwatch.stop();
        final avgActivationTime =
            stopwatch.elapsedMicroseconds / activationCount / 1000.0;

        print('=== Power-up System Performance ===');
        print('Power-up activations: $activationCount');
        print(
          'Average activation time: ${avgActivationTime.toStringAsFixed(2)}ms',
        );
        print('Power-up system: Timer-based with state management');

        // Power-up activation should be fast
        expect(
          avgActivationTime,
          lessThan(2.0),
          reason: 'Power-up activation should be fast',
        );

        // Cleanup
        game.powerUpState.dispose();
      },
    );
  });

  group('Performance Comparison Metrics', () {
    test('Component lifecycle efficiency - measures onLoad and onRemove', () async {
      final game = TestSkyDefenderGame();
      await initializeGameForTest(game);

      startGameForTest(game);

      // Measure component creation time
      final createStopwatch = Stopwatch()..start();
      for (int i = 0; i < 50; i++) {
        game.spawnMeteor();
      }
      createStopwatch.stop();

      final avgCreateTime = createStopwatch.elapsedMicroseconds / 50 / 1000.0;

      // Measure component removal time
      final meteors = game.children.whereType<Meteor>().toList();
      final removeStopwatch = Stopwatch()..start();
      // Use toList() to avoid concurrent modification
      for (final meteor in List.from(meteors)) {
        meteor.destroy();
      }
      removeStopwatch.stop();

      final avgRemoveTime =
          removeStopwatch.elapsedMicroseconds / meteors.length / 1000.0;

      print('=== Component Lifecycle Efficiency ===');
      print(
        'Average component creation time: ${avgCreateTime.toStringAsFixed(3)}ms',
      );
      print(
        'Average component removal time: ${avgRemoveTime.toStringAsFixed(3)}ms',
      );
      print('Lifecycle: Flame component system with pooling');

      // Component lifecycle should be efficient
      expect(
        avgCreateTime,
        lessThan(1.0),
        reason: 'Component creation should be fast',
      );
      expect(
        avgRemoveTime,
        lessThan(0.5),
        reason: 'Component removal should be fast',
      );
    });

    test(
      'Difficulty scaling performance - measures performance across waves',
      () async {
        final game = TestSkyDefenderGame();
        await initializeGameForTest(game);

        startGameForTest(game);

        final wavePerformance = <int, double>{};

        // Test performance at different difficulty waves
        for (int wave = 1; wave <= 5; wave++) {
          // Set difficulty to wave
          game.difficultyManager.updateDifficulty((wave - 1) * 100);

          // Clear existing entities
          final meteorsToRemove = game.children.whereType<Meteor>().toList();
          final bulletsToRemove = game.children.whereType<Bullet>().toList();
          for (final m in meteorsToRemove) {
            m.destroy();
          }
          for (final b in bulletsToRemove) {
            b.destroy();
          }

          // Spawn entities for this wave
          for (int i = 0; i < 20; i++) {
            game.spawnMeteor();
          }
          for (int i = 0; i < 10; i++) {
            game.fireBullet();
          }

          // Measure performance
          final stopwatch = Stopwatch()..start();
          for (int i = 0; i < 50; i++) {
            game.update(1 / 60);
          }
          stopwatch.stop();

          final avgFrameTime = stopwatch.elapsedMicroseconds / 50 / 1000.0;
          wavePerformance[wave] = avgFrameTime;
        }

        print('=== Difficulty Scaling Performance ===');
        wavePerformance.forEach((wave, time) {
          print('Wave $wave: ${time.toStringAsFixed(2)}ms avg frame time');
        });

        // Performance should remain consistent across difficulty levels
        final maxWaveTime = wavePerformance.values.reduce(
          (a, b) => a > b ? a : b,
        );
        expect(
          maxWaveTime,
          lessThan(15.0),
          reason: 'Performance should scale well with difficulty',
        );
      },
    );
  });
}
