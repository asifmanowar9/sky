import 'package:flutter_test/flutter_test.dart';
import 'package:sky/performance_monitor.dart';
import 'package:sky/design_system.dart';

void main() {
  group('Performance Monitor Tests', () {
    late PerformanceMonitor monitor;

    setUp(() {
      monitor = PerformanceMonitor();
      monitor.reset();
    });

    tearDown(() {
      monitor.stopMonitoring();
    });

    test('Performance monitor initializes correctly', () {
      expect(monitor.averageFPS, equals(0.0));
      expect(monitor.minFPS, equals(0.0));
      expect(monitor.maxFPS, equals(0.0));
      expect(monitor.averageFrameTimeMs, equals(0.0));
    });

    test('Performance summary returns valid string when no data', () {
      final summary = monitor.getPerformanceSummary();
      expect(summary, contains('No performance data available'));
    });

    test('Performance thresholds are correct with no data', () {
      // These are just checking the logic, not actual performance
      expect(monitor.isPerformanceAcceptable, isFalse); // No data yet
      expect(monitor.isPerformanceOptimal, isFalse); // No data yet
    });
  });

  group('Design System Performance Tests', () {
    test('Blur radius values are optimized', () {
      // Verify blur values are reduced for better performance
      expect(DesignSystem.blurRadiusLight, equals(8.0));
      expect(DesignSystem.blurRadiusMedium, equals(12.0));
      expect(DesignSystem.blurRadiusHeavy, equals(15.0));

      // Verify they are less than previous values
      expect(DesignSystem.blurRadiusLight, lessThan(10.0));
      expect(DesignSystem.blurRadiusMedium, lessThan(15.0));
      expect(DesignSystem.blurRadiusHeavy, lessThan(20.0));
    });

    test('Shadow blur values are optimized', () {
      // Verify shadow blur values are reduced
      final subtleGlow = DesignSystem.glowSubtle(DesignSystem.electricCyan);
      final mediumGlow = DesignSystem.glowMedium(DesignSystem.electricCyan);
      final strongGlow = DesignSystem.glowStrong(DesignSystem.electricCyan);

      expect(subtleGlow.first.blurRadius, equals(15.0));
      expect(mediumGlow.first.blurRadius, equals(25.0));
      expect(strongGlow.first.blurRadius, equals(35.0));

      // Verify they are less than previous values
      expect(subtleGlow.first.blurRadius, lessThan(20.0));
      expect(mediumGlow.first.blurRadius, lessThan(40.0));
      expect(strongGlow.first.blurRadius, lessThan(60.0));
    });

    test('Elevation shadows are defined', () {
      expect(DesignSystem.elevationLevel1.length, equals(1));
      expect(DesignSystem.elevationLevel2.length, equals(1));
      expect(DesignSystem.elevationLevel3.length, equals(1));
    });

    test('Animation durations are defined', () {
      expect(DesignSystem.durationInstant.inMilliseconds, equals(100));
      expect(DesignSystem.durationFast.inMilliseconds, equals(200));
      expect(DesignSystem.durationNormal.inMilliseconds, equals(300));
      expect(DesignSystem.durationSlow.inMilliseconds, equals(400));
      expect(DesignSystem.durationVerySlow.inMilliseconds, equals(500));
    });
  });
}
