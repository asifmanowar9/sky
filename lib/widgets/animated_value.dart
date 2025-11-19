import 'package:flutter/material.dart';
import '../design_system.dart';

/// A widget that animates number changes with scale effects
///
/// Features:
/// - Smooth number transitions
/// - Scale pulse animation on value change
/// - Optional color flash effect
/// - Customizable text styling
class AnimatedValue extends StatefulWidget {
  /// The current value to display
  final int value;

  /// Text style for the value
  final TextStyle? textStyle;

  /// Duration of the scale animation
  final Duration duration;

  /// Scale factor for the pulse effect (default: 1.2)
  final double scaleFactor;

  /// Whether to animate color flash on change
  final bool useColorFlash;

  /// Flash color (defaults to electric cyan)
  final Color? flashColor;

  /// Prefix text (e.g., "$", "x")
  final String? prefix;

  /// Suffix text (e.g., "pts", "%")
  final String? suffix;

  const AnimatedValue({
    super.key,
    required this.value,
    this.textStyle,
    this.duration = const Duration(milliseconds: 300),
    this.scaleFactor = 1.2,
    this.useColorFlash = false,
    this.flashColor,
    this.prefix,
    this.suffix,
  });

  @override
  State<AnimatedValue> createState() => _AnimatedValueState();
}

class _AnimatedValueState extends State<AnimatedValue>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: widget.scaleFactor,
        ).chain(CurveTween(curve: DesignSystem.curveEaseOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: widget.scaleFactor,
          end: 1.0,
        ).chain(CurveTween(curve: DesignSystem.curveEaseIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    final baseColor = widget.textStyle?.color ?? DesignSystem.pureWhite;
    final flashColor = widget.flashColor ?? DesignSystem.electricCyan;

    _colorAnimation = ColorTween(
      begin: baseColor,
      end: flashColor,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(AnimatedValue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTextStyle = widget.textStyle ?? DesignSystem.bodyLarge;
    final reducedMotion = DesignSystem.prefersReducedMotion(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final displayColor = widget.useColorFlash && !reducedMotion
            ? _colorAnimation.value
            : effectiveTextStyle.color;

        return Transform.scale(
          scale: reducedMotion ? 1.0 : _scaleAnimation.value,
          child: Text(
            '${widget.prefix ?? ''}${widget.value}${widget.suffix ?? ''}',
            style: effectiveTextStyle.copyWith(color: displayColor),
          ),
        );
      },
    );
  }
}

/// A widget that animates between two integer values with smooth transitions
///
/// This variant uses AnimatedSwitcher for a different animation style
class AnimatedValueSwitcher extends StatelessWidget {
  /// The current value to display
  final int value;

  /// Text style for the value
  final TextStyle? textStyle;

  /// Duration of the transition
  final Duration duration;

  /// Prefix text (e.g., "$", "x")
  final String? prefix;

  /// Suffix text (e.g., "pts", "%")
  final String? suffix;

  const AnimatedValueSwitcher({
    super.key,
    required this.value,
    this.textStyle,
    this.duration = const Duration(milliseconds: 300),
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextStyle = textStyle ?? DesignSystem.bodyLarge;
    final reducedMotion = DesignSystem.prefersReducedMotion(context);

    return AnimatedSwitcher(
      duration: reducedMotion ? Duration.zero : duration,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Text(
        '${prefix ?? ''}$value${suffix ?? ''}',
        key: ValueKey<int>(value),
        style: effectiveTextStyle,
      ),
    );
  }
}
