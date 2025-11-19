# Sky Defender

A fast-paced arcade game built with Flutter and Flame where you defend the skies against an endless meteor shower!

## Overview

Sky Defender is a classic arcade-style shooter where players control a spaceship at the bottom of the screen, automatically firing bullets to destroy incoming meteors. The game features simple touch/drag controls, progressive difficulty, and a lives system that challenges players to achieve the highest score possible.

## Features

- **Intuitive Controls**: Drag your finger or mouse to move the spaceship horizontally
- **Auto-Fire System**: Bullets fire automatically every 0.3 seconds
- **Dynamic Meteor Spawning**: Meteors spawn at random positions every 1.5 seconds
- **Lives System**: Start with 3 lives; lose one each time a meteor reaches the bottom
- **Score Tracking**: Earn 10 points for each meteor destroyed
- **Real-time UI Updates**: Live score and lives counter displayed during gameplay
- **Game States**: Start screen, active gameplay, and game over screen with restart options
- **Collision Detection**: Precise collision detection between bullets and meteors
- **Responsive Design**: Adapts to different screen sizes and orientations

## How to Play

1. **Start**: Launch the game and tap "Start Game" on the welcome screen
2. **Move**: Drag your finger (mobile) or mouse (desktop) left and right to move your spaceship
3. **Shoot**: Your spaceship fires bullets automatically - just focus on positioning!
4. **Defend**: Destroy meteors before they reach the bottom of the screen
5. **Survive**: You have 3 lives. Each meteor that reaches the bottom costs one life
6. **Score**: Earn 10 points for every meteor you destroy
7. **Game Over**: When all lives are lost, choose to restart or return to the start screen

## Technical Stack

- **Flutter SDK**: ^3.8.1
- **Dart**: ^3.8.1
- **Flame Engine**: ^1.30.1 (2D game engine)
- **Logger**: ^2.0.0 (structured logging)
- **Cupertino Icons**: ^1.0.8

## Prerequisites

Before running Sky Defender, ensure you have the following installed:

- **Flutter SDK** (version 3.8.1 or higher)
  - Download from: https://flutter.dev/docs/get-started/install
- **Dart SDK** (included with Flutter)
- **IDE** (recommended):
  - Android Studio with Flutter plugin
  - VS Code with Flutter extension
  - IntelliJ IDEA with Flutter plugin
- **Platform-specific requirements**:
  - **Android**: Android Studio, Android SDK
  - **iOS**: Xcode (macOS only), CocoaPods
  - **Web**: Chrome browser
  - **Desktop**: Platform-specific build tools (Windows SDK, Xcode, or Linux build essentials)

## Installation

1. **Clone or download the repository**:
   ```bash
   git clone <repository-url>
   cd sky
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify Flutter installation**:
   ```bash
   flutter doctor
   ```
   Resolve any issues reported by Flutter Doctor before proceeding.

## Running the Game

### Development Mode (Hot Reload Enabled)

```bash
flutter run
```

Select your target device when prompted (connected device, emulator, or Chrome for web).

### Platform-Specific Commands

**Android**:
```bash
flutter run -d android
```

**iOS** (macOS only):
```bash
flutter run -d ios
```

**Web**:
```bash
flutter run -d chrome
```

**Windows**:
```bash
flutter run -d windows
```

**macOS**:
```bash
flutter run -d macos
```

**Linux**:
```bash
flutter run -d linux
```

### Building for Release

**Android APK**:
```bash
flutter build apk --release
```

**iOS** (macOS only):
```bash
flutter build ios --release
```

**Web**:
```bash
flutter build web --release
```

**Desktop**:
```bash
flutter build windows --release  # Windows
flutter build macos --release    # macOS
flutter build linux --release    # Linux
```

## Project Structure

```
sky/
├── lib/
│   ├── main.dart              # Application entry point
│   ├── sky_defender_game.dart # Main game logic and state management
│   ├── player.dart            # Player spaceship component
│   ├── meteor.dart            # Meteor enemy component
│   ├── bullet.dart            # Bullet projectile component
│   ├── score_display.dart     # In-game score and lives UI overlay
│   ├── game_over.dart         # Game over screen overlay
│   └── start_screen.dart      # Welcome/start screen overlay
├── assets/
│   ├── images/                # Game sprite assets (player, meteor, bullet)
│   └── audio/                 # Sound effects and music (future)
├── test/
│   └── widget_test.dart       # Unit and widget tests
├── pubspec.yaml               # Project dependencies and configuration
└── README.md                  # This file
```

### Key Components

- **SkyDefenderGame**: Core game engine managing game loop, collision detection, spawning, and state
- **Player**: User-controlled spaceship with horizontal movement
- **Meteor**: Enemy objects that fall from the top of the screen
- **Bullet**: Projectiles fired automatically by the player
- **UI Overlays**: StartScreen, ScoreDisplay, and GameOver screens

## Development

### Code Quality

The codebase follows Flutter and Flame best practices:
- Uses current non-deprecated APIs (`HasGameReference`, `withValues()`)
- Implements structured logging with the `logger` package
- Follows Dart style guidelines with `flutter_lints`
- Component-based architecture for maintainability

### Logging

The game uses structured logging for debugging and monitoring:
- Game state transitions are logged (start, game over, restart)
- Logs include timestamps and severity levels
- Configured with `PrettyPrinter` for readable console output

### Testing

Run tests with:
```bash
flutter test
```

## Known Issues

- **Missing Sprite Assets**: The game currently uses colored shapes as placeholders:
  - Player: Blue rectangle (50x30)
  - Meteor: Red circle (40x40)
  - Bullet: Yellow rectangle (10x20)
  
  The game gracefully falls back to these shapes if sprite images are not found in `assets/images/`.

## Future Enhancements

Potential improvements for future versions:
- Add sprite graphics for player, meteors, and bullets
- Implement sound effects and background music
- Add power-ups (shields, rapid fire, multi-shot)
- Progressive difficulty (faster meteors, increased spawn rate)
- High score persistence using local storage
- Multiple meteor types with different behaviors
- Particle effects for explosions
- Background parallax scrolling
- Mobile haptic feedback
- Leaderboard integration
- Achievement system

## License

This project is available for personal and educational use. See the repository for specific license terms.

---

**Enjoy defending the skies!** 🚀☄️
