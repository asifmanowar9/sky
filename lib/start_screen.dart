import 'dart:ui';
import 'package:flutter/material.dart';
import 'sky_defender_game.dart';
import 'design_system.dart';
import 'widgets/glassmorphic_container.dart';

class StartScreen extends StatefulWidget {
  final SkyDefenderGame game;

  const StartScreen({super.key, required this.game});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: DesignSystem.durationNormal,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = DesignSystem.responsivePadding(
      context,
      DesignSystem.spacingL,
    );
    final verticalPadding = DesignSystem.responsivePadding(
      context,
      DesignSystem.spacingXL,
    );

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DesignSystem.deepSpaceBlue,
              DesignSystem.cosmicPurple,
              DesignSystem.deepSpaceBlue,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Game Title with Glassmorphism
                  _buildTitle(context),
                  SizedBox(
                    height: DesignSystem.responsiveSpacing(
                      context,
                      DesignSystem.spacingL,
                    ),
                  ),

                  // Subtitle
                  Text(
                    'Defend the Sky from Meteors!',
                    style: TextStyle(
                      color: DesignSystem.lightGray,
                      fontSize: DesignSystem.responsiveFontSize(context, 20),
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: DesignSystem.responsiveSpacing(
                      context,
                      DesignSystem.spacingXL,
                    ),
                  ),

                  // Game Instructions
                  _buildInstructionCard(context),
                  SizedBox(
                    height: DesignSystem.responsiveSpacing(
                      context,
                      DesignSystem.spacingXL,
                    ),
                  ),

                  // High Score Display
                  _buildHighScoreDisplay(context),
                  SizedBox(
                    height: DesignSystem.responsiveSpacing(
                      context,
                      DesignSystem.spacingL,
                    ),
                  ),

                  // Start Button
                  _buildStartButton(context),
                  SizedBox(
                    height: DesignSystem.responsiveSpacing(
                      context,
                      DesignSystem.spacingL,
                    ),
                  ),

                  // Version or Credits
                  Text(
                    'v1.0 • Flutter Game',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: DesignSystem.responsiveFontSize(context, 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final isSmallScreen = DesignSystem.isSmallScreen(context);
    final titleFontSize = DesignSystem.responsiveFontSize(context, 63);
    final titlePadding = DesignSystem.responsivePadding(
      context,
      DesignSystem.spacingL,
    );
    final borderRadius = DesignSystem.responsiveBorderRadius(
      context,
      DesignSystem.radiusLarge,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: titlePadding,
        vertical: DesignSystem.responsivePadding(
          context,
          DesignSystem.spacingM,
        ),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [DesignSystem.cosmicPurple, DesignSystem.electricCyan],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: DesignSystem.electricCyan.withValues(alpha: 0.5),
            blurRadius: isSmallScreen ? 30 : 40,
            spreadRadius: isSmallScreen ? 3 : 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: DesignSystem.blurRadiusLight,
            sigmaY: DesignSystem.blurRadiusLight,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            padding: EdgeInsets.all(titlePadding),
            child: Text(
              'SKY DEFENDER',
              style: TextStyle(
                color: Colors.white,
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: isSmallScreen ? 2 : 4,
                shadows: [
                  Shadow(
                    blurRadius: 20,
                    color: DesignSystem.electricCyan.withValues(alpha: 0.8),
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionCard(BuildContext context) {
    final maxWidth = DesignSystem.responsiveMaxWidth(context);
    final cardPadding = DesignSystem.responsivePadding(
      context,
      DesignSystem.spacingM,
    );
    final borderRadius = DesignSystem.responsiveBorderRadius(
      context,
      DesignSystem.radiusMedium,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: GlassmorphicContainer(
        sigmaX: DesignSystem.blurRadiusMedium,
        sigmaY: DesignSystem.blurRadiusMedium,
        opacity: 0.15,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: Column(
            children: [
              Text(
                'HOW TO PLAY',
                style: TextStyle(
                  color: DesignSystem.electricCyan,
                  fontSize: DesignSystem.responsiveFontSize(context, 24),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(
                height: DesignSystem.responsiveSpacing(
                  context,
                  DesignSystem.spacingS,
                ),
              ),
              _buildInstructionRow(
                context,
                Icons.touch_app,
                'Drag to move your ship',
                DesignSystem.electricCyan,
              ),
              SizedBox(height: DesignSystem.spacingXS),
              _buildInstructionRow(
                context,
                Icons.radio_button_checked,
                'Automatic shooting',
                DesignSystem.neonGreen,
              ),
              SizedBox(height: DesignSystem.spacingXS),
              _buildInstructionRow(
                context,
                Icons.star,
                'Destroy meteors for points',
                DesignSystem.sunsetOrange,
              ),
              SizedBox(height: DesignSystem.spacingXS),
              _buildInstructionRow(
                context,
                Icons.favorite,
                'Collect power-ups for bonuses',
                DesignSystem.crimsonRed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionRow(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
  ) {
    final iconSize = DesignSystem.responsiveIconSize(context, 24);
    final fontSize = DesignSystem.responsiveFontSize(context, 16);

    return Row(
      children: [
        Icon(icon, color: color, size: iconSize),
        SizedBox(width: DesignSystem.spacingS),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: fontSize),
          ),
        ),
      ],
    );
  }

  Widget _buildHighScoreDisplay(BuildContext context) {
    final isSmallScreen = DesignSystem.isSmallScreen(context);
    final iconSize = DesignSystem.responsiveIconSize(context, 28);
    final fontSize = DesignSystem.responsiveFontSize(context, 20);
    final borderRadius = DesignSystem.responsiveBorderRadius(
      context,
      DesignSystem.radiusLarge,
    );

    return StreamBuilder<int>(
      stream: widget.game.highScoreStream,
      initialData: widget.game.highScore,
      builder: (context, snapshot) {
        final highScore = snapshot.data ?? 0;
        return Semantics(
          label: DesignSystem.highScoreSemanticLabel(highScore),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: DesignSystem.responsivePadding(
                context,
                DesignSystem.spacingM,
              ),
              vertical: DesignSystem.responsivePadding(
                context,
                DesignSystem.spacingS,
              ),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DesignSystem.goldenYellow.withValues(alpha: 0.3),
                  DesignSystem.sunsetOrange.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: DesignSystem.goldenYellow, width: 2),
              boxShadow: [
                BoxShadow(
                  color: DesignSystem.goldenYellow.withValues(alpha: 0.4),
                  blurRadius: isSmallScreen ? 15 : 20,
                  spreadRadius: isSmallScreen ? 1 : 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emoji_events,
                  color: DesignSystem.goldenYellow,
                  size: iconSize,
                ),
                SizedBox(width: DesignSystem.spacingXS),
                Text(
                  'High Score: $highScore',
                  style: TextStyle(
                    color: DesignSystem.goldenYellow,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return _AnimatedStartButton(onPressed: () => widget.game.startGame());
  }
}

/// Animated start button with hover, press, and ripple effects
class _AnimatedStartButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _AnimatedStartButton({required this.onPressed});

  @override
  State<_AnimatedStartButton> createState() => _AnimatedStartButtonState();
}

class _AnimatedStartButtonState extends State<_AnimatedStartButton>
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
    final isSmallScreen = DesignSystem.isSmallScreen(context);
    final iconSize = DesignSystem.responsiveIconSize(context, 32);
    final fontSize = DesignSystem.responsiveFontSize(context, 24);
    final borderRadius = DesignSystem.responsiveBorderRadius(
      context,
      DesignSystem.radiusLarge,
    );

    return Semantics(
      button: true,
      label: 'Start game',
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
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: DesignSystem.responsivePadding(
                    context,
                    DesignSystem.spacingXL,
                  ),
                  vertical: DesignSystem.responsivePadding(
                    context,
                    DesignSystem.spacingM,
                  ),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [DesignSystem.neonGreen, DesignSystem.electricCyan],
                  ),
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: DesignSystem.neonGreen.withValues(alpha: 0.5),
                      blurRadius: _isHovered
                          ? (isSmallScreen ? 25 : 30)
                          : (isSmallScreen ? 15 : 20),
                      spreadRadius: _isHovered
                          ? (isSmallScreen ? 3 : 5)
                          : (isSmallScreen ? 1 : 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onPressed,
                    borderRadius: BorderRadius.circular(borderRadius),
                    splashColor: Colors.white.withValues(alpha: 0.3),
                    highlightColor: Colors.white.withValues(alpha: 0.1),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: DesignSystem.spacingS,
                        vertical: DesignSystem.spacingXS,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: iconSize,
                          ),
                          SizedBox(width: DesignSystem.spacingXS),
                          Text(
                            'START GAME',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              letterSpacing: isSmallScreen ? 1 : 2,
                            ),
                          ),
                        ],
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
