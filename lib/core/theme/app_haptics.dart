import 'package:flutter/services.dart';

/// Centralized iOS haptic engine for the Performance Studio interface.
/// Provides tactical, sensory feedback on touch interactions.
class AppHaptics {
  AppHaptics._();

  /// Feather-light tick for tab switching, segmented controls, or filter chips.
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// Gentle tap feedback on button taps, card presses, or modal dismissals.
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Solid, satisfying thud when assigning a workout to a shoe or adding mileage.
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// High-impact celebratory pulse for retiring a shoe, reaching a milestone, or inbox zero.
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }
}
