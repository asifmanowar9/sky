# Design Document

## Overview

This design document outlines the architecture and implementation approach for adding pause functionality to the Sky Defender game. The pause feature will allow players to temporarily halt gameplay mid-game, providing options to resume or return to the home screen. The design integrates seamlessly with the existing Flame game architecture and overlay system.

## Architecture

### High-Level Structure

The pause feature will integrate into the existing game architecture:

```
SkyDefenderGame (FlameGame)
├── Pause State Management (new)
├── Pause Button Overlay (new)
└── Pause Menu Overlay (new)
```

### Game State Management

The game will have three primary states:
1. **Playing**: Normal gameplay with all systems active
2. **Paused**: Gameplay frozen, pause menu visible
3. **Not Started/Game Over**: Existing states (unchanged)

## Components and Interfaces

### 1. Pause State in SkyDefenderGame

Extend the existing `SkyDefenderGame` class with pause state management:

```dart
class SkyDefenderGame extends FlameGame {
  // Existing fields...
  
  // New pause state
  bool isPaused = false;
  
  // Methods
  void pauseGame();
  void resumeGame();
  void togglePause();
}
```

**Design Decisions:**
- Use a simple boolean flag for pause state
- Pause state is separate from `isGameOver` and `hasGameStarted`
- Pause is only available during active gameplay
- Leverage Flame's built-in `paused` property for automatic component freezing

### 2. Pause Button Component

A new overlay widget that displays a pause button during gameplay:

```dart
class PauseButton extends StatelessWidget {
  final SkyDefenderGame game;
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      right: 20,
      child: IconButton(
        icon: Icon(Icons.pause),
        onPressed: () => game.pauseGame(),
      ),
    );
  }
}
```

**Design Decisions:**
- Position in top-right corner (currently occupied by home button, will need to adjust)
- Use standard Material Icons pause icon (two vertical bars)
- Size: 44x44 pixels for easy tapping (Material Design touch target)
- Semi-transparent dark background for visibility
- Only visible during active gameplay (not on start screen or game over)
- Will replace the current home button position; home button moves to pause menu

### 3. Pause Menu Overlay

A new overlay widget that displays when the game is paused:

```dart
class PauseMenu extends StatelessWidget {
  final SkyDefenderGame game;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      // Semi-transparent dark overlay
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('PAUSED'),
            ElevatedButton(
              onPressed: () => game.resumeGame(),
              child: Text('RESUME'),
            ),
            ElevatedButton(
              onPressed: () => game.goToStartScreen(),
              child: Text('HOME'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Design Decisions:**
- Full-screen overlay with semi-transparent background (80% opacity)
- Centered content with clear visual hierarchy
- "PAUSED" header in large, bold text
- Two action buttons: Resume (primary) and Home (secondary)
- Resume button styled prominently (green color)
- Home button styled as secondary action (orange color)
- Consistent styling with existing GameOver overlay

### 4. Update Method Modification

Modify the game's update loop to respect pause state:

```dart
@override
void update(double dt) {
  super.update(dt);
  
  // Don't update game logic if paused
  if (isPaused) return;
  
  // Existing update logic...
}
```

**Design Decisions:**
- Early return in update method when paused
- Flame's component system automatically handles pausing child components
- Timers and animations freeze naturally when update stops
- No need to manually pause individual components

## Data Models

### Game State Extensions

Add to existing `SkyDefenderGame`:

```dart
class SkyDefenderGame extends FlameGame {
  // Existing fields...
  bool isPaused = false;
  
  // Pause management methods
  void pauseGame() {
    if (!hasGameStarted || isGameOver || isPaused) return;
    
    isPaused = true;
    paused = true; // Flame's built-in pause
    overlays.remove('ScoreDisplay');
    overlays.add('PauseMenu');
  }
  
