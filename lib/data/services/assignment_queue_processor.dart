import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import 'app_group_service.dart';
import 'health_kit_service.dart';

class AssignmentQueueProcessor {
  final AppGroupService appGroupService;
  final AppDatabase database;
  final HealthKitService? healthKitService;

  AssignmentQueueProcessor({
    required this.appGroupService,
    required this.database,
    this.healthKitService,
  });

  /// Drains and processes all pending workout-to-shoe assignments queued in UserDefaults.
  /// Returns the number of successfully processed assignments.
  Future<int> processQueue() async {
    final pendingAssignments = await appGroupService.getPendingAssignments();
    if (pendingAssignments.isEmpty) return 0;

    int processedCount = 0;

    for (final item in pendingAssignments) {
      if (item.workoutId.isEmpty || item.shoeId.isEmpty) continue;

      // Check if activity already exists in Drift database
      Activity? activity = await database.getActivityByWorkoutId(item.workoutId);

      if (activity == null && healthKitService != null) {
        // Query HealthKit to populate the activity before assigning
        final recentWorkouts = await healthKitService!.fetchRecentWorkouts(days: 2);
        final match = recentWorkouts.where((w) => w.workoutId == item.workoutId).firstOrNull;

        if (match != null) {
          final newId = const Uuid().v4();
          await database.insertActivity(
            ActivitiesCompanion.insert(
              id: newId,
              workoutId: match.workoutId,
              workoutType: match.workoutType,
              distance: Value(match.distance),
              duration: Value(match.duration),
              startDate: match.startDate,
              endDate: match.endDate,
              source: Value(match.source),
              sourceBundleId: Value(match.sourceBundleId),
            ),
          );
          activity = await database.getActivityByWorkoutId(item.workoutId);
        }
      }

      if (activity != null) {
        await database.assignActivityToShoe(
          activityId: activity.id,
          shoeId: item.shoeId,
        );
        processedCount++;
      }
    }

    // Clear the queue in UserDefaults after processing
    await appGroupService.clearPendingAssignments();
    return processedCount;
  }
}
