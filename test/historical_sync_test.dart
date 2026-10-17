import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoe_garage/data/database/database.dart';
import 'package:shoe_garage/data/services/health_kit_service.dart';
import 'package:shoe_garage/data/services/historical_sync_service.dart';
import 'package:shoe_garage/data/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late HealthKitService healthKitService;
  late HistoricalSyncService syncService;
  final List<MethodCall> notificationCalls = [];
  List<Map<String, dynamic>> mockHealthKitWorkouts = [];

  setUp(() {
    notificationCalls.clear();
    mockHealthKitWorkouts.clear();

    db = AppDatabase(NativeDatabase.memory());

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel(NotificationService.channelName),
      (MethodCall call) async {
        notificationCalls.add(call);
        return true;
      },
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel(HealthKitService.channelName),
      (MethodCall call) async {
        if (call.method == 'fetchRecentWorkouts') {
          return mockHealthKitWorkouts;
        }
        return true;
      },
    );

    healthKitService = HealthKitService();
    syncService = HistoricalSyncService(
      healthKitService: healthKitService,
      database: db,
    );
  });

  tearDown(() async {
    await db.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel(NotificationService.channelName),
      null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel(HealthKitService.channelName),
      null,
    );
  });

  group('[STORY-02] Historical 30-Day Sync Tests', () {
    test('[Scenario 1] Stale workout suppression & Inbox routing: 20 historical runs are imported with shoeId = null and 0 notifications fired', () async {
      final now = DateTime.now();

      // Generate 20 historical runs over the last 20 days
      for (int i = 1; i <= 20; i++) {
        final workoutStart = now.subtract(Duration(days: i, hours: 2));
        final workoutEnd = workoutStart.add(const Duration(minutes: 35));

        mockHealthKitWorkouts.add({
          'workoutId': 'hk-historical-$i',
          'workoutType': 'running',
          'distance': 4.5,
          'duration': 2100.0,
          'startDate': workoutStart.toIso8601String(),
          'endDate': workoutEnd.toIso8601String(),
          'source': 'Apple Watch',
          'sourceBundleId': 'com.apple.Health',
        });
      }

      final result = await syncService.syncLast30Days();

      expect(result.totalFetched, 20);
      expect(result.insertedCount, 20);
      expect(result.discardedCount, 0);

      // Verify all 20 entries are in Drift DB and have shoeId == null (Inbox)
      final unassigned = await db.getUnassignedActivities();
      expect(unassigned.length, 20);
      for (final activity in unassigned) {
        expect(activity.shoeId, isNull);
      }

      // Verify NO push notifications were posted during bulk import
      final postedNotifications = notificationCalls
          .where((call) => call.method == 'postTestNotification')
          .toList();
      expect(postedNotifications, isEmpty);
    });

    test('[Scenario 2] Overlapping duplicates (>80% overlap) are discarded, prioritizing native Apple bundles', () async {
      final now = DateTime.now();
      final runStart = now.subtract(const Duration(days: 3, hours: 1));
      final runEnd = runStart.add(const Duration(minutes: 45));

      // 1. Initial sync with an Apple Watch run
      mockHealthKitWorkouts = [
        {
          'workoutId': 'apple-run-1',
          'workoutType': 'running',
          'distance': 5.0,
          'duration': 2700.0,
          'startDate': runStart.toIso8601String(),
          'endDate': runEnd.toIso8601String(),
          'source': 'Apple Watch',
          'sourceBundleId': 'com.apple.Health',
        }
      ];

      await syncService.syncLast30Days();
      var activities = await db.getAllActivities();
      expect(activities.length, 1);
      expect(activities.first.workoutId, 'apple-run-1');

      // 2. Subsequent sync returns a Strava workout covering >80% of the same timeframe (overlapping duplicate)
      mockHealthKitWorkouts = [
        {
          'workoutId': 'strava-run-duplicate',
          'workoutType': 'running',
          'distance': 5.05,
          'duration': 2640.0,
          'startDate': runStart.add(const Duration(minutes: 1)).toIso8601String(),
          'endDate': runEnd.subtract(const Duration(minutes: 1)).toIso8601String(),
          'source': 'Strava',
          'sourceBundleId': 'com.strava.run',
        }
      ];

      final syncResult = await syncService.syncLast30Days();
      expect(syncResult.insertedCount, 0);
      expect(syncResult.discardedCount, 1);

      // Verify only the Apple Watch entry is preserved in Drift DB
      activities = await db.getAllActivities();
      expect(activities.length, 1);
      expect(activities.first.workoutId, 'apple-run-1');
      expect(activities.first.source, 'Apple Watch');
    });
  });
}
