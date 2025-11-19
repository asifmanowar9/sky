import 'package:flame/components.dart';

/// Represents a single particle with position, velocity, and lifetime
class Particle {
  Vector2 position;
  Vector2 velocity;
  double life; // Remaining lifetime in seconds
  final double maxLife; // Total lifetime for fade calculation

  Particle({required this.position, required this.velocity, required this.life})
    : maxLife = life;

  /// Update particle position and lifetime
  void update(double dt) {
    position += velocity * dt;
    life -= dt;
  }

  /// Get alpha value based on remaining life (fades out)
  double get alpha {
    return (life / maxLife).clamp(0.0, 1.0);
  }

  /// Check if particle is still alive
  bool get isAlive => life > 0;
}