  void resumeGame() {
    if (!isPaused) return;
    
    isPaused = false;
    paused = false; // Flame's built-in resume
    overlays.remove('PauseMenu');
    overlays.add('ScoreDisplay');
  }
}
```

### Overlay Management

Update overlay visibility logic:

- **Start Screen**: No pause button
- **Active Gameplay**: Show pause button in ScoreDisplay
- **Paused State**: Hide ScoreDisplay, show PauseMenu
- **Game Over**: No pause button

## UI Layout Changes

### ScoreDisplay Overlay Update

Current layout:
```
Top-Left: Score, Lives, Wave
Top-Center: Power-up indicators
Top-Right: Home button
```

New layout:
```
Top-Left: Score, Lives, Wave
Top-Center: Power-up indicators
Top-Right: Pause button
```

**Design Decision:**
- Move home button from ScoreDisplay to PauseMenu
- This makes more sense UX-wise: players pause first, then decide to go home
- Prevents accidental exits during gameplay

## Pause Behavior Details

### What Gets Paused

When the game enters pause state:
1. **Game Loop**: Update method returns early
2. **Component Updates**: All Flame components stop updating (meteors, bullets, power-ups, particles)
3. **Timers**: All game timers freeze (spawn timers, power-up timers, difficulty timers)
4. **Animations**: Particle effects and wave transitions freeze
5. **Input**: Player movement and shooting disabled

### What Continues

When paused:
1. **Rendering**: Game scene remains visible (dimmed by overlay)
2. **UI**: Pause menu is interactive
3. **Streams**: Stream controllers remain active (for potential UI updates)

### Resume Behavior

When resuming from pause:
1. All timers continue from their paused values
2. All components resume movement and behavior
3. Power-up durations continue counting down
4. Difficulty progression unchanged
5. Score and lives preserved

### Home from Pause

When going home from pause menu:
1. Check and save high score if applicable
2. Reset all game state (same as existing `goToStartScreen()`)
3. Clear all game objects
4. Return to start screen
5. Reset pause state

## Error Handling

### Invalid Pause States

- Cannot pause if game hasn't started: Check `hasGameStarted`
- Cannot pause if game is over: Check `isGameOver`
- Cannot pause if already paused: Check `isPaused`
- All pause/resume methods include state validation

### Overlay Management

- Ensure overlays are properly added/removed during state transitions
- Prevent multiple pause menus from stacking
- Handle rapid pause/resume button presses gracefully

### Timer Synchronization

- Flame's built-in pause system handles timer freezing automatically
- No manual timer management needed
- Power-up timers will naturally pause with the game

## Testing Strategy

### Unit Testing Focus

1. **Pause State Management**
   - Test `pauseGame()` sets `isPaused` to true
   - Test `resumeGame()` sets `isPaused` to false
   - Test pause only works during active gameplay
   - Test cannot pause when game over or not started

2. **Overlay Management**
   - Test correct overlays shown in each state
   - Test overlay transitions during pause/resume
   - Test pause button visibility conditions

### Integration Testing

1. **Pause During Gameplay**
   - Verify all game entities freeze when paused
   - Verify timers stop counting
   - Verify power-up durations don't decrease while paused
   - Verify score and lives remain unchanged

2. **Resume Functionality**
   - Verify game continues from exact paused state
   - Verify meteor positions unchanged after resume
   - Verify power-up timers continue correctly
   - Verify player can immediately control ship

3. **Home from Pause**
   - Verify high score saved if applicable
   - Verify game state fully reset
   - Verify start screen displays correctly
   - Verify can start new game after returning home

### Manual Testing

- Test pause button is easily tappable during intense gameplay
- Verify pause menu is clearly visible and readable
- Test rapid pause/resume doesn't cause issues
- Verify pausing during power-up effects works correctly
- Test pausing during wave transitions
- Confirm no performance issues with pause/resume cycles

## Implementation Phases

The implementation will be done in a single phase:

1. Add pause state to `SkyDefenderGame`
2. Modify update method to respect pause state
3. Create `PauseMenu` overlay widget
4. Update `ScoreDisplay` to include pause button instead of home button
5. Implement pause/resume methods
6. Update overlay management logic
7. Test all pause scenarios

## Performance Considerations

- Pausing is lightweight: simply stops update loop
- No additional memory overhead (single boolean flag)
- Overlay rendering is minimal (static UI elements)
- Resume is instant (no state reconstruction needed)
- No impact on game performance when not paused

## Dependencies

No new dependencies required. The pause feature uses:
- Existing Flame game engine capabilities
- Flutter's built-in overlay system
- Material Design icons (already in use)

## Visual Design

### Pause Button

- Icon: `Icons.pause` (two vertical bars)
- Size: 44x44 pixels
- Background: Semi-transparent dark (`Colors.black.withOpacity(0.7)`)
- Border: Subtle white border for visibility
- Position: Top-right corner (40px from top, 20px from right)

### Pause Menu

- Background: Dark overlay (`Colors.black.withOpacity(0.8)`)
- Container: Rounded rectangle with border
- Header: "PAUSED" in large white text (48px, bold)
- Resume Button: Green background, white text, prominent
- Home Button: Orange background, white text, secondary
- Spacing: Consistent with existing GameOver overlay
- Centered on screen

## Accessibility Considerations

- Pause button meets minimum touch target size (44x44)
- High contrast between button and background
- Clear, readable text in pause menu
- Consistent with existing UI patterns
- Keyboard support (if applicable for web/desktop builds)
