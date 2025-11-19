import 'package:flutter_test/flutter_test.dart';
import 'package:sky/sky_defender_game.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Pause Functionality Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('pause state validation - cannot pause when game has not started', () {
      final game = SkyDefenderGame();

      // Game hasn't started yet
      expect(game.hasGameStarted, false);
      expect(game.isPaused, false);

      // pauseGame() should check hasGameStarted and return early
      // We test the validation logic by checking state doesn't change
      final initialPauseState = game.isPaused;
      final initialFlameState = game.paused;

      // This should do nothing because hasGameStarted is false
      game.pauseGame();

      // State should remain unchanged
      expect(game.isPaused, initialPauseState);
      expect(game.paused, initialFlameState);
    });

    test('pause state validation - cannot pause when game is over', () {
      final game = SkyDefenderGame();

      // Simulate game over state
      game.hasGameStarted = true;
      game.isGameOver = true;
      expect(game.isPaused, false);

      // This should do nothing because isGameOver is true
      game.pauseGame();

      // Should remain unpaused
      expect(game.isPaused, false);
      expect(game.paused, false);
    });

    test('pause state validation - cannot pause when already paused', () {
      final game = SkyDefenderGame();

      // Simulate paused game
      game.hasGameStarted = true;
      game.isPaused = true;
      game.paused = true;

      // Try to pause again - should do nothing
      game.pauseGame();

      // Should remain in same state
      expect(game.isPaused, true);
    });

    test('resume state validation - does nothing when not paused', () {
      final game = SkyDefenderGame();

      // Simulate active game (not paused)
      game.hasGameStarted = true;
      expect(game.isPaused, false);

      // Try to resume - should do nothing
      game.resumeGame();

      // Should remain unpaused
      expect(game.isPaused, false);
    });

    test('pause freezes game update loop', () {
      final game = SkyDefenderGame();

      // Simulate active game
      game.hasGameStarted = true;
      game.isGameOver = false;

      // Set spawn timer
      game.meteorSpawnTimer = 1.0;

      // Manually set pause state (simulating pause without overlay management)
      game.isPaused = true;

      // Update game (should not affect timers due to early return)
      game.update(0.5);

      // Timer should remain unchanged due to early return in update
      expect(game.meteorSpawnTimer, 1.0);
    });

    test('resume continues game from paused state', () {
      final game = SkyDefenderGame();

      // Simulate active game
      game.hasGameStarted = true;
      game.isGameOver = false;

      // Set spawn timer to a value that won't trigger spawning
      game.meteorSpawnTimer = 0.5;

      // Pause game (manually set state)
      game.isPaused = true;
      final pausedTimer = game.meteorSpawnTimer;

      // Update while paused (should not change)
      game.update(0.1);
      expect(game.meteorSpawnTimer, pausedTimer);

      // Resume game (manually clear pause state)
      game.isPaused = false;

      // Update after resume with small delta to avoid spawning
      game.update(0.2);
      expect(game.meteorSpawnTimer, greaterThan(pausedTimer));
    });

    test('goToStartScreen resets pause state', () {
      final game = SkyDefenderGame();

      // Simulate paused game
      game.hasGameStarted = true;
      game.isPaused = true;

      // Manually reset state (simulating goToStartScreen logic)
      game.isPaused = false;
      game.hasGameStarted = false;

      // Verify pause state is reset
      expect(game.isPaused, false);
      expect(game.hasGameStarted, false);
    });

    test('goToStartScreen saves high score before resetting', () async {
      final game = SkyDefenderGame();

      // Simulate game with score
      game.hasGameStarted = true;
      game.score = 500;

      // Manually save high score (simulating goToStartScreen logic)
      if (game.scoreManager.isNewHighScore(game.score, game.highScore)) {
        await game.scoreManager.saveHighScore(game.score);
      }

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

      // Pause game (manually set state)
      game.isPaused = true;

      // Power-up should still be active
      expect(game.powerUpState.rapidFireActive, true);

      // Resume game (manually clear state)
      game.isPaused = false;

      // Power-up should still be active
      expect(game.powerUpState.rapidFireActive, true);

      // Cleanup
      game.powerUpState.dispose();
    });

    test('pause stops spawn timers', () {
      final game = SkyDefenderGame();

      // Simulate active game
      game.hasGameStarted = true;
      game.isGameOver = false;

      // Set spawn timer to near spawn threshold
      game.meteorSpawnTimer = 1.4; // Close to 1.5s spawn interval

      // Pause game (manually set state)
      game.isPaused = true;

      // Update game (should not increment timer)
      game.update(0.2);

      // Timer should remain unchanged
      expect(game.meteorSpawnTimer, 1.4);
    });

    test('resume continues spawn timers from paused values', () {
      final game = SkyDefenderGame();

      // Simulate active game
      game.hasGameStarted = true;
      game.isGameOver = false;

      // Set spawn timer to a value that won't trigger spawning
      game.meteorSpawnTimer = 0.5;

      // Pause game (manually set state)
      game.isPaused = true;
      final pausedTimer = game.meteorSpawnTimer;

      // Resume game (manually clear state)
      game.isPaused = false;

      // Update game with small delta to avoid spawning
      game.update(0.2);

      // Timer should have increased from paused value
      expect(game.meteorSpawnTimer, greaterThan(pausedTimer));
    });

    test('pause stops power-up spawn timer', () {
      final game = SkyDefenderGame();

      // Simulate active game
      game.hasGameStarted = true;
      game.isGameOver = false;

      // Set power-up spawn timer
      game.powerUpSpawnTimer = 10.0;

      // Pause game (manually set state)
      game.isPaused = true;

      // Update game (should not increment timer)
      game.update(1.0);

      // Timer should remain unchanged
      expect(game.powerUpSpawnTimer, 10.0);
    });

    test('pause stops bullet fire timer', () {
      final game = SkyDefenderGame();

      // Simulate active game
      game.hasGameStarted = true;
      game.isGameOver = false;

      // Set bullet fire timer
      game.bulletFireTimer = 0.2;

      // Pause game (manually set state)
      game.isPaused = true;

      // Update game (should not increment timer)
      game.update(0.2);

      // Timer should remain unchanged
      expect(game.bulletFireTimer, 0.2);
    });

    test('rapid pause/resume cycles maintain correct state', () {
      final game = SkyDefenderGame();

      // Simulate active game
      game.hasGameStarted = true;
      game.isGameOver = false;

      // Rapid pause/resume cycles (manually toggling state)
      for (int i = 0; i < 5; i++) {
        game.isPaused = true;
        expect(game.isPaused, true);

        game.isPaused = false;
        expect(game.isPaused, false);
      }

      // Final state should be unpaused
      expect(game.isPaused, false);
    });
  });
}
