import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'particle.dart';

/// Component that manages a group of particles for visual effects
class ParticleEffect extends PositionComponent {
  final List<Particle> particles = [];
  final Color color;
  final double particleSize = 3.0;

  ParticleEffect({required this.color, required Vector2 position})
    : super(position: position);

  /// Spawn particles at the current position
  void spawn({required int count, double lifetime = 0.4}) {
    final random = Random();

    for (int i = 0; i < count; i++) {
      // Random angle for particle direction
      final angle = random.nextDouble() * 2 * pi;
      // Random speed between 50 and 150
      final speed = 50.0 + random.nextDouble() * 100.0;

      // Calculate velocity from angle and speed
      final velocity = Vector2(cos(angle) * speed, sin(angle) * speed);

      particles.add(
        Particle(
          position: Vector2.zero(), // Relative to effect position
          velocity: velocity,
          life: lifetime,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update all particles
    for (final particle in particles) {
      particle.update(dt);
    }

    // Remove dead particles
    particles.removeWhere((particle) => !particle.isAlive);

    // Remove effect when all particles are gone
    if (particles.isEmpty) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Render each particle
    for (final particle in particles) {
      final paint = Paint()
        ..color = color.withValues(alpha: particle.alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.position.x, particle.position.y),
        particleSize,
        paint,
      );
    }
  }
}
