import 'dart:ui';
import 'package:flutter/material.dart';
import 'sky_defender_game.dart';
import 'design_system.dart';
import 'widgets/glassmorphic_container.dart';
import 'widgets/modern_button.dart';

class PauseMenu extends StatefulWidget {
  final SkyDefenderGame game;

  const PauseMenu({super.key, required this.game});

  @override
  State<PauseMenu> createState() => _PauseMenuState();
}

class _PauseMenuState extends State<PauseMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignSystem.durationSlow,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildPauseContent(BuildContext context) {
    final isSmallScreen = DesignSystem.isSmallScreen(context);
    final horizontalMargin = DesignSystem.responsivePadding(context, 32);
    final containerPadding = DesignSystem.responsivePadding(context, 48);
    final maxWidth = DesignSystem.responsiveMaxWidth(context);
    final titleFontSize = DesignSystem.responsiveFontSize(context, 48);
    final buttonSpacing = DesignSystem.responsiveSpacing(context, 16);
    final titleSpacing = DesignSystem.responsiveSpacing(context, 48);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: GlassmorphicContainer(
        sigmaX: DesignSystem.blurRadiusHeavy,
        sigmaY: DesignSystem.blurRadiusHeavy,
        opacity: 0.15,
        borderRadius: BorderRadius.circular(
          DesignSystem.responsiveBorderRadius(
            context,
            DesignSystem.radiusXLarge,
          ),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DesignSystem.darkGray.withValues(alpha: 0.95),
            DesignSystem.deepSpaceBlue.withValues(alpha: 0.95),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(containerPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pause Title
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: DesignSystem.responsivePadding(context, 24),
                  vertical: DesignSystem.responsivePadding(context, 12),
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      DesignSystem.cosmicPurple,
                      DesignSystem.electricCyan,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(
                    DesignSystem.responsiveBorderRadius(
                      context,
                      DesignSystem.radiusMedium,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: DesignSystem.electricCyan.withValues(alpha: 0.5),
                      blurRadius: isSmallScreen ? 15 : 20,
                      spreadRadius: isSmallScreen ? 1 : 2,
                    ),
                  ],
                ),
                child: Text(
                  'PAUSED',
                  style: DesignSystem.heading1.copyWith(
                    fontSize: titleFontSize,
                    letterSpacing: isSmallScreen ? 2 : 4,
                    shadows: [
                      Shadow(
                        color: DesignSystem.electricCyan.withValues(alpha: 0.8),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: titleSpacing),

              // Resume Button
              ModernButton(
                label: 'RESUME',
                leadingIcon: Icons.play_arrow,
                onPressed: () {
                  widget.game.resumeGame();
                },
                style: ModernButtonStyle.success,
                width: double.infinity,
                height: DesignSystem.responsiveButtonHeight(context),
              ),

              SizedBox(height: buttonSpacing),

              // Home Button
              ModernButton(
                label: 'HOME',
                leadingIcon: Icons.home,
                onPressed: () {
                  widget.game.goToStartScreen();
                },
                style: ModernButtonStyle.secondary,
                width: double.infinity,
                height: DesignSystem.responsiveButtonHeight(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = DesignSystem.prefersReducedMotion(context);

    return Semantics(
      label: 'Game paused',
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withValues(
              alpha: reducedMotion ? 0.8 : 0.8 * _fadeAnimation.value,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: reducedMotion
                    ? DesignSystem.blurRadiusHeavy
                    : DesignSystem.blurRadiusHeavy * _fadeAnimation.value,
                sigmaY: reducedMotion
                    ? DesignSystem.blurRadiusHeavy
                    : DesignSystem.blurRadiusHeavy * _fadeAnimation.value,
              ),
              child: Center(
                child: Opacity(
                  opacity: reducedMotion ? 1.0 : _fadeAnimation.value,
                  child: Transform.scale(
                    scale: reducedMotion ? 1.0 : _scaleAnimation.value,
                    child: child,
                  ),
                ),
              ),
            ),
          );
        },
        child: _buildPauseContent(context),
      ),
    );
  }
}
