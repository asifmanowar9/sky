# Implementation Plan

- [x] 1. Implement difficulty progression system





  - Create DifficultyManager class with wave calculation logic
  - Add methods to calculate spawn interval and meteor speed based on wave
  - Integrate DifficultyManager into SkyDefenderGame
  - Update meteor spawning to use difficulty-based intervals and speeds
  - Add wave number to game state and create stream for UI updates
  - _Requirements: 1.1, 1.2, 1.3, 1.5_

- [x] 2. Enhance meteor component with type system





  - Create MeteorType enum with small, medium, and large variants
  - Add type, pointValue, and speedMultiplier fields to Meteor class
  - Implement factory constructor Meteor.random() with weighted selection (60/30/10)
  - Implement factory constructor Meteor.ofType() for specific types
  - Update meteor rendering to show different sizes and colors based on type
  - Update collision detection to award points based on meteor type
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 3. Create power-up system





- [x] 3.1 Implement PowerUp component


  - Create PowerUpType enum with rapidFire and shield variants
  - Create PowerUp component extending SpriteComponent with HasGameReference
  - Implement falling behavior at 150 speed
  - Add sprite loading with fallback shapes (yellow star, blue circle)
  - Implement auto-removal when reaching bottom
  - _Requirements: 2.1, 2.2_

- [x] 3.2 Implement power-up state management


  - Create PowerUpState class to track active power-ups
  - Add timer management for rapidFire (5s) and shield (8s) durations
  - Implement activateRapidFire() and activateShield() methods
  - Add automatic deactivation when timers expire
  - Create stream controller for power-up state updates
  - _Requirements: 2.3, 2.4, 2.5, 2.6_

- [x] 3.3 Integrate power-ups into game loop


  - Add power-up spawn timer with random 10-20 second intervals
  - Implement power-up spawning logic in game update loop
  - Add collision detection between player and power-ups
  - Modify bullet fire rate when rapidFire is active
  - Implement shield logic to prevent life loss
  - _Requirements: 2.1, 2.2, 2.3, 2.4_

- [x] 4. Implement particle effect system





  - Create Particle class with position, velocity, and lifetime
  - Create ParticleEffect component to manage particle groups
  - Implement spawn() method to create particles at collision points
  - Add particle update logic for movement and fading
  - Implement particle rendering with color and alpha
  - Add particle effects to bullet-meteor collisions
  - Add particle effects to power-up collection
  - Add screen shake effect when meteor reaches bottom
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 5. Implement high score persistence






- [x] 5.1 Add shared_preferences dependency and create ScoreManager

  - Add shared_preferences package to pubspec.yaml
  - Create ScoreManager class with getHighScore() and saveHighScore() methods
  - Implement isNewHighScore() comparison method
  - Add error handling for persistence failures
  - _Requirements: 5.1, 5.3_


- [x] 5.2 Integrate high score into game flow

  - Load high score on game initialization
  - Add highScore field to game state
  - Check for new high score in gameOver() method
  - Save new high score when achieved
  - Add "New High Score" detection and messaging
  - _Requirements: 5.1, 5.3, 5.4_

- [x] 6. Update UI overlays with new features





  - Add wave number display to ScoreDisplay overlay
  - Add active power-up indicators to ScoreDisplay overlay
  - Display high score on StartScreen overlay
  - Show current score and high score on GameOver overlay
  - Add "New High Score!" message to GameOver overlay when applicable
  - Add visual feedback for wave transitions
  - _Requirements: 1.3, 1.4, 2.5, 5.2, 5.4, 5.5_

- [x] 7. Update game restart and cleanup logic





  - Reset DifficultyManager state on game restart
  - Cancel and reset all power-up timers on restart
  - Clear all particles on restart
  - Ensure proper cleanup in onRemove() to prevent memory leaks
  - Test game restart maintains high score correctly
  - _Requirements: 1.1, 2.6_

- [x] 8. Write integration tests for new features






  - Test difficulty progression increases spawn rate and speed correctly
  - Test meteor type distribution matches expected percentages
  - Test power-up collection activates correct effects
  - Test power-up timers expire correctly
  - Test shield prevents life loss as expected
  - Test high score saves and loads correctly
  - Test particle effects spawn and cleanup properly
  - _Requirements: 1.1, 1.2, 2.2, 2.3, 2.4, 3.5, 4.1, 5.1_
