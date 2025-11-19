import 'package:flutter/scheduler.dart';

/// Performance monitoring utility for tracking FPS and frame times
///
/// This class helps monitor the performance of the game and UI,
/// ensuring smooth 60 FPS gameplay with the new modern UI overlays.
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final List<Duration> _frameTimes = [];
  final int _maxSamples = 60; // Track last 60 frames
  DateTime? _lastFrameTime;
  bool _isMonitoring = false;

  /// Start monitoring frame performance
  void startMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;
    _frameTimes.clear();
    _lastFrameTime = DateTime.now();

    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
  }

  /// Stop monitoring frame performance
  void stopMonitoring() {
    _isMonitoring = false;
    _frameTimes.clear();
    _lastFrameTime = null;
  }

  void _onFrame(Duration timestamp) {
    if (!_isMonitoring) return;

    final now = DateTime.now();
    if (_lastFrameTime != null) {
      final frameDuration = now.difference(_lastFrameTime!);
      _frameTimes.add(frameDuration);

      // Keep only the last N samples
      if (_frameTimes.length > _maxSamples) {
        _frameTimes.removeAt(0);
      }
    }
    _lastFrameTime = now;

    // Schedule next frame callback
    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
  }

  /// Get current average FPS
  double get averageFPS {
    if (_frameTimes.isEmpty) return 0.0;

    final totalMicroseconds = _frameTimes.fold<int>(
      0,
      (sum, duration) => sum + duration.inMicroseconds,
    );
    final averageMicroseconds = totalMicroseconds / _frameTimes.length;

    // FPS = 1,000,000 microseconds / average frame time
    return 1000000.0 / averageMicroseconds;
  }

  /// Get minimum FPS from recent samples
  double get minFPS {
    if (_frameTimes.isEmpty) return 0.0;

    final maxFrameTime = _frameTimes.reduce(
      (a, b) => a.inMicroseconds > b.inMicroseconds ? a : b,
    );

    return 1000000.0 / maxFrameTime.inMicroseconds;
  }

  /// Get maximum FPS from recent samples
  double get maxFPS {
    if (_frameTimes.isEmpty) return 0.0;

    final minFrameTime = _frameTimes.reduce(
      (a, b) => a.inMicroseconds < b.inMicroseconds ? a : b,
    );

    return 1000000.0 / minFrameTime.inMicroseconds;
  }

  /// Get average frame time in milliseconds
  double get averageFrameTimeMs {
    if (_frameTimes.isEmpty) return 0.0;

    final totalMicroseconds = _frameTimes.fold<int>(
      0,
      (sum, duration) => sum + duration.inMicroseconds,
    );

    return (totalMicroseconds / _frameTimes.length) / 1000.0;
  }

  /// Check if performance is acceptable (>= 55 FPS average)
  bool get isPerformanceAcceptable => averageFPS >= 55.0;

  /// Check if performance is optimal (>= 58 FPS average)
  bool get isPerformanceOptimal => averageFPS >= 58.0;

  /// Get performance summary as a string
  String getPerformanceSummary() {
    if (_frameTimes.isEmpty) {
      return 'No performance data available';
    }

    return '''
Performance Summary:
- Average FPS: ${averageFPS.toStringAsFixed(1)}
- Min FPS: ${minFPS.toStringAsFixed(1)}
- Max FPS: ${maxFPS.toStringAsFixed(1)}
- Avg Frame Time: ${averageFrameTimeMs.toStringAsFixed(2)}ms
- Status: ${isPerformanceOptimal
        ? 'Optimal'
        : isPerformanceAcceptable
        ? 'Acceptable'
        : 'Needs Optimization'}
''';
  }

  /// Reset all performance data
  void reset() {
    _frameTimes.clear();
    _lastFrameTime = null;
  }
}
