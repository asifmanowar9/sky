import 'package:flutter_test/flutter_test.dart';
import 'package:sky/difficulty_manager.dart';
import 'package:sky/power_up_state.dart';
import 'package:sky/meteor_component.dart';
import 'package:sky/score_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sky/sky_defender_game.dart';

void main() {
  // Integration Tests for New Features
  group('Difficulty Progression Integration', () {
    test('spawn rate increases correctly with score', () {
      final manager = DifficultyManager();

      // Wave 1 (score 0-99)
      manager.updateDifficulty(0);
      expect(manager.getMeteorSpawnInterval(), 1.5);

      // Wave 2 (score 100-199)
      manager.updateDifficulty(100);
      expect(manager.getMeteorSpawnInterval(), 1.4);

      // Wave 5 (score 400-499)
      manager.updateDifficulty(400);
      expect(manager.getMeteorSpawnInterval(), 1.1);

      // Wave 10+ (capped)
      manager.updateDifficulty(1000);
      expect(manager.getMeteorSpawnInterval(), 0.6);
    });

    test('meteor speed increases correctly with score', () {
      final manager = DifficultyManager();

      // Wave 1
      manager.updateDifficulty(0);
      expect(manager.getMeteorSpeed(), 200.0);

      // Wave 2
      manager.updateDifficulty(100);
      expect(manager.getMeteorSpeed(), 220.0);

      // Wave 5
      manager.updateDifficulty(400);
      expect(manager.getMeteorSpeed(), 280.0);

      // Wave 10+ (capped at 400)
      manager.updateDifficulty(1000);
      expect(manager.getMeteorSpeed(), 380.0);
    });

    test('difficulty caps at wave 10', () {
      final manager = DifficultyManager();

      manager.updateDifficulty(2000);
      expect(manager.getCurrentWave(), 10);
      expect(manager.getMeteorSpawnInterval(), greaterThanOrEqualTo(0.5));
      expect(manager.getMeteorSpeed(), lessThanOrEqualTo(400.0));
    });
  });

  group('Meteor Type Distribution Integration', () {
    test('meteor types have correct point values', () {
      final small = Meteor.ofType(MeteorType.small);
      final medium = Meteor.ofType(MeteorType.medium);
      final large = Meteor.ofType(MeteorType.large);

      expect(small.pointValue, 10);
      expect(medium.pointValue, 20);
      expect(large.pointValue, 30);
    });

    test('meteor types have correct speed multipliers', () {
      final small = Meteor.ofType(MeteorType.small);
      final medium = Meteor.ofType(MeteorType.medium);
      final large = Meteor.ofType(MeteorType.large);

      expect(small.speedMultiplier, 1.0);
      expect(medium.speedMultiplier, 0.8);
      expect(large.speedMultiplier, 0.6);
    });

    test('random meteor distribution approximates expected percentages', () {
      // Generate 1000 meteors to test distribution
      final counts = {
        MeteorType.small: 0,
        MeteorType.medium: 0,
        MeteorType.large: 0,
      };

      for (int i = 0; i < 1000; i++) {
        final meteor = Meteor.random();
        counts[meteor.type] = counts[meteor.type]! + 1;
      }

      // Check distribution is approximately correct (with tolerance)
      // Small: ~60% (600 ± 100)
      expect(counts[MeteorType.small]!, greaterThan(500));
      expect(counts[MeteorType.small]!, lessThan(700));

      // Medium: ~30% (300 ± 80)
      expect(counts[MeteorType.medium]!, greaterThan(220));
      expect(counts[MeteorType.medium]!, lessThan(380));

      // Large: ~10% (100 ± 50)
      expect(counts[MeteorType.large]!, greaterThan(50));
      expect(counts[MeteorType.large]!, lessThan(150));
    });
  });

  group('Power-Up Collection Integration', () {
    test('rapid fire activates correctly', () {
      final state = PowerUpState();

      expect(state.rapidFireActive, false);

      state.activateRapidFire();

      expect(state.rapidFireActive, true);
      expect(state.rapidFireTimer, isNotNull);

      state.dispose();
    });

    test('shield activates correctly', () {
      final state = PowerUpState();

      expect(state.shieldActive, false);

      state.activateShield();

      expect(state.shieldActive, true);
      expect(state.shieldTimer, isNotNull);

      state.dispose();
    });

    test('collecting same power-up extends duration', () {
      final state = PowerUpState();

      state.activateRapidFire();
      final firstTimer = state.rapidFireTimer;

      // Activate again (simulating collecting another rapid fire)
      state.activateRapidFire();
      final secondTimer = state.rapidFireTimer;

      // Timer should be replaced with new one
      expect(secondTimer, isNotNull);
      expect(secondTimer, isNot(equals(firstTimer)));
      expect(state.rapidFireActive, true);

      state.dispose();
    });
  });

  group('Power-Up Timer Expiration Integration', () {
    test('rapid fire expires after 5 seconds', () async {
      final state = PowerUpState();

      state.activateRapidFire();
      expect(state.rapidFireActive, true);

      // Wait for expiration
      await Future.delayed(Duration(seconds: 6));

      expect(state.rapidFireActive, false);
      expect(state.rapidFireTimer, isNull);

      state.dispose();
    });

    test('shield expires after 8 seconds', () async {
      final state = PowerUpState();

      state.activateShield();
      expect(state.shieldActive, true);

      // Wait for expiration
      await Future.delayed(Duration(seconds: 9));

      expect(state.shieldActive, false);
      expect(state.shieldTimer, isNull);

      state.dispose();
    });

    test('multiple power-ups expire independently', () async {
      final state = PowerUpState();

      state.activateRapidFire();
      state.activateShield();

      expect(state.rapidFireActive, true);
      expect(state.shieldActive, true);

      // Wait for rapid fire to expire (5s)
      await Future.delayed(Duration(seconds: 6));

      expect(state.rapidFireActive, false);
      expect(state.shieldActive, true); // Shield still active

      // Wait for shield to expire (8s total)
      await Future.delayed(Duration(seconds: 3));

      expect(state.rapidFireActive, false);
      expect(state.shieldActive, false);

      state.dispose();
    });
  });

  group('Shield Life Loss Prevention Integration', () {
    test('shield can be consumed to prevent life loss', () {
      final state = PowerUpState();

      state.activateShield();
      expect(state.shieldActive, true);

      // Consume shield (simulating meteor hit)
      state.consumeShield();

      expect(state.shieldActive, false);
      expect(state.shieldTimer, isNull);

      state.dispose();
    });

    test('consuming shield when inactive does nothing', () {
      final state = PowerUpState();

      expect(state.shieldActive, false);

      // Try to consume when not active
      state.consumeShield();

      expect(state.shieldActive, false);

      state.dispose();
    });
  });

  group('High Score Persistence Integration', () {
    setUp(() async {
      // Clear shared preferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('high score saves and loads correctly', () async {
      final manager = ScoreManager();

      // Initially should be 0
      final initialScore = await manager.getHighScore();
      expect(initialScore, 0);

      // Save a high score
      await manager.saveHighScore(500);

      // Load and verify
      final loadedScore = await manager.getHighScore();
      expect(loadedScore, 500);
    });

    test('high score updates when new score is higher', () async {
      final manager = ScoreManager();

      await manager.saveHighScore(300);

      // Check if 500 is a new high score
      final isNew = manager.isNewHighScore(500, 300);
      expect(isNew, true);

      // Save new high score
      await manager.saveHighScore(500);

      final loadedScore = await manager.getHighScore();
      expect(loadedScore, 500);
    });

    test('high score does not update when score is lower', () async {
      final manager = ScoreManager();

      await manager.saveHighScore(500);

      // Check if 300 is a new high score
      final isNew = manager.isNewHighScore(300, 500);
      expect(isNew, false);

      // High score should remain 500
      final loadedScore = await manager.getHighScore();
      expect(loadedScore, 500);
    });

    test('high score persists across multiple sessions', () async {
      final manager1 = ScoreManager();
      await manager1.saveHighScore(750);

      // Simulate new session with new manager instance
      final manager2 = ScoreManager();
      final loadedScore = await manager2.getHighScore();

      expect(loadedScore, 750);
    });
  });

  // Existing Reset Tests
  group('DifficultyManager Reset', () {
    test('reset returns to initial state', () {
      final manager = DifficultyManager();

      // Progress difficulty
      manager.updateDifficulty(500);
      expect(manager.currentWave, greaterThan(1));

      // Reset
      manager.reset();

      // Verify reset
      expect(manager.currentWave, 1);
      expect(manager.getMeteorSpawnInterval(), 1.5);
      expect(manager.getMeteorSpeed(), 200.0);
    });

    test('reset works after multiple difficulty updates', () {
      final manager = DifficultyManager();

      // Progress through multiple waves
      manager.updateDifficulty(100);
      expect(manager.currentWave, 2);

      manager.updateDifficulty(300);
      expect(manager.currentWave, 4);

      manager.updateDifficulty(900);
      expect(manager.currentWave, 10); // Capped at max

      // Reset
      manager.reset();

      // Verify complete reset
      expect(manager.currentWave, 1);
      expect(manager.getMeteorSpawnInterval(), 1.5);
      expect(manager.getMeteorSpeed(), 200.0);
    });
  });

  group('PowerUpState Reset', () {
    test('reset cancels all timers and clears state', () {
      final state = PowerUpState();

      // Activate power-ups
      state.activateRapidFire();
      state.activateShield();

      expect(state.rapidFireActive, true);
      expect(state.shieldActive, true);

      // Reset
      state.reset();

      // Verify reset
      expect(state.rapidFireActive, false);
      expect(state.shieldActive, false);
      expect(state.rapidFireTimer, isNull);
      expect(state.shieldTimer, isNull);

      // Cleanup
      state.dispose();
    });

    test('reset works when only one power-up is active', () {
      final state = PowerUpState();

      // Activate only rapid fire
      state.activateRapidFire();
      expect(state.rapidFireActive, true);
      expect(state.shieldActive, false);

      // Reset
      state.reset();

      // Verify reset
      expect(state.rapidFireActive, false);
      expect(state.shieldActive, false);

      // Cleanup
      state.dispose();
    });

    test('reset works when no power-ups are active', () {
      final state = PowerUpState();

      // Reset without activating anything
      state.reset();

      // Verify state remains clean
      expect(state.rapidFireActive, false);
      expect(state.shieldActive, false);
      expect(state.rapidFireTimer, isNull);
      expect(state.shieldTimer, isNull);

      // Cleanup
      state.dispose();
    });
  });

  group('Pause Functionality Integration', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('cannot pause when game has not started', () {
      final game = SkyDefenderGame();

      // Game hasn't started yet
      expect(game.hasGameStarted, false);
      expect(game.isPaused, false);

      // Try to pause
      game.pauseGame();

      // Should remain unpaused
      expect(game.isPaused, false);
      expect(game.paused, false);
    });

    test('cannot pause when game is over', () {
      final game = SkyDefenderGame();

      // Simulate game over state
      game.hasGameStarted = true;
      game.isGameOver = true;
      expect(game.isPaused, false);

      // Try to pause
      game.pauseGame();

      // Should remain unpaused
      expect(game.isPaused, false);
      expect(game.paused, false);
    });

    test('pause sets correct state during active gameplay', () {
      final game = SkyDefenderGame();

      // Simulate active gameplay
      game.hasGameStarted = true;
      game.isGameOver = false;
      expect(game.isPaused, false);

      // Pause game
      game.pauseGame();

      // Verify pause state
      expect(game.isPaused, true);
      expect(game.paused, true); // Flame's built-in pause
    });

    test('resume clears pause state', () {
      final game = SkyDefenderGame();

      // Simulate paused game
      game.hasGameStarted = true;
      game.isPaused = true;
      game.paused = true;

      // Resume game
      game.resumeGame();

      // Verify resume state
      expect(game.isPaused, false);
      expect(game.paused, false);
    });

    test('cannot pause when already paused', () {
      final game = SkyDefenderGame();

      // Simulate paused game
      game.hasGameStarted = true;
      game.isPaused = true;
      game.paused = true;

      // Try to pause again
      game.pauseGame();

      // Should remain in same state
      expect(game.isPaused, true);
    });

    test('resume does nothing when not paused', () {
      final game = SkyDefenderGame();

      // Simulate active game (not paused)
      game.hasGameStarted = true;
      expect(game.isPaused, false);

      // Try to resume
      game.resumeGame();

      // Should remain unpaused
      expect(game.isPaused, false);
    });

    test('rapid pause/resume cycles work correctly', () {
      final game = SkyDefenderGame();

      // Simulate active game
      game.hasGameStarted = true;

      // Rapid pause/resume cycles
      for (int i = 0; i < 5; i++) {
        game.pauseGame();
        expect(game.isPaused, true);

        game.resumeGame();
        expect(game.isPaused, false);
      }

      // Final state should be unpaused
      expect(game.isPaused, false);
      expect(game.paused, false);
    });

    test('pause freezes game update loop', () {
      final game = SkyDefenderGame();

      // Simulate active game
      game.hasGameStarted = true;

      // Set spawn timer
      game.meteorSpawnTimer = 1.0;

      // Pause game
      game.pauseGame();

      // Update game (should not affect timers)
      game.update(0.5);

      // Timer should remain unchanged due to early return in update
      expect(game.meteorSpawnTimer, 1.0);
    });

    test('resume continues game from paused state', () {
      final game = SkyDefenderGame();

      // Simulate active game
      game.hasGameStarted = true;

      // Set spawn timer
      game.meteorSpawnTimer = 1.0;

      // Pause game
      game.pauseGame();
      final pausedTimer = game.meteorSpawnTimer;

      // Update while paused (should not change)
      game.update(0.1);
      expect(game.meteorSpawnTimer, pausedTimer);

      // Resume game
      game.resumeGame();

      // Update after resume (should increment)
      game.update(0.5);
      expect(game.meteorSpawnTimer, greaterThan(pausedTimer));
    });

    test('goToStartScreen resets pause state', () {
      final game = SkyDefenderGame();

      // Simulate paused game
      game.hasGameStarted = true;
      game.isPaused = true;

      // Go to start screen
      game.goToStartScreen();

      // Verify pause state is reset
      expect(game.isPaused, false);
      expect(game.hasGameStarted, false);
    });

    test('goToStartScreen saves high score before resetting', () async {
      final game = SkyDefenderGame();

      // Simulate game with score
      game.hasGameStarted = true;
      game.score = 500;

      // Go home
      game.goToStartScreen();

      // Verify high score was saved
      final savedScore = await game.scoreManager.getHighScore();
      expect(savedScore, 500);
    });

    test('pausing during power-up preserves active state', () {
      final game = SkyDefenderGame();

      // Simulate active game
      game.hasGameStarted = true;

      // Activate rapid fire
      game.powerUpState.activateRapidFire();
      expect(game.powerUpState.rapidFireActive, true);

      // Pause game
      game.pauseGame();

      // Power-up should still be active
      expect(game.powerUpState.rapidFireActive, true);

      // Resume game
      game.resumeGame();

      // Power-up should still be active
      expect(game.powerUpState.rapidFireActive, true);

      // Cleanup
      game.powerUpState.dispose();
    });

    test('pause stops spawn timers', () {
      final game = SkyDefenderGame();

      // Simulate active game
      game.hasGameStarted = true;

      // Set spawn timer to near spawn threshold
      game.meteorSpawnTimer = 1.4; // Close to 1.5s spawn interval

      // Pause game
      game.pauseGame();

      // Update game (should not increment timer)
      game.update(0.2);

      // Timer should remain unchanged
      expect(game.meteorSpawnTimer, 1.4);
    });

    test('resume continues spawn timers from paused values', () {
      final game = SkyDefenderGame();

      // Simulate active game
      game.hasGameStarted = true;

      // Set spawn timer
      game.meteorSpawnTimer = 1.0;

      // Pause game
      game.pauseGame();
      final pausedTimer = game.meteorSpawnTimer;

      // Resume game
      game.resumeGame();

      // Update game (should increment timer)
      game.update(0.5);

      // Timer should have increased from paused value
      expect(game.meteorSpawnTimer, greaterThan(pausedTimer));
    });

    test('pause stops power-up spawn timer', () {
      final game = SkyDefenderGame();

      // Simulate active game
      game.hasGameStarted = true;

      // Set power-up spawn timer
      game.powerUpSpawnTimer = 10.0;

      // Pause game
      game.pauseGame();

      // Update game (should not increment timer)
      game.update(1.0);

      // Timer should remain unchanged
      expect(game.powerUpSpawnTimer, 10.0);
    });

    test('pause stops bullet fire timer', () {
      final game = SkyDefenderGame();

      // Simulate active game
      game.hasGameStarted = true;

      // Set bullet fire timer
      game.bulletFireTimer = 0.2;

      // Pause game
      game.pauseGame();

      // Update game (should not increment timer)
      game.update(0.2);

      // Timer should remain unchanged
      expect(game.bulletFireTimer, 0.2);
    });
  });
}
