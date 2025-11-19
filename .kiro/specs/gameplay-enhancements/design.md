# Design Document

## Overview

This design document outlines the architecture and implementation approach for enhancing the Sky Defender game with progressive difficulty, power-ups, meteor variety, visual effects, and persistent high scores. The design maintains the existing game architecture while extending it with new component types and game systems.

## Architecture

### High-Level Structure

The enhancements will follow Flame's component-based architecture:

```
SkyDefenderGame (FlameGame)
├── Player (existing)
├── Meteor (enhanced with types)
├── Bullet (existing)
├── PowerUp (new component)
├── ParticleEffect (new component)
└── DifficultyManager (new system)
```

### New Systems

1. **Difficulty System**: Manages wave progression and difficulty scaling
2. **Power-Up System**: Handles power-up spawning, collection, and effects
3. **Particle System**: Creates visual feedback for game events
4. **Persistence System**: Stores and retrieves high scores using shared_preferences

## Components and Interfaces

### 1. Difficulty Manager

A new class to manage difficulty progression:

```dart
class DifficultyManager {
  int currentWave = 1;
  double meteorSpawnInterval = 1.5;
  double meteorSpeed = 200.0;
  
  void updateDifficulty(int score);
  double getMeteorSpawnInterval();
  double getMeteorSpeed();
  int getCurrentWave();
}
```

**Design Decisions:**
- Encapsulates difficulty logic separate from main game class
- Wave advances every 100 points
- Spawn interval decreases by 0.1s per wave (min 0.5s)
- Meteor speed increases by 20 units per wave (max 400)
- Caps at wave 10 to prevent impossible difficulty

### 2. Meteor Types

Enhance existing Meteor component with type system:

```dart
enum MeteorType {
  small,  // 10 points, 1.0x speed, size 30
  medium, // 20 points, 0.8x speed, size 45
  large   // 30 points, 0.6x speed, size 60
}

class Meteor extends SpriteComponent {
  MeteorType type;
  int pointValue;
  double speedMultiplier;
  
  factory Meteor.random();
  factory Meteor.ofType(MeteorType type);
}
```

**Design Decisions:**
- Use enum for type safety
- Factory constructors for easy creation
- Weighted random selection (60% small, 30% medium, 10% large)
- Color coding: small=red, medium=orange, large=brown
- Larger meteors are slower but worth more points

### 3. Power-Up Component

New component for collectible power-ups:

```dart
enum PowerUpType {
  rapidFire,  // Increases fire rate by 50% for 5s
  shield      // Prevents 1 life loss for 8s
}

class PowerUp extends SpriteComponent with HasGameReference {
  PowerUpType type;
  double fallSpeed = 150.0;
  
  void onCollected();
}
```

**Design Decisions:**
- Falls slower than meteors (150 vs 200 speed)
- Spawns every 10-20 seconds randomly
- 50/50 chance for each type
- Visual distinction: rapidFire=yellow star, shield=blue circle
- Auto-removes if reaches bottom (not collected)

### 4. Power-Up State Management

Track active power-ups in game:

```dart
class PowerUpState {
  bool rapidFireActive = false;
  bool shieldActive = false;
  Timer? rapidFireTimer;
  Timer? shieldTimer;
  
  void activateRapidFire();
  void activateShield();
  void deactivate(PowerUpType type);
}
```

**Design Decisions:**
- Use timers for automatic expiration
- Collecting same power-up extends duration
- Shield prevents next life loss then deactivates
- Visual indicators in UI overlay

### 5. Particle Effect Component

Simple particle system for visual feedback:

```dart
class ParticleEffect extends PositionComponent {
  List<Particle> particles;
  Color color;
  double lifetime;
  
  void spawn(Vector2 position, Color color, int count);
}

class Particle {
  Vector2 position;
  Vector2 velocity;
  double life;
}
```

**Design Decisions:**
- Spawn 8-12 particles per effect
- Particles move outward from center
- Fade out over 0.3-0.5 seconds
- Use color matching destroyed object
- Auto-remove when all particles expire

### 6. High Score Persistence

