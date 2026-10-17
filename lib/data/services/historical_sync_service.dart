import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import 'health_kit_service.dart';
import 'workout_deduplicator.dart';

class HistoricalSyncResult {
  final int totalFetched;
  final int insertedCount;
  final int discardedCount;
  final int replacedCount;

  HistoricalSyncResult({
    required this.totalFetched,
    required this.insertedCount,
    required this.discardedCount,
    required this.replacedCount,
  });
}

class HistoricalSyncService {
  final HealthKitService healthKitService;
  final AppDatabase database;

  HistoricalSyncService({
    required this.healthKitService,
    required this.database,
  });

  /// Imports up to the last 30 days of workouts from Apple Health.
  /// All imported historical workouts are routed to the Inbox with shoeId = null,
  /// and any stale runs (>2 hours old) suppress push notifications.
  /// Workouts overlapping by >80% with existing entries are deduplicated, prioritizing native Apple bundles.
  Future<HistoricalSyncResult> syncLast30Days({int days = 30}) async {
    final rawWorkouts = await healthKitService.fetchRecentWorkouts(days: days);
    return processAndImportWorkouts(rawWorkouts);
  }

  /// Incremental sync using HKAnchoredObjectQuery
  Future<HistoricalSyncResult> syncAnchored() async {
    final rawWorkouts = await healthKitService.fetchAnchoredWorkouts();
    return processAndImportWorkouts(rawWorkouts);
  }

  /// Deduplicates and imports a list of HealthWorkout instances into Drift.
  Future<HistoricalSyncResult> processAndImportWorkouts(List<HealthWorkout> rawWorkouts) async {
    if (rawWorkouts.isEmpty) {
      return HistoricalSyncResult(
        totalFetched: 0,
        insertedCount: 0,
        discardedCount: 0,
        replacedCount: 0,
      );
    }

    // Deduplicate within the batch itself first
    final cleanBatch = WorkoutDeduplicator.deduplicateIncomingBatch(rawWorkouts);

    int inserted = 0;
    int discarded = rawWorkouts.length - cleanBatch.length;
    int replaced = 0;

    final existingActivities = await database.getAllActivities();

    for (final workout in cleanBatch) {
      bool shouldInsert = true;
      String? activityToReplaceId;

      for (final existing in existingActivities) {
        final decision = WorkoutDeduplicator.evaluate(
          existing: existing,
          incoming: workout,
        );

        if (decision == DeduplicationAction.discardIncoming) {
          shouldInsert = false;
          discarded++;
          break;
        } else if (decision == DeduplicationAction.replaceExistingWithIncoming) {
          activityToReplaceId = existing.id;
          break;
        }
      }

      if (activityToReplaceId != null) {
        await database.deleteActivity(activityToReplaceId);
        replaced++;
      }

      if (shouldInsert) {
        final id = const Uuid().v4();
        // shoeId is null, routing to Inbox. Push notifications are completely suppressed during bulk import.
        await database.insertActivity(
          ActivitiesCompanion.insert(
            id: id,
            workoutId: workout.workoutId,
            workoutType: workout.workoutType,
            distance: Value(workout.distance),
            duration: Value(workout.duration),
            startDate: workout.startDate,
            endDate: workout.endDate,
            source: Value(workout.source),
            sourceBundleId: Value(workout.sourceBundleId),
          ),
        );
        inserted++;
      }
    }

    return HistoricalSyncResult(
      totalFetched: rawWorkouts.length,
      insertedCount: inserted,
      discardedCount: discarded,
      replacedCount: replaced,
    );
  }
}
