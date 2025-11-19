import 'package:flutter/material.dart';
import '../design_system.dart';

/// A card widget for displaying game statistics with icons
///
/// Features:
/// - Icon + label + value layout
/// - Customizable colors and styling
/// - Optional glassmorphic background
/// - Responsive sizing
class StatCard extends StatelessWidget {
  /// Icon to display
  final IconData icon;

  /// Label text (e.g., "Score", "Lives")
  final String label;

  /// Value to display (e.g., "1000", "3")
  final String value;

  /// Icon color (defaults to electric cyan)
  final Color? iconColor;

  /// Value text color (defaults to white)
  final Color? valueColor;

  /// Label text color (defaults to light gray)
  final Color? labelColor;

  /// Icon size (default: 24)
  final double iconSize;

  /// Whether to use glassmorphic background
  final bool useGlassmorphic;

  /// Background color (used if not glassmorphic)
  final Color? backgroundColor;

  /// Padding inside the card
  final EdgeInsetsGeometry? padding;

  /// Border radius
  final BorderRadius? borderRadius;

  /// Layout orientation
  final Axis orientation;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.valueColor,
    this.labelColor,
    this.iconSize = 24,
    this.useGlassmorphic = true,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
    this.orientation = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? DesignSystem.electricCyan;
    final effectiveValueColor = valueColor ?? DesignSystem.pureWhite;
    final effectiveLabelColor = labelColor ?? DesignSystem.lightGray;
    final effectivePadding =
        padding ??
        EdgeInsets.all(
          DesignSystem.responsivePadding(context, DesignSystem.spacingS),
        );
    final effectiveBorderRadius =
        borderRadius ?? DesignSystem.borderRadiusSmall;

    Widget content = orientation == Axis.horizontal
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: iconSize, color: effectiveIconColor),
              SizedBox(width: DesignSystem.spacingXS),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: DesignSystem.caption.copyWith(
                      color: effectiveLabelColor,
                      fontSize: DesignSystem.responsiveFontSize(
                        context,
                        DesignSystem.caption.fontSize!,
                      ),
                    ),
                  ),
                  Text(
                    value,
                    style: DesignSystem.bodyLarge.copyWith(
                      color: effectiveValueColor,
                      fontWeight: FontWeight.bold,
                      fontSize: DesignSystem.responsiveFontSize(
                        context,
                        DesignSystem.bodyLarge.fontSize!,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: iconSize, color: effectiveIconColor),
              SizedBox(height: DesignSystem.spacingXXS),
              Text(
                label,
                style: DesignSystem.caption.copyWith(
                  color: effectiveLabelColor,
                  fontSize: DesignSystem.responsiveFontSize(
                    context,
                    DesignSystem.caption.fontSize!,
                  ),
                ),
              ),
              Text(
                value,
                style: DesignSystem.bodyLarge.copyWith(
                  color: effectiveValueColor,
                  fontWeight: FontWeight.bold,
                  fontSize: DesignSystem.responsiveFontSize(
                    context,
                    DesignSystem.bodyLarge.fontSize!,
                  ),
                ),
              ),
            ],
          );

    if (useGlassmorphic) {
      return Container(
        decoration: DesignSystem.glassmorphicLight(
          borderRadius: effectiveBorderRadius,
        ),
        padding: effectivePadding,
        child: content,
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color:
              backgroundColor ?? DesignSystem.darkGray.withValues(alpha: 0.8),
          borderRadius: effectiveBorderRadius,
          boxShadow: DesignSystem.elevationLevel1,
        ),
        padding: effectivePadding,
        child: content,
      );
    }
  }
}
