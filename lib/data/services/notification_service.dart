import 'package:flutter/services.dart';

class NotificationService {
  static const String channelName = 'com.shoegarage/notifications';
  final MethodChannel _channel;

  NotificationService({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(channelName);

  /// Request iOS user notification permissions (alerts, sounds, badges).
  Future<bool> requestPermissions() async {
    try {
      final granted = await _channel.invokeMethod<bool>('requestPermissions');
      return granted ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Inform native iOS to refresh dynamic shoe action buttons on UNNotificationCategory.
  Future<bool> updateCategories() async {
    try {
      final updated = await _channel.invokeMethod<bool>('updateCategories');
      return updated ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Posts a test or simulated workout notification.
  Future<bool> postTestNotification({
    required String workoutId,
    required String workoutType,
    required double distance,
  }) async {
    try {
      final posted = await _channel.invokeMethod<bool>('postTestNotification', {
        'workoutId': workoutId,
        'workoutType': workoutType,
        'distance': distance,
      });
      return posted ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }
}
