import 'package:flutter_test/flutter_test.dart';
import 'package:shoe_garage/data/database/database.dart';
import 'package:shoe_garage/data/services/health_kit_service.dart';
import 'package:shoe_garage/data/services/workout_deduplicator.dart';

void main() {
  group('[STORY-02] Workout Deduplication Unit Tests [TEST-01]', () {
    test('[TEST-01] Feed two overlapping workout objects (>80% overlap) into deduplication function and ensure only one is preserved (prioritizing Apple)', () {
      final baseTime = DateTime(2026, 10, 16, 8, 0, 0);

      // Existing workout: Apple Watch recording (08:00 - 08:30, 30 min)
      final existingAppleActivity = Activity(
        id: 'act-1',
        workoutId: 'hk-apple-100',
        shoeId: null,
        workoutType: 'running',
        distance: 4.0,
        duration: 1800.0,
        startDate: baseTime,
        endDate: baseTime.add(const Duration(minutes: 30)),
        source: 'Apple Watch',
        sourceBundleId: 'com.apple.Health',
        createdAt: baseTime,
      );

      // Incoming workout: Strava recording of the exact same run (08:01 - 08:29, 28 min)
      // Overlap: 28 min / 28 min = 100% overlap (>80%)
      final incomingStravaWorkout = HealthWorkout(
        workoutId: 'strava-200',
        workoutType: 'running',
        distance: 4.05,
        duration: 1680.0,
        startDate: baseTime.add(const Duration(minutes: 1)),
        endDate: baseTime.add(const Duration(minutes: 29)),
        source: 'Strava',
        sourceBundleId: 'com.strava.run',
      );

      final decision = WorkoutDeduplicator.evaluate(
        existing: existingAppleActivity,
        incoming: incomingStravaWorkout,
      );

      // Incoming Strava should be discarded, preserving existing native Apple entry
      expect(decision, DeduplicationAction.discardIncoming);
    });

    test('Incoming native Apple bundle replaces existing 3rd-party duplicate when overlapping >80%', () {
      final baseTime = DateTime(2026, 10, 16, 9, 0, 0);

      // Existing 3rd-party activity (Garmin)
      final existingGarminActivity = Activity(
        id: 'act-2',
        workoutId: 'garmin-100',
        shoeId: null,
        workoutType: 'running',
        distance: 5.0,
        duration: 2400.0,
        startDate: baseTime,
        endDate: baseTime.add(const Duration(minutes: 40)),
        source: 'Garmin Connect',
        sourceBundleId: 'com.garmin.connect.mobile',
        createdAt: baseTime,
      );

      // Incoming native Apple workout of the same run (09:00 - 09:39, 39 min)
      final incomingAppleWorkout = HealthWorkout(
        workoutId: 'hk-apple-200',
        workoutType: 'running',
        distance: 5.02,
        duration: 2340.0,
        startDate: baseTime,
        endDate: baseTime.add(const Duration(minutes: 39)),
        source: 'Apple Watch',
        sourceBundleId: 'com.apple.fitness',
      );

      final decision = WorkoutDeduplicator.evaluate(
        existing: existingGarminActivity,
        incoming: incomingAppleWorkout,
      );

      // Native Apple should replace 3rd party
      expect(decision, DeduplicationAction.replaceExistingWithIncoming);
    });

    test('Workouts with <80% overlap are both preserved', () {
      final baseTime = DateTime(2026, 10, 16, 14, 0, 0);

      // Run 1: Morning run (14:00 - 14:30)
      final existingActivity = Activity(
        id: 'act-3',
        workoutId: 'hk-1',
        shoeId: null,
        workoutType: 'running',
        distance: 3.1,
        duration: 1800.0,
        startDate: baseTime,
        endDate: baseTime.add(const Duration(minutes: 30)),
        source: 'Apple Watch',
        sourceBundleId: 'com.apple.Health',
        createdAt: baseTime,
      );

      // Run 2: Afternoon run (15:00 - 15:30, completely separate)
      final incomingWorkout = HealthWorkout(
        workoutId: 'hk-2',
        workoutType: 'running',
        distance: 3.2,
        duration: 1800.0,
        startDate: baseTime.add(const Duration(minutes: 60)),
        endDate: baseTime.add(const Duration(minutes: 90)),
        source: 'Apple Watch',
        sourceBundleId: 'com.apple.Health',
      );

      final decision = WorkoutDeduplicator.evaluate(
        existing: existingActivity,
        incoming: incomingWorkout,
      );

      expect(decision, DeduplicationAction.keepBoth);
    });

    test('deduplicateIncomingBatch collapses overlapping duplicates, preserving native Apple bundle', () {
      final baseTime = DateTime(2026, 10, 15, 7, 0, 0);

      final strava = HealthWorkout(
        workoutId: 'strava-run-1',
        workoutType: 'running',
        distance: 6.0,
        duration: 3000.0,
        startDate: baseTime,
        endDate: baseTime.add(const Duration(minutes: 50)),
        source: 'Strava',
        sourceBundleId: 'com.strava.run',
      );

      final apple = HealthWorkout(
        workoutId: 'apple-run-1',
        workoutType: 'running',
        distance: 6.02,
        duration: 2980.0,
        startDate: baseTime.add(const Duration(seconds: 10)),
        endDate: baseTime.add(const Duration(minutes: 50)),
        source: 'Apple Watch',
        sourceBundleId: 'com.apple.Health',
      );

      final distinctRun = HealthWorkout(
        workoutId: 'apple-run-2',
        workoutType: 'walking',
        distance: 1.5,
        duration: 1200.0,
        startDate: baseTime.add(const Duration(hours: 3)),
        endDate: baseTime.add(const Duration(hours: 3, minutes: 20)),
        source: 'Apple Watch',
        sourceBundleId: 'com.apple.Health',
      );

      final deduplicated = WorkoutDeduplicator.deduplicateIncomingBatch([strava, apple, distinctRun]);
      expect(deduplicated.length, 2);
      expect(deduplicated.any((w) => w.workoutId == 'apple-run-1'), true);
      expect(deduplicated.any((w) => w.workoutId == 'apple-run-2'), true);
      expect(deduplicated.any((w) => w.workoutId == 'strava-run-1'), false);
    });
  });
}
