import 'package:flutter/material.dart';
import 'sky_defender_game.dart';
import 'power_up_state.dart';
import 'design_system.dart';
import 'widgets/glassmorphic_container.dart';
import 'widgets/animated_value.dart';

class ScoreDisplay extends StatelessWidget {
  final SkyDefenderGame game;

  const ScoreDisplay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = DesignSystem.isSmallScreen(context);
    final topPosition = isSmallScreen ? 20.0 : 40.0;
    final leftPosition = isSmallScreen ? 10.0 : 20.0;
    final rightPosition = isSmallScreen ? 10.0 : 20.0;
    final statsPadding = DesignSystem.responsivePadding(
      context,
      DesignSystem.spacingS,
    );

    return Stack(
      children: [
        // Score, Lives, and Wave Display (top-left)
        Positioned(
          top: topPosition,
          left: leftPosition,
          child: GlassmorphicContainer(
            sigmaX: DesignSystem.blurRadiusLight,
            sigmaY: DesignSystem.blurRadiusLight,
            opacity: 0.15,
            borderRadius: DesignSystem.borderRadiusMedium,
            padding: EdgeInsets.all(statsPadding),
            backgroundColor: DesignSystem.darkGray,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Score
                StreamBuilder<int>(
                  stream: game.scoreStream,
                  initialData: game.score,
                  builder: (context, snapshot) {
                    final score = snapshot.data ?? 0;
                    return Semantics(
                      label: DesignSystem.scoreSemanticLabel(score),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.stars,
                            color: DesignSystem.goldenYellow,
                            size: 20,
                          ),
                          SizedBox(width: DesignSystem.spacingXS),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'SCORE',
                                style: DesignSystem.label.copyWith(
                                  fontSize: 10,
                                ),
                              ),
                              AnimatedValue(
                                value: score,
                                textStyle: DesignSystem.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                useColorFlash: true,
                                flashColor: DesignSystem.goldenYellow,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: DesignSystem.spacingS),
                // Lives
                StreamBuilder<int>(
                  stream: game.livesStream,
                  initialData: game.lives,
                  builder: (context, snapshot) {
                    final lives = snapshot.data ?? 3;
                    return Semantics(
                      label: DesignSystem.livesSemanticLabel(lives),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite,
                            color: DesignSystem.crimsonRed,
                            size: 20,
                          ),
                          SizedBox(width: DesignSystem.spacingXS),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'LIVES',
                                style: DesignSystem.label.copyWith(
                                  fontSize: 10,
                                ),
                              ),
                              AnimatedValue(
                                value: lives,
                                textStyle: DesignSystem.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: lives <= 1
                                      ? DesignSystem.crimsonRed
                                      : DesignSystem.pureWhite,
                                ),
                                useColorFlash: true,
                                flashColor: DesignSystem.crimsonRed,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: DesignSystem.spacingS),
                // Wave
                StreamBuilder<int>(
                  stream: game.waveStream,
                  initialData: game.difficultyManager.currentWave,
                  builder: (context, snapshot) {
                    final wave = snapshot.data ?? 1;
                    return Semantics(
                      label: DesignSystem.waveSemanticLabel(wave),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.waves,
                            color: DesignSystem.electricCyan,
                            size: 20,
                          ),
                          SizedBox(width: DesignSystem.spacingXS),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'WAVE',
                                style: DesignSystem.label.copyWith(
                                  fontSize: 10,
                                ),
                              ),
                              AnimatedValue(
                                value: wave,
                                textStyle: DesignSystem.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: DesignSystem.electricCyan,
                                ),
                                useColorFlash: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Power-Up Indicators (top-center)
        Positioned(
          top: topPosition,
          left: 0,
          right: 0,
          child: StreamBuilder<PowerUpState>(
            stream: game.powerUpStream,
            initialData: game.powerUpState,
            builder: (context, snapshot) {
              final state = snapshot.data ?? game.powerUpState;
              final hasActivePowerUps =
                  state.rapidFireActive || state.shieldActive;

              return AnimatedSwitcher(
                duration: DesignSystem.durationNormal,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.5),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: hasActivePowerUps
                    ? Center(
                        key: const ValueKey('power-ups-active'),
                        child: GlassmorphicContainer(
                          sigmaX: DesignSystem.blurRadiusLight,
                          sigmaY: DesignSystem.blurRadiusLight,
                          opacity: 0.15,
                          borderRadius: DesignSystem.borderRadiusMedium,
                          padding: EdgeInsets.symmetric(
                            horizontal: DesignSystem.spacingS,
                            vertical: DesignSystem.spacingS,
                          ),
                          backgroundColor: DesignSystem.darkGray,
                          borderColor: DesignSystem.neonGreen,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (state.rapidFireActive) ...[
                                _PulsingPowerUpIndicator(
                                  icon: Icons.flash_on,
                                  label: 'RAPID FIRE',
                                  color: DesignSystem.goldenYellow,
                                ),
                              ],
                              if (state.rapidFireActive && state.shieldActive)
                                SizedBox(width: DesignSystem.spacingM),
                              if (state.shieldActive) ...[
                                _PulsingPowerUpIndicator(
                                  icon: Icons.shield,
                                  label: 'SHIELD',
                                  color: DesignSystem.electricCyan,
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(
                        key: ValueKey('power-ups-inactive'),
                      ),
              );
            },
          ),
        ),

        // Wave Transition Feedback
        Positioned.fill(
          child: IgnorePointer(
            ignoring: false,
            child: StreamBuilder<int>(
              stream: game.waveStream,
              initialData: game.difficultyManager.currentWave,
              builder: (context, snapshot) {
                return _WaveTransitionOverlay(wave: snapshot.data ?? 1);
              },
            ),
          ),
        ),

        // Pause Button (top-right)
        Positioned(
          top: topPosition,
          right: rightPosition,
          child: _ModernPauseButton(
            onPressed: () {
              game.pauseGame();
            },
          ),
        ),
      ],
    );
  }
}

/// Pulsing power-up indicator with animated glow effect
class _PulsingPowerUpIndicator extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PulsingPowerUpIndicator({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  State<_PulsingPowerUpIndicator> createState() =>
      _PulsingPowerUpIndicatorState();
}

class _PulsingPowerUpIndicatorState extends State<_PulsingPowerUpIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: DesignSystem.powerUpSemanticLabel(widget.label, true),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: _pulseAnimation.value),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, color: widget.color, size: 24),
                SizedBox(width: DesignSystem.spacingXS),
                Text(
                  widget.label,
                  style: DesignSystem.body.copyWith(
                    color: widget.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Modern pause button with glassmorphic background, hover, press, and ripple effects
class _ModernPauseButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _ModernPauseButton({required this.onPressed});

  @override
  State<_ModernPauseButton> createState() => _ModernPauseButtonState();
}

class _ModernPauseButtonState extends State<_ModernPauseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DesignSystem.durationInstant,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: DesignSystem.curveDefault),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final buttonSize = DesignSystem.ensureMinTouchTarget(
      DesignSystem.spacingS * 2 + 24,
    );

    return Semantics(
      button: true,
      label: 'Pause game',
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: widget.onPressed,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedScale(
              scale: _isHovered ? 1.05 : 1.0,
              duration: DesignSystem.accessibleDuration(
                context,
                DesignSystem.durationFast,
              ),
              curve: DesignSystem.accessibleCurve(
                context,
                DesignSystem.curveDefault,
              ),
              child: AnimatedContainer(
                duration: DesignSystem.accessibleDuration(
                  context,
                  DesignSystem.durationFast,
                ),
                curve: DesignSystem.accessibleCurve(
                  context,
                  DesignSystem.curveDefault,
                ),
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  color: DesignSystem.darkGray.withValues(
                    alpha: _isHovered ? 0.9 : 0.8,
                  ),
                  borderRadius: DesignSystem.borderRadiusSmall,
                  border: Border.all(
                    color: Colors.white.withValues(
                      alpha: _isHovered ? 0.25 : 0.15,
                    ),
                    width: 1.5,
                  ),
                  boxShadow: _isHovered
                      ? DesignSystem.glowMedium(DesignSystem.electricCyan)
                      : DesignSystem.glowSubtle(DesignSystem.electricCyan),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onPressed,
                    borderRadius: DesignSystem.borderRadiusSmall,
                    splashColor: Colors.white.withValues(alpha: 0.3),
                    highlightColor: Colors.white.withValues(alpha: 0.1),
                    child: Center(
                      child: Icon(
                        Icons.pause,
                        color: DesignSystem.pureWhite,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WaveTransitionOverlay extends StatefulWidget {
  final int wave;

  const _WaveTransitionOverlay({required this.wave});

  @override
  State<_WaveTransitionOverlay> createState() => _WaveTransitionOverlayState();
}

class _WaveTransitionOverlayState extends State<_WaveTransitionOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  int _previousWave = 1;
  bool _showTransition = false;

  @override
  void initState() {
    super.initState();
    _previousWave = widget.wave;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Smooth fade-in and fade-out transitions
    // Timeline: 0-200ms fade in, 200-1200ms hold, 1200-1500ms fade out
    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 13.3, // ~200ms
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 66.7, // ~1000ms hold
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20.0, // ~300ms
      ),
    ]).animate(_controller);

    // Scale animation with overshoot effect: 0.8 → 1.2 → 1.0
    // Timeline: 0-200ms scale to 1.2 (overshoot), 200-400ms settle to 1.0
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.8,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 13.3, // ~200ms
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.2,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 13.3, // ~200ms
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 73.4, // Hold at 1.0 for remainder
      ),
    ]).animate(_controller);

    // Pulsing glow effect that intensifies during the hold period
    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.3,
          end: 0.7,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.7,
          end: 0.5,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.5,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(_WaveTransitionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.wave != _previousWave && widget.wave > 1) {
      _previousWave = widget.wave;
      _showTransition = true;
      _controller.forward(from: 0.0).then((_) {
        if (mounted) {
          setState(() {
            _showTransition = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showTransition) {
      return const SizedBox.shrink();
    }

    final reducedMotion = DesignSystem.prefersReducedMotion(context);

    return Semantics(
      liveRegion: true,
      label: 'Wave ${widget.wave} starting',
      child: IgnorePointer(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: reducedMotion ? 1.0 : _fadeAnimation.value,
                child: Transform.scale(
                  scale: reducedMotion ? 1.0 : _scaleAnimation.value,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: DesignSystem.spacingXL,
                      vertical: DesignSystem.spacingM,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          DesignSystem.electricCyan.withValues(alpha: 0.95),
                          DesignSystem.cosmicPurple.withValues(alpha: 0.95),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(
                        DesignSystem.radiusLarge,
                      ),
                      border: Border.all(
                        color: DesignSystem.pureWhite.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: reducedMotion
                          ? [
                              BoxShadow(
                                color: DesignSystem.electricCyan.withValues(
                                  alpha: 0.5,
                                ),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ]
                          : [
                              // Primary glow effect
                              BoxShadow(
                                color: DesignSystem.electricCyan.withValues(
                                  alpha: _glowAnimation.value,
                                ),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                              // Secondary glow for depth
                              BoxShadow(
                                color: DesignSystem.cosmicPurple.withValues(
                                  alpha: _glowAnimation.value * 0.6,
                                ),
                                blurRadius: 60,
                                spreadRadius: 5,
                              ),
                              // Elevation shadow
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                    ),
                    child: Text(
                      'WAVE ${widget.wave}',
                      style: DesignSystem.displayText.copyWith(
                        color: DesignSystem.pureWhite,
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6,
                        shadows: [
                          Shadow(
                            blurRadius: 20,
                            color: Colors.black.withValues(alpha: 0.8),
                            offset: const Offset(0, 4),
                          ),
                          Shadow(
                            blurRadius: 40,
                            color: DesignSystem.electricCyan.withValues(
                              alpha: 0.5,
                            ),
                            offset: Offset.zero,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
