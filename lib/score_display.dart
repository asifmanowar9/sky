import 'package:flutter/material.dart';
import 'sky_defender_game.dart';

class ScoreDisplay extends StatelessWidget {
  final SkyDefenderGame game;

  const ScoreDisplay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Score and Lives Display (top-left)
        Positioned(
          top: 40,
          left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<int>(
                  stream: game.scoreStream,
                  initialData: game.score,
                  builder: (context, snapshot) {
                    return Text(
                      'Score: ${snapshot.data ?? 0}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                StreamBuilder<int>(
                  stream: game.livesStream,
                  initialData: game.lives,
                  builder: (context, snapshot) {
                    return Text(
                      'Lives: ${snapshot.data ?? 3}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Home Button (top-right)
        Positioned(
          top: 40,
          right: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: IconButton(
              onPressed: () {
                game.goToStartScreen();
              },
              icon: const Icon(Icons.home, color: Colors.white, size: 24),
              tooltip: 'Home',
            ),
          ),
        ),
      ],
    );
  }
}
