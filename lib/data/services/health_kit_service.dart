import 'package:flutter/services.dart';

class HealthWorkout {
  final String workoutId;
  final String workoutType;
  final double distance;
  final double duration;
  final DateTime startDate;
  final DateTime endDate;
  final String? source;
  final String? sourceBundleId;

  HealthWorkout({
    required this.workoutId,
    required this.workoutType,
    required this.distance,
    required this.duration,
    required this.startDate,
    required this.endDate,
    this.source,
    this.sourceBundleId,
  });

  factory HealthWorkout.fromMap(Map<dynamic, dynamic> map) {
    return HealthWorkout(
      workoutId: map['workoutId'] as String? ?? '',
      workoutType: map['workoutType'] as String? ?? 'running',
      distance: (map['distance'] as num?)?.toDouble() ?? 0.0,
      duration: (map['duration'] as num?)?.toDouble() ?? 0.0,
      startDate: DateTime.tryParse(map['startDate'] as String? ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(map['endDate'] as String? ?? '') ?? DateTime.now(),
      source: map['source'] as String?,
      sourceBundleId: map['sourceBundleId'] as String?,
    );
  }
}

class HealthKitService {
  static const String channelName = 'com.shoegarage/health_kit';
  final MethodChannel _channel;

  HealthKitService({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(channelName);

  /// Check if Apple Health is available on this device.
  Future<bool> isHealthDataAvailable() async {
    try {
      final available = await _channel.invokeMethod<bool>('isHealthDataAvailable');
      return available ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Request Apple Health read authorization for workouts and distances.
  /// When granted, also triggers setup of the native Swift HKObserverQuery.
  Future<bool> requestAuthorization() async {
    try {
      final granted = await _channel.invokeMethod<bool>('requestAuthorization');
      return granted ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Explicitly trigger the background HKObserverQuery setup.
  Future<bool> startObserver() async {
    try {
      final started = await _channel.invokeMethod<bool>('startObserver');
      return started ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Fetch workouts recorded in the past [days] days from Apple Health.
  Future<List<HealthWorkout>> fetchRecentWorkouts({int days = 30}) async {
    try {
      final List<dynamic>? raw = await _channel.invokeMethod<List<dynamic>>(
        'fetchRecentWorkouts',
        {'days': days},
      );
      if (raw == null) return [];
      return raw.map((item) => HealthWorkout.fromMap(item as Map<dynamic, dynamic>)).toList();
    } on PlatformException catch (_) {
      return [];
    }
  }

  /// Fetch workouts using HKAnchoredObjectQuery for incremental sync.
  Future<List<HealthWorkout>> fetchAnchoredWorkouts() async {
    try {
      final List<dynamic>? raw = await _channel.invokeMethod<List<dynamic>>('fetchAnchoredWorkouts');
      if (raw == null) return [];
      return raw.map((item) => HealthWorkout.fromMap(item as Map<dynamic, dynamic>)).toList();
    } on PlatformException catch (_) {
      return [];
    }
  }
}
