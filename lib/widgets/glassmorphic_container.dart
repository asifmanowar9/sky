import 'dart:ui';
import 'package:flutter/material.dart';
import '../design_system.dart';
import '../platform_utils.dart';

/// A reusable glassmorphic container widget with backdrop filter effects
///
/// This widget creates a modern frosted glass effect with customizable
/// blur intensity, opacity, and styling options.
class GlassmorphicContainer extends StatelessWidget {
  /// The child widget to display inside the container
  final Widget child;

  /// Horizontal blur intensity (default: 8, optimized for performance)
  final double sigmaX;

  /// Vertical blur intensity (default: 8, optimized for performance)
  final double sigmaY;

  /// Background color opacity level (0.0 to 1.0)
  final double opacity;

  /// Border radius for the container
  final BorderRadius? borderRadius;

  /// Padding inside the container
  final EdgeInsetsGeometry? padding;

  /// Border color (defaults to white with opacity)
  final Color? borderColor;

  /// Border width (default: 1.5)
  final double borderWidth;

  /// Background color (defaults to white)
  final Color? backgroundColor;

  /// Optional box shadow
  final List<BoxShadow>? boxShadow;

  /// Optional gradient background (overrides backgroundColor if provided)
  final Gradient? gradient;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.sigmaX = 8,
    this.sigmaY = 8,
    this.opacity = 0.1,
    this.borderRadius,
    this.padding,
    this.borderColor,
    this.borderWidth = 1.5,
    this.backgroundColor,
    this.boxShadow,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    // Reduce blur intensity on mobile for better GPU performance.
    final effectiveSigmaX = PlatformUtils.adaptiveBlur(sigmaX);
    final effectiveSigmaY = PlatformUtils.adaptiveBlur(sigmaY);

    final effectiveBorderRadius =
        borderRadius ??
        BorderRadius.circular(
          DesignSystem.responsiveBorderRadius(
            context,
            DesignSystem.radiusMedium,
          ),
        );
    final effectiveBackgroundColor = backgroundColor ?? DesignSystem.pureWhite;
    final effectiveBorderColor =
        borderColor ?? DesignSystem.pureWhite.withValues(alpha: 0.2);
    final effectivePadding = padding != null
        ? DesignSystem.responsiveEdgeInsets(context, padding as EdgeInsets)
        : null;

    return ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: effectiveSigmaX,
          sigmaY: effectiveSigmaY,
        ),
        child: Container(
          padding: effectivePadding,
          decoration: BoxDecoration(
            color: gradient == null
                ? effectiveBackgroundColor.withValues(alpha: opacity)
                : null,
            gradient: gradient,
            borderRadius: effectiveBorderRadius,
            border: Border.all(color: effectiveBorderColor, width: borderWidth),
            boxShadow: boxShadow ?? DesignSystem.elevationLevel2,
          ),
          child: child,
        ),
      ),
    );
  }
}
