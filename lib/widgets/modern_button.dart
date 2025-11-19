import 'package:flutter/material.dart';
import '../design_system.dart';

/// Button style variants
enum ModernButtonStyle { primary, secondary, success }

/// A modern button widget with gradient backgrounds, icons, and animations
///
/// Features:
/// - Gradient backgrounds based on style
/// - Optional leading/trailing icons
/// - Hover and press animations
/// - Customizable sizing and styling
class ModernButton extends StatefulWidget {
  /// Button text label
  final String label;

  /// Callback when button is pressed
  final VoidCallback onPressed;

  /// Button style variant
  final ModernButtonStyle style;

  /// Optional leading icon
  final IconData? leadingIcon;

  /// Optional trailing icon
  final IconData? trailingIcon;

  /// Icon size (default: 24)
  final double iconSize;

  /// Button width (null for auto-sizing)
  final double? width;

  /// Button height (default: 56)
  final double height;

  /// Text style override
  final TextStyle? textStyle;

  /// Border radius override
  final BorderRadius? borderRadius;

  /// Whether button is enabled
  final bool enabled;

  const ModernButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = ModernButtonStyle.primary,
    this.leadingIcon,
    this.trailingIcon,
    this.iconSize = 24,
    this.width,
    this.height = 56,
    this.textStyle,
    this.borderRadius,
    this.enabled = true,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DesignSystem.durationFast,
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
    if (!widget.enabled) return;
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled) return;
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (!widget.enabled) return;
    _controller.reverse();
  }

  void _handleTap() {
    if (widget.enabled) {
      widget.onPressed();
    }
  }

  BoxDecoration _getDecoration() {
    List<BoxShadow> shadows;

    switch (widget.style) {
      case ModernButtonStyle.primary:
        shadows = _isHovered
            ? DesignSystem.glowStrong(DesignSystem.electricCyan)
            : DesignSystem.glowMedium(DesignSystem.electricCyan);
        return DesignSystem.primaryButtonDecoration(
          borderRadius: widget.borderRadius,
          boxShadow: shadows,
        );
      case ModernButtonStyle.secondary:
        shadows = _isHovered
            ? DesignSystem.glowMedium(DesignSystem.sunsetOrange)
            : DesignSystem.glowSubtle(DesignSystem.sunsetOrange);
        return DesignSystem.secondaryButtonDecoration(
          borderRadius: widget.borderRadius,
          boxShadow: shadows,
        );
      case ModernButtonStyle.success:
        shadows = _isHovered
            ? DesignSystem.glowStrong(DesignSystem.neonGreen)
            : DesignSystem.glowMedium(DesignSystem.neonGreen);
        return DesignSystem.successButtonDecoration(
          borderRadius: widget.borderRadius,
          boxShadow: shadows,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseTextStyle = widget.textStyle ?? DesignSystem.bodyLarge;
    final effectiveTextStyle = DesignSystem.responsiveTextStyle(
      context,
      baseTextStyle.copyWith(fontWeight: FontWeight.w600),
    );
    final effectiveIconSize = DesignSystem.responsiveIconSize(
      context,
      widget.iconSize,
    );
    final effectiveHeight = DesignSystem.ensureMinTouchTarget(
      widget.height == 56
          ? DesignSystem.responsiveButtonHeight(context)
          : widget.height,
    );

    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.label,
      child: MouseRegion(
        onEnter: (_) {
          if (widget.enabled) {
            setState(() => _isHovered = true);
          }
        },
        onExit: (_) {
          if (widget.enabled) {
            setState(() => _isHovered = false);
          }
        },
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: _handleTap,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedScale(
              scale: _isHovered && widget.enabled ? 1.05 : 1.0,
              duration: DesignSystem.accessibleDuration(
                context,
                DesignSystem.durationFast,
              ),
              curve: DesignSystem.accessibleCurve(
                context,
                DesignSystem.curveDefault,
              ),
              child: Opacity(
                opacity: widget.enabled ? 1.0 : DesignSystem.opacityDisabled,
                child: Container(
                  width: widget.width,
                  height: effectiveHeight,
                  decoration: _getDecoration(),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _handleTap,
                      borderRadius:
                          widget.borderRadius ?? DesignSystem.borderRadiusSmall,
                      splashColor: Colors.white.withValues(alpha: 0.3),
                      highlightColor: Colors.white.withValues(alpha: 0.1),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: DesignSystem.responsivePadding(
                            context,
                            DesignSystem.spacingM,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: widget.width == null
                              ? MainAxisSize.min
                              : MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.leadingIcon != null) ...[
                              Icon(
                                widget.leadingIcon,
                                size: effectiveIconSize,
                                color: DesignSystem.pureWhite,
                              ),
                              SizedBox(width: DesignSystem.spacingXS),
                            ],
                            Flexible(
                              child: Text(
                                widget.label,
                                style: effectiveTextStyle,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.trailingIcon != null) ...[
                              SizedBox(width: DesignSystem.spacingXS),
                              Icon(
                                widget.trailingIcon,
                                size: effectiveIconSize,
                                color: DesignSystem.pureWhite,
                              ),
                            ],
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
      ),
    );
  }
}
