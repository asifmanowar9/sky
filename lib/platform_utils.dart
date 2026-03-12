import 'package:flutter/foundation.dart';

/// Platform detection and adaptive performance utilities.
///
/// Uses [defaultTargetPlatform] (available on all Flutter targets including
/// web) instead of `dart:io`, so this file compiles safely on web.
class PlatformUtils {
  PlatformUtils._();

  // ── Platform flags ─────────────────────────────────────────────────────────

  /// `true` when running in a browser.
  static bool get isWeb => kIsWeb;

  /// `true` when running on an Android or iOS device.
  static bool get isMobile =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  /// `true` when running on macOS, Windows, or Linux.
  static bool get isDesktop =>
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;

  // ── Adaptive rendering ─────────────────────────────────────────────────────

  /// Returns an adjusted particle count for the current platform.
  ///
  /// Mobile receives ~60 % of [baseCount] to reduce GPU / CPU load on
  /// lower-end hardware. The value is clamped to a sensible minimum of 4.
  static int adaptiveParticleCount(int baseCount) {
    if (isMobile) return (baseCount * 0.6).round().clamp(4, baseCount);
    return baseCount;
  }

  /// Returns an adjusted blur sigma for backdrop-filter effects.
  ///
  /// Mobile receives a 50 % reduction so that [BackdropFilter] stays
  /// performant on devices with limited GPU bandwidth.
  static double adaptiveBlur(double baseSigma) {
    if (isMobile) return baseSigma * 0.5;
    return baseSigma;
  }

  // ── Adaptive game-feel ─────────────────────────────────────────────────────

  /// Returns an adjusted screen-shake intensity for the current platform.
  ///
  /// Mobile receives 65 % of [baseIntensity] to avoid jarring on small
  /// screens while still providing haptic-like visual feedback.
  static double adaptiveShakeIntensity(double baseIntensity) {
    if (isMobile) return baseIntensity * 0.65;
    return baseIntensity;
  }

  /// Maximum number of [MoveEffect] steps used for screen-shake animations.
  ///
  /// Fewer steps means fewer Dart object allocations per shake, which
  /// reduces GC pressure – especially important on mobile.
  static int get maxShakeSteps => isMobile ? 6 : 10;
}
