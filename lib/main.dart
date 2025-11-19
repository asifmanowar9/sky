import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'sky_defender_game.dart';
import 'score_display.dart';
import 'game_over.dart';
import 'start_screen.dart';
import 'pause_menu.dart';
import 'design_system.dart';

void main() {
  runApp(const SkyDefenderApp());
}

class SkyDefenderApp extends StatelessWidget {
  const SkyDefenderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sky Defender',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final SkyDefenderGame game;

  @override
  void initState() {
    super.initState();
    game = SkyDefenderGame();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;

        // Handle back button based on game state
        if (game.hasGameStarted && !game.isGameOver && !game.isPaused) {
          // During active gameplay, pause the game
          game.pauseGame();
        } else if (game.isPaused) {
          // If already paused, resume (or do nothing - user can use pause menu)
          // Optionally: game.resumeGame();
        } else if (game.isGameOver) {
          // On game over screen, go to start screen
          game.goToStartScreen();
        }
        // If on start screen, do nothing (don't exit app)
      },
      child: Scaffold(
        body: SafeArea(
          child: GameWidget<SkyDefenderGame>(
            game: game,
            overlayBuilderMap: {
              'StartScreen': (context, game) => AnimatedOverlay(
                key: const ValueKey('StartScreen'),
                child: StartScreen(game: game),
              ),
              'ScoreDisplay': (context, game) => ScoreDisplay(game: game),
              'GameOver': (context, game) => AnimatedOverlay(
                key: const ValueKey('GameOver'),
                child: GameOverOverlay(game: game),
              ),
              'PauseMenu': (context, game) => AnimatedOverlay(
                key: const ValueKey('PauseMenu'),
                child: PauseMenu(game: game),
              ),
            },
          ),
        ),
      ),
    );
  }
}

/// Animated wrapper for overlays with fade and scale transitions
class AnimatedOverlay extends StatefulWidget {
  final Widget child;

  const AnimatedOverlay({super.key, required this.child});

  @override
  State<AnimatedOverlay> createState() => _AnimatedOverlayState();
}

class _AnimatedOverlayState extends State<AnimatedOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Create animation controller with duration from design system
    _controller = AnimationController(
      duration: DesignSystem.durationSlow,
      vsync: this,
    );

    // Create fade animation (0.0 to 1.0)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: DesignSystem.curveDefault),
    );

    // Create scale animation (0.9 to 1.0) for subtle entrance effect
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: DesignSystem.curveBackOut),
    );

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
