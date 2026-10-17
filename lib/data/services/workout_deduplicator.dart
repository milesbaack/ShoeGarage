import '../database/database.dart';
import 'health_kit_service.dart';

enum DeduplicationAction {
  keepBoth,
  discardIncoming,
  replaceExistingWithIncoming,
}

class WorkoutDeduplicator {
  /// Calculates the overlap ratio between two time intervals.
  /// Overlap ratio is computed relative to the shorter duration interval.
  static double calculateOverlapRatio({
    required DateTime start1,
    required DateTime end1,
    required DateTime start2,
    required DateTime end2,
  }) {
    final dur1 = end1.difference(start1).inSeconds;
    final dur2 = end2.difference(start2).inSeconds;

    if (dur1 <= 0 || dur2 <= 0) return 0.0;

    final overlapStart = start1.isAfter(start2) ? start1 : start2;
    final overlapEnd = end1.isBefore(end2) ? end1 : end2;

    if (overlapEnd.isBefore(overlapStart)) {
      return 0.0;
    }

    final overlapDuration = overlapEnd.difference(overlapStart).inSeconds;
    final minDuration = dur1 < dur2 ? dur1 : dur2;

    return overlapDuration / minDuration;
  }

  /// Returns true if two workout intervals overlap by strictly greater than 80%.
  static bool isOverlappingBy80Percent({
    required DateTime start1,
    required DateTime end1,
    required DateTime start2,
    required DateTime end2,
  }) {
    return calculateOverlapRatio(
      start1: start1,
      end1: end1,
      start2: start2,
      end2: end2,
    ) > 0.80;
  }

  /// Determines if a bundle identifier originates from a native Apple app or system source.
  static bool isAppleNative(String? bundleId) {
    if (bundleId == null || bundleId.isEmpty) return false;
    final lower = bundleId.toLowerCase();
    return lower.startsWith('com.apple.') || lower.contains('apple');
  }

  /// Evaluates an incoming workout against an existing database entry.
  /// Deduplication logic prioritizes native Apple bundles when overlap > 80%.
  static DeduplicationAction evaluate({
    required Activity existing,
    required HealthWorkout incoming,
  }) {
    // Exact workoutId match
    if (existing.workoutId == incoming.workoutId) {
      return DeduplicationAction.discardIncoming;
    }

    // Check for >80% temporal overlap
    final overlaps = isOverlappingBy80Percent(
      start1: existing.startDate,
      end1: existing.endDate,
      start2: incoming.startDate,
      end2: incoming.endDate,
    );

    if (!overlaps) {
      return DeduplicationAction.keepBoth;
    }

    final existingIsApple = isAppleNative(existing.sourceBundleId);
    final incomingIsApple = isAppleNative(incoming.sourceBundleId);

    if (incomingIsApple && !existingIsApple) {
      // Incoming is native Apple, existing is 3rd party -> replace existing with native Apple
      return DeduplicationAction.replaceExistingWithIncoming;
    } else {
      // Existing is native Apple or both are equal -> keep existing, discard duplicate
      return DeduplicationAction.discardIncoming;
    }
  }

  /// Deduplicates a batch of incoming workouts against each other,
  /// ensuring native Apple bundles are preserved when multiple apps recorded the same run.
  static List<HealthWorkout> deduplicateIncomingBatch(List<HealthWorkout> workouts) {
    if (workouts.length <= 1) return workouts;

    final List<HealthWorkout> preserved = [];

    for (final candidate in workouts) {
      bool shouldAdd = true;
      int? replaceIndex;

      for (int i = 0; i < preserved.length; i++) {
        final existing = preserved[i];
        if (existing.workoutId == candidate.workoutId) {
          shouldAdd = false;
          break;
        }

        final overlaps = isOverlappingBy80Percent(
          start1: existing.startDate,
          end1: existing.endDate,
          start2: candidate.startDate,
          end2: candidate.endDate,
        );

        if (overlaps) {
          final existingIsApple = isAppleNative(existing.sourceBundleId);
          final candidateIsApple = isAppleNative(candidate.sourceBundleId);

          if (candidateIsApple && !existingIsApple) {
            replaceIndex = i;
          } else {
            shouldAdd = false;
          }
          break;
        }
      }

      if (replaceIndex != null) {
        preserved[replaceIndex] = candidate;
      } else if (shouldAdd) {
        preserved.add(candidate);
      }
    }

    return preserved;
  }
}
