import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'sky_defender_game.dart';
import 'score_display.dart';
import 'game_over.dart';
import 'start_screen.dart';

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
      home: GameWidget<SkyDefenderGame>.controlled(
        gameFactory: SkyDefenderGame.new,
        overlayBuilderMap: {
          'StartScreen': (context, game) => StartScreen(game: game),
          'ScoreDisplay': (context, game) => ScoreDisplay(game: game),
          'GameOver': (context, game) => GameOverOverlay(game: game),
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