Use shared_preferences for local storage:

```dart
class ScoreManager {
  static const String _highScoreKey = 'high_score';
  
  Future<int> getHighScore();
  Future<void> saveHighScore(int score);
  bool isNewHighScore(int currentScore);
}
```

**Design Decisions:**
- Use shared_preferences package (lightweight, cross-platform)
- Single key-value storage
- Load on game start
- Save immediately when new high score achieved
- Display on start screen and game over screen

## Data Models

### Game State Extensions

Add to existing SkyDefenderGame:

```dart
class SkyDefenderGame extends FlameGame {
  // Existing fields...
  
  // New fields
  DifficultyManager difficultyManager = DifficultyManager();
  PowerUpState powerUpState = PowerUpState();
  ScoreManager scoreManager = ScoreManager();
  
  int highScore = 0;
  double powerUpSpawnTimer = 0;
  double nextPowerUpSpawn = 15.0; // Random 10-20s
  
  // New streams
  StreamController<int> _waveController;
  StreamController<PowerUpState> _powerUpController;
}
```

### Collision Detection Updates

Extend collision checking:

```dart
void checkCollisions() {
  // Existing: bullets vs meteors
  checkBulletMeteorCollisions();
  
  // New: player vs power-ups
  checkPlayerPowerUpCollisions();
  
  // New: player vs meteors (if shield active)
  checkPlayerMeteorCollisions();
}
```

## Error Handling

### Sprite Loading Failures

- All new components follow existing pattern: try to load sprite, fallback to colored shapes
- PowerUp: yellow star (rapidFire) or blue circle (shield) shapes
- Meteor types: different sized circles with type-specific colors

### Persistence Failures

- If shared_preferences fails to load: default highScore to 0
- If save fails: log error but don't crash game
- Graceful degradation: game continues without persistence

### Timer Management

- Cancel all timers in onRemove() to prevent memory leaks
- Check timer state before canceling
- Reset timers on game restart

## Testing Strategy

### Unit Testing Focus

1. **DifficultyManager**
   - Test wave calculation from score
   - Verify spawn interval decreases correctly
   - Verify speed increases correctly
   - Test difficulty cap at wave 10

2. **PowerUpState**
   - Test activation and deactivation
   - Verify timer behavior
   - Test shield consumption on life loss

3. **ScoreManager**
   - Test high score comparison
   - Mock shared_preferences for testing
   - Test save/load operations

### Integration Testing

1. **Difficulty Progression**
   - Verify meteors spawn faster as score increases
   - Verify wave number updates correctly
   - Test visual wave transition feedback

2. **Power-Up Collection**
   - Verify collision detection works
   - Test power-up effects activate correctly
   - Verify UI updates show active power-ups

3. **Meteor Variety**
   - Verify different types spawn with correct distribution
   - Test point values award correctly
   - Verify visual distinction is clear

4. **Particle Effects**
   - Verify effects spawn on collisions
   - Test particle lifecycle and cleanup
   - Verify performance with multiple effects

5. **High Score Persistence**
   - Test score persists across app restarts
   - Verify new high score detection
   - Test UI displays correct values

### Manual Testing

- Play through multiple waves to verify difficulty feels balanced
- Test power-up collection and effects feel impactful
- Verify visual effects enhance experience without causing lag
- Confirm high score persists after closing and reopening app

## Implementation Phases

The implementation will be done incrementally:

1. **Phase 1**: Difficulty system and meteor types
2. **Phase 2**: Power-up system
3. **Phase 3**: Particle effects
4. **Phase 4**: High score persistence
5. **Phase 5**: UI updates and polish

Each phase builds on the previous, ensuring the game remains playable throughout development.

## Performance Considerations

- Limit active particles to prevent performance issues (max 50 particles on screen)
- Remove off-screen power-ups to prevent memory buildup
- Use object pooling for particles if performance issues arise
- Profile particle rendering on lower-end devices

## Dependencies

New packages required:

```yaml
dependencies:
  shared_preferences: ^2.2.0  # For high score persistence
```

Flame already provides particle system support, so no additional game engine dependencies needed.
