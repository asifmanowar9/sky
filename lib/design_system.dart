import 'dart:ui';
import 'package:flutter/material.dart';

/// Design System for Sky Defender
/// Contains all color palette, typography, spacing, and styling constants
class DesignSystem {
  // Prevent instantiation
  DesignSystem._();

  // ============================================================================
  // COLOR PALETTE
  // ============================================================================

  /// Primary Colors
  static const Color deepSpaceBlue = Color(0xFF0A1628);
  static const Color cosmicPurple = Color(0xFF6B46C1);
  static const Color electricCyan = Color(0xFF00D9FF);
  static const Color neonGreen = Color(0xFF00FF88);

  /// Secondary Colors
  static const Color sunsetOrange = Color(0xFFFF6B35);
  static const Color goldenYellow = Color(0xFFFFD700);
  static const Color crimsonRed = Color(0xFFFF3366);

  /// Neutral Colors
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFE5E7EB);
  static const Color darkGray = Color(0xFF1F2937);
  static const Color blackOverlay = Color(0xFF000000);

  // ============================================================================
  // GRADIENTS
  // ============================================================================

  /// Background gradient for start screen
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepSpaceBlue, cosmicPurple],
  );

  /// Title gradient
  static const LinearGradient titleGradient = LinearGradient(
    colors: [cosmicPurple, electricCyan],
  );

  /// Success/positive gradient
  static const LinearGradient successGradient = LinearGradient(
    colors: [neonGreen, electricCyan],
  );

  /// High score celebration gradient
  static const LinearGradient highScoreGradient = LinearGradient(
    colors: [goldenYellow, sunsetOrange],
  );

  /// Primary button gradient
  static const LinearGradient primaryButtonGradient = LinearGradient(
    colors: [electricCyan, cosmicPurple],
  );

  /// Secondary button gradient
  static const LinearGradient secondaryButtonGradient = LinearGradient(
    colors: [sunsetOrange, crimsonRed],
  );

  /// Dark glassmorphic gradient
  static LinearGradient darkGlassmorphicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      darkGray.withValues(alpha: 0.95),
      deepSpaceBlue.withValues(alpha: 0.95),
    ],
  );

  // ============================================================================
  // TYPOGRAPHY
  // ============================================================================

  /// Display text style (64px, Bold) - Main titles
  static const TextStyle displayText = TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.bold,
    letterSpacing: 4,
    color: pureWhite,
    height: 1.2,
  );

  /// Heading 1 (48px, Bold) - Screen titles
  static const TextStyle heading1 = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
    color: pureWhite,
    height: 1.2,
  );

  /// Heading 2 (32px, Bold) - Section headers
  static const TextStyle heading2 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
    color: pureWhite,
    height: 1.3,
  );

  /// Heading 3 (24px, SemiBold) - Subsections
  static const TextStyle heading3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: pureWhite,
    height: 1.3,
  );

  /// Body Large (20px, Medium) - Important info
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: pureWhite,
    height: 1.5,
  );

  /// Body (16px, Regular) - Standard text
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: pureWhite,
    height: 1.5,
  );

  /// Caption (14px, Regular) - Secondary info
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: lightGray,
    height: 1.4,
  );

  /// Label (12px, Medium, Uppercase) - Labels
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: lightGray,
    letterSpacing: 1.5,
    height: 1.3,
  );

  // ============================================================================
  // SPACING (8-point grid system)
  // ============================================================================

  static const double spacingXXS = 4.0;
  static const double spacingXS = 8.0;
  static const double spacingS = 16.0;
  static const double spacingM = 24.0;
  static const double spacingL = 32.0;
  static const double spacingXL = 48.0;
  static const double spacingXXL = 64.0;

  // ============================================================================
  // BORDER RADIUS
  // ============================================================================

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusXLarge = 32.0;

  static const BorderRadius borderRadiusSmall = BorderRadius.all(
    Radius.circular(radiusSmall),
  );
  static const BorderRadius borderRadiusMedium = BorderRadius.all(
    Radius.circular(radiusMedium),
  );
  static const BorderRadius borderRadiusLarge = BorderRadius.all(
    Radius.circular(radiusLarge),
  );
  static const BorderRadius borderRadiusXLarge = BorderRadius.all(
    Radius.circular(radiusXLarge),
  );

  // ============================================================================
  // SHADOWS AND GLOWS
  // ============================================================================

  /// Elevation shadows
  static List<BoxShadow> get elevationLevel1 => [
    BoxShadow(
      color: blackOverlay.withValues(alpha: 0.1),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevationLevel2 => [
    BoxShadow(
      color: blackOverlay.withValues(alpha: 0.15),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevationLevel3 => [
    BoxShadow(
      color: blackOverlay.withValues(alpha: 0.2),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  /// Glow effects (optimized for performance)
  static List<BoxShadow> glowSubtle(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.3),
      blurRadius: 15,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> glowMedium(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.5),
      blurRadius: 25,
      spreadRadius: 3,
    ),
  ];

  static List<BoxShadow> glowStrong(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.7),
      blurRadius: 35,
      spreadRadius: 5,
    ),
  ];

  // ============================================================================
  // ANIMATION CONSTANTS
  // ============================================================================

  /// Animation durations
  static const Duration durationInstant = Duration(milliseconds: 100);
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 400);
  static const Duration durationVerySlow = Duration(milliseconds: 500);

  /// Animation curves
  static const Curve curveDefault = Curves.easeInOut;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveBackOut = Curves.easeOutBack;
  static const Curve curveBounce = Curves.bounceOut;

  // ============================================================================
  // GLASSMORPHISM HELPERS
  // ============================================================================

  /// Creates a light glassmorphic decoration
  static BoxDecoration glassmorphicLight({
    BorderRadius? borderRadius,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: (backgroundColor ?? pureWhite).withValues(alpha: 0.1),
      borderRadius: borderRadius ?? borderRadiusMedium,
      border: Border.all(
        color: (borderColor ?? pureWhite).withValues(alpha: 0.2),
        width: 1.5,
      ),
      boxShadow: elevationLevel2,
    );
  }

  /// Creates a medium glassmorphic decoration
  static BoxDecoration glassmorphicMedium({
    BorderRadius? borderRadius,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: (backgroundColor ?? pureWhite).withValues(alpha: 0.15),
      borderRadius: borderRadius ?? borderRadiusMedium,
      border: Border.all(
        color: (borderColor ?? pureWhite).withValues(alpha: 0.25),
        width: 1.5,
      ),
      boxShadow: elevationLevel2,
    );
  }

  /// Creates a heavy glassmorphic decoration
  static BoxDecoration glassmorphicHeavy({
    BorderRadius? borderRadius,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: (backgroundColor ?? pureWhite).withValues(alpha: 0.2),
      borderRadius: borderRadius ?? borderRadiusMedium,
      border: Border.all(
        color: (borderColor ?? pureWhite).withValues(alpha: 0.3),
        width: 2,
      ),
      boxShadow: elevationLevel3,
    );
  }

  /// Creates a dark glassmorphic decoration with gradient (optimized)
  static BoxDecoration glassmorphicDark({
    BorderRadius? borderRadius,
    Gradient? gradient,
    Color? borderColor,
  }) {
    return BoxDecoration(
      gradient: gradient ?? darkGlassmorphicGradient,
      borderRadius: borderRadius ?? borderRadiusLarge,
      border: Border.all(
        color: (borderColor ?? pureWhite).withValues(alpha: 0.2),
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: blackOverlay.withValues(alpha: 0.5),
          blurRadius: 25,
          spreadRadius: 5,
        ),
      ],
    );
  }

  /// Optimized blur radius values for better performance
  static const double blurRadiusLight = 8.0; // Reduced from 10
  static const double blurRadiusMedium = 12.0; // Reduced from 15
  static const double blurRadiusHeavy = 15.0; // Reduced from 20

  /// Creates a glassmorphic container widget with backdrop filter
  /// Uses optimized blur values for better performance
  static Widget glassmorphicContainer({
    required Widget child,
    double sigmaX = 8,
    double sigmaY = 8,
    BoxDecoration? decoration,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? borderRadiusMedium,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: Container(
          decoration:
              decoration ?? glassmorphicLight(borderRadius: borderRadius),
          padding: padding,
          child: child,
        ),
      ),
    );
  }

  // ============================================================================
  // BUTTON STYLES
  // ============================================================================

  /// Primary button decoration
  static BoxDecoration primaryButtonDecoration({
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      gradient: primaryButtonGradient,
      borderRadius: borderRadius ?? borderRadiusSmall,
      boxShadow: boxShadow ?? glowMedium(electricCyan),
    );
  }

  /// Secondary button decoration
  static BoxDecoration secondaryButtonDecoration({
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      gradient: secondaryButtonGradient,
      borderRadius: borderRadius ?? borderRadiusSmall,
      boxShadow: boxShadow ?? glowSubtle(sunsetOrange),
    );
  }

  /// Success button decoration
  static BoxDecoration successButtonDecoration({
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      gradient: successGradient,
      borderRadius: borderRadius ?? borderRadiusSmall,
      boxShadow: boxShadow ?? glowMedium(neonGreen),
    );
  }

  // ============================================================================
  // RESPONSIVE HELPERS
  // ============================================================================

  /// Breakpoint values
  static const double breakpointSmall = 600;
  static const double breakpointMedium = 900;

  /// Check if screen is small (< 600px)
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < breakpointSmall;
  }

  /// Check if screen is medium (600-900px)
  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= breakpointSmall && width < breakpointMedium;
  }

  /// Check if screen is large (>= 900px)
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= breakpointMedium;
  }

  /// Get responsive font size (reduces by 20% on small screens)
  static double responsiveFontSize(BuildContext context, double baseSize) {
    if (isSmallScreen(context)) {
      return baseSize * 0.8;
    }
    return baseSize;
  }

  /// Get responsive padding (reduces by 25% on small screens)
  static double responsivePadding(BuildContext context, double basePadding) {
    if (isSmallScreen(context)) {
      return basePadding * 0.75;
    }
    return basePadding;
  }

  /// Get responsive spacing value
  static double responsiveSpacing(BuildContext context, double baseSpacing) {
    if (isSmallScreen(context)) {
      return baseSpacing * 0.75;
    }
    return baseSpacing;
  }

  /// Get responsive icon size
  static double responsiveIconSize(BuildContext context, double baseSize) {
    if (isSmallScreen(context)) {
      return baseSize * 0.85;
    }
    return baseSize;
  }

  /// Get responsive border radius
  static double responsiveBorderRadius(
    BuildContext context,
    double baseRadius,
  ) {
    if (isSmallScreen(context)) {
      return baseRadius * 0.8;
    }
    return baseRadius;
  }

  /// Get responsive text style with adjusted font size
  static TextStyle responsiveTextStyle(
    BuildContext context,
    TextStyle baseStyle,
  ) {
    if (isSmallScreen(context) && baseStyle.fontSize != null) {
      return baseStyle.copyWith(fontSize: baseStyle.fontSize! * 0.8);
    }
    return baseStyle;
  }

  /// Get responsive EdgeInsets
  static EdgeInsets responsiveEdgeInsets(
    BuildContext context,
    EdgeInsets baseInsets,
  ) {
    if (isSmallScreen(context)) {
      return EdgeInsets.only(
        left: baseInsets.left * 0.75,
        top: baseInsets.top * 0.75,
        right: baseInsets.right * 0.75,
        bottom: baseInsets.bottom * 0.75,
      );
    }
    return baseInsets;
  }

  /// Get responsive button height
  static double responsiveButtonHeight(BuildContext context) {
    return isSmallScreen(context) ? minTouchTarget : 56.0;
  }

  /// Get responsive container max width
  static double responsiveMaxWidth(BuildContext context) {
    if (isSmallScreen(context)) {
      return MediaQuery.of(context).size.width * 0.9;
    } else if (isMediumScreen(context)) {
      return 600;
    } else {
      return 800;
    }
  }

  // ============================================================================
  // TOUCH TARGET SIZES
  // ============================================================================

  static const double minTouchTarget = 44.0;
  static const double minTouchTargetSpacing = 8.0;

  // ============================================================================
  // OPACITY VALUES
  // ============================================================================

  static const double opacityDisabled = 0.5;
  static const double opacityHover = 0.9;
  static const double opacityPressed = 0.8;
  static const double opacityOverlay = 0.8;

  // ============================================================================
  // ACCESSIBILITY HELPERS
  // ============================================================================

  /// Check if reduced motion is preferred by the user
  static bool prefersReducedMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Get animation duration respecting reduced motion preference
  static Duration accessibleDuration(
    BuildContext context,
    Duration normalDuration,
  ) {
    return prefersReducedMotion(context) ? Duration.zero : normalDuration;
  }

  /// Get animation curve respecting reduced motion preference
  static Curve accessibleCurve(BuildContext context, Curve normalCurve) {
    return prefersReducedMotion(context) ? Curves.linear : normalCurve;
  }

  /// Ensure minimum touch target size for accessibility
  static double ensureMinTouchTarget(double size) {
    return size < minTouchTarget ? minTouchTarget : size;
  }

  /// Create semantic label for score display
  static String scoreSemanticLabel(int score) {
    return 'Score: $score points';
  }

  /// Create semantic label for lives display
  static String livesSemanticLabel(int lives) {
    return 'Lives remaining: $lives';
  }

  /// Create semantic label for wave display
  static String waveSemanticLabel(int wave) {
    return 'Wave $wave';
  }

  /// Create semantic label for high score display
  static String highScoreSemanticLabel(int highScore) {
    return 'High score: $highScore points';
  }

  /// Create semantic label for power-up indicator
  static String powerUpSemanticLabel(String powerUpName, bool isActive) {
    return isActive
        ? '$powerUpName power-up active'
        : '$powerUpName power-up inactive';
  }
}
