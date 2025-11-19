import 'package:flutter/material.dart';
import 'design_system.dart';
import 'sky_defender_game.dart';
import 'widgets/glassmorphic_container.dart';
import 'widgets/modern_button.dart';
import 'widgets/animated_value.dart';

class GameOverOverlay extends StatefulWidget {
  final SkyDefenderGame game;

  const GameOverOverlay({super.key, required this.game});

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Setup entrance animation (scale + fade)
    _animationController = AnimationController(
      duration: DesignSystem.durationSlow,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: DesignSystem.curveBackOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: DesignSystem.curveDefault,
      ),
    );

    // Start entrance animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = DesignSystem.isSmallScreen(context);
    final responsivePadding = DesignSystem.responsivePadding(
      context,
      DesignSystem.spacingXL,
    );
    final reducedMotion = DesignSystem.prefersReducedMotion(context);

    return Semantics(
      label: widget.game.isNewHighScore
          ? 'Game over. New high score!'
          : 'Game over',
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: DesignSystem.blackOverlay.withValues(
          alpha: DesignSystem.opacityOverlay,
        ),
        child: Center(
          child: FadeTransition(
            opacity: reducedMotion
                ? const AlwaysStoppedAnimation(1.0)
                : _fadeAnimation,
            child: ScaleTransition(
              scale: reducedMotion
                  ? const AlwaysStoppedAnimation(1.0)
                  : _scaleAnimation,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: responsivePadding),
                  child: GlassmorphicContainer(
                    sigmaX: DesignSystem.blurRadiusHeavy,
                    sigmaY: DesignSystem.blurRadiusHeavy,
                    borderRadius: DesignSystem.borderRadiusXLarge,
                    gradient: DesignSystem.darkGlassmorphicGradient,
                    padding: EdgeInsets.all(responsivePadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Game Over Title
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              DesignSystem.crimsonRed,
                              DesignSystem.sunsetOrange,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'GAME OVER',
                            style: DesignSystem.heading1.copyWith(
                              fontSize: DesignSystem.responsiveFontSize(
                                context,
                                48,
                              ),
                              color: DesignSystem.pureWhite,
                            ),
                          ),
                        ),
                        SizedBox(height: DesignSystem.spacingM),

                        // High Score Celebration (if new high score)
                        if (widget.game.isNewHighScore)
                          _buildHighScoreCelebration(isSmallScreen),

                        // Final Score Display
                        _buildScoreDisplay(isSmallScreen),

                        SizedBox(height: DesignSystem.spacingL),

                        // Action Buttons
                        _buildActionButtons(context, isSmallScreen),
                      ],
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

  /// Builds the high score celebration component with golden gradient
  Widget _buildHighScoreCelebration(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.only(bottom: DesignSystem.spacingM),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: DesignSystem.spacingM,
                vertical: DesignSystem.spacingS,
              ),
              decoration: BoxDecoration(
                gradient: DesignSystem.highScoreGradient,
                borderRadius: DesignSystem.borderRadiusMedium,
                boxShadow: DesignSystem.glowStrong(DesignSystem.goldenYellow),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: isSmallScreen ? 28 : 32,
                    color: DesignSystem.pureWhite,
                  ),
                  SizedBox(width: DesignSystem.spacingS),
                  Text(
                    'NEW HIGH SCORE!',
                    style: DesignSystem.heading3.copyWith(
                      fontSize: DesignSystem.responsiveFontSize(
                        context,
                        isSmallScreen ? 20 : 24,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: DesignSystem.spacingS),
                  Icon(
                    Icons.emoji_events,
                    size: isSmallScreen ? 28 : 32,
                    color: DesignSystem.pureWhite,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the score display section with animated values
  Widget _buildScoreDisplay(bool isSmallScreen) {
    return Column(
      children: [
        // Final Score Label
        Text(
          'FINAL SCORE',
          style: DesignSystem.label.copyWith(
            fontSize: DesignSystem.responsiveFontSize(context, 12),
            color: DesignSystem.lightGray,
          ),
        ),
        SizedBox(height: DesignSystem.spacingXS),

        // Animated Final Score Value
        StreamBuilder<int>(
          stream: widget.game.scoreStream,
          initialData: widget.game.score,
          builder: (context, snapshot) {
            final score = snapshot.data ?? 0;
            return Semantics(
              label: DesignSystem.scoreSemanticLabel(score),
              child: AnimatedValue(
                value: score,
                textStyle: DesignSystem.heading1.copyWith(
                  fontSize: DesignSystem.responsiveFontSize(
                    context,
                    isSmallScreen ? 40 : 48,
                  ),
                  fontWeight: FontWeight.bold,
                ),
                scaleFactor: 1.1,
                useColorFlash: true,
                flashColor: DesignSystem.electricCyan,
              ),
            );
          },
        ),

        SizedBox(height: DesignSystem.spacingM),

        // High Score Display
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: DesignSystem.spacingM,
            vertical: DesignSystem.spacingS,
          ),
          decoration: BoxDecoration(
            color: DesignSystem.darkGray.withValues(alpha: 0.5),
            borderRadius: DesignSystem.borderRadiusMedium,
            border: Border.all(
              color: DesignSystem.goldenYellow.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.emoji_events,
                size: isSmallScreen ? 20 : 24,
                color: DesignSystem.goldenYellow,
              ),
              SizedBox(width: DesignSystem.spacingXS),
              Text(
                'High Score: ',
                style: DesignSystem.bodyLarge.copyWith(
                  fontSize: DesignSystem.responsiveFontSize(
                    context,
                    isSmallScreen ? 16 : 20,
                  ),
                  color: DesignSystem.lightGray,
                ),
              ),
              StreamBuilder<int>(
                stream: widget.game.highScoreStream,
                initialData: widget.game.highScore,
                builder: (context, snapshot) {
                  final highScore = snapshot.data ?? 0;
                  return Semantics(
                    label: DesignSystem.highScoreSemanticLabel(highScore),
                    child: AnimatedValue(
                      value: highScore,
                      textStyle: DesignSystem.bodyLarge.copyWith(
                        fontSize: DesignSystem.responsiveFontSize(
                          context,
                          isSmallScreen ? 16 : 20,
                        ),
                        color: DesignSystem.goldenYellow,
                        fontWeight: FontWeight.bold,
                      ),
                      scaleFactor: 1.15,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the action buttons with proper visual hierarchy
  Widget _buildActionButtons(BuildContext context, bool isSmallScreen) {
    // Use vertical layout on small screens, horizontal on larger screens
    if (isSmallScreen) {
      return Column(
        children: [
          // Restart Button (Primary action)
          ModernButton(
            label: 'RESTART',
            onPressed: () {
              widget.game.restartGame();
            },
            style: ModernButtonStyle.primary,
            leadingIcon: Icons.refresh,
            width: double.infinity,
            height: DesignSystem.minTouchTarget,
          ),
          SizedBox(height: DesignSystem.spacingS),
          // Home Button (Secondary action)
          ModernButton(
            label: 'HOME',
            onPressed: () {
              widget.game.goToStartScreen();
            },
            style: ModernButtonStyle.secondary,
            leadingIcon: Icons.home,
            width: double.infinity,
            height: DesignSystem.minTouchTarget,
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Home Button (Secondary action)
          ModernButton(
            label: 'HOME',
            onPressed: () {
              widget.game.goToStartScreen();
            },
            style: ModernButtonStyle.secondary,
            leadingIcon: Icons.home,
            width: 180,
          ),
          SizedBox(width: DesignSystem.spacingS),
          // Restart Button (Primary action)
          ModernButton(
            label: 'RESTART',
            onPressed: () {
              widget.game.restartGame();
            },
            style: ModernButtonStyle.primary,
            leadingIcon: Icons.refresh,
            width: 180,
          ),
        ],
      );
    }
  }
}
