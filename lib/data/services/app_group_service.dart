import 'dart:convert';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';
import '../database/database.dart';

class PendingAssignment {
  final String workoutId;
  final String shoeId;
  final double timestamp;

  PendingAssignment({
    required this.workoutId,
    required this.shoeId,
    required this.timestamp,
  });

  factory PendingAssignment.fromMap(Map<dynamic, dynamic> map) {
    return PendingAssignment(
      workoutId: map['workoutId'] as String? ?? '',
      shoeId: map['shoeId'] as String? ?? '',
      timestamp: (map['timestamp'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AppGroupService {
  final MethodChannel _channel;

  AppGroupService({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(AppConstants.methodChannelName);

  /// Synchronize the list of active shoes to iOS App Group UserDefaults.
  /// This allows Swift background queries and interactive push notifications
  /// to access active shoes without waking the Flutter engine.
  Future<bool> syncActiveShoes(List<Shoe> shoes) async {
    try {
      final shoeData = shoes.map((shoe) => {
        'id': shoe.id,
        'name': shoe.name,
        'brand': shoe.brand,
        'model': shoe.model,
        'category': shoe.category,
        'currentDistance': shoe.currentDistance,
        'targetDistance': shoe.targetDistance,
      }).toList();

      final jsonString = jsonEncode(shoeData);
      final result = await _channel.invokeMethod<bool>('saveActiveShoes', {
        'shoesJson': jsonString,
      });
      return result ?? false;
    } on PlatformException catch (_) {
      // In tests or non-iOS environments, fail gracefully
      return false;
    }
  }

  /// Synchronize unit preference ('mi' or 'km') to iOS App Group UserDefaults.
  Future<bool> syncDistanceUnit(String unit) async {
    try {
      final result = await _channel.invokeMethod<bool>('saveDistanceUnit', {
        'unit': unit,
      });
      return result ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Read active shoes directly from App Group UserDefaults.
  Future<List<Map<String, dynamic>>> getActiveShoesFromUserDefaults() async {
    try {
      final jsonString = await _channel.invokeMethod<String>('getActiveShoes');
      if (jsonString == null || jsonString.isEmpty) return [];
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } on PlatformException catch (_) {
      return [];
    }
  }

  /// Retrieve all pending workout-to-shoe assignments queued by native notifications.
  Future<List<PendingAssignment>> getPendingAssignments() async {
    try {
      final List<dynamic>? raw = await _channel.invokeMethod<List<dynamic>>('getPendingAssignments');
      if (raw == null) return [];
      return raw.map((item) => PendingAssignment.fromMap(item as Map<dynamic, dynamic>)).toList();
    } on PlatformException catch (_) {
      return [];
    }
  }

  /// Clear the pending assignments queue in shared UserDefaults after syncing into Drift.
  Future<bool> clearPendingAssignments() async {
    try {
      final result = await _channel.invokeMethod<bool>('clearPendingAssignments');
      return result ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Append a pending assignment directly (useful for testing or bridge delegation).
  Future<bool> appendPendingAssignment({required String workoutId, required String shoeId}) async {
    try {
      final result = await _channel.invokeMethod<bool>('appendPendingAssignment', {
        'workoutId': workoutId,
        'shoeId': shoeId,
      });
      return result ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }
}
