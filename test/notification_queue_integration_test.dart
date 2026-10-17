import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoe_garage/core/constants/app_constants.dart';
import 'package:shoe_garage/data/database/database.dart';
import 'package:shoe_garage/data/services/app_group_service.dart';
import 'package:shoe_garage/data/services/assignment_queue_processor.dart';
import 'package:shoe_garage/data/services/health_kit_service.dart';
import 'package:shoe_garage/data/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late AppGroupService appGroupService;
  late NotificationService notificationService;
  late HealthKitService healthKitService;
  late AssignmentQueueProcessor processor;

  List<Map<String, dynamic>> mockUserDefaultsQueue = [];
  String? mockUserDefaultsActiveShoes;
  final List<MethodCall> notificationCalls = [];

  setUp(() {
    mockUserDefaultsQueue.clear();
    mockUserDefaultsActiveShoes = null;
    notificationCalls.clear();

    db = AppDatabase(NativeDatabase.memory());

    // Mock AppGroup channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel(AppConstants.methodChannelName),
      (MethodCall call) async {
        switch (call.method) {
          case 'saveActiveShoes':
            final args = call.arguments as Map<dynamic, dynamic>;
            mockUserDefaultsActiveShoes = args['shoesJson'] as String;
            return true;
          case 'getActiveShoes':
            return mockUserDefaultsActiveShoes;
          case 'getPendingAssignments':
            return mockUserDefaultsQueue;
          case 'clearPendingAssignments':
            mockUserDefaultsQueue.clear();
            return true;
          case 'appendPendingAssignment':
            final args = call.arguments as Map<dynamic, dynamic>;
            mockUserDefaultsQueue.add({
              'workoutId': args['workoutId'],
              'shoeId': args['shoeId'],
              'timestamp': 1000.0,
            });
            return true;
          default:
            return null;
        }
      },
    );

    // Mock Notification channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel(NotificationService.channelName),
      (MethodCall call) async {
        notificationCalls.add(call);
        return true;
      },
    );

    // Mock HealthKit channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel(HealthKitService.channelName),
      (MethodCall call) async {
        if (call.method == 'fetchRecentWorkouts') {
          return [
            {
              'workoutId': 'workout-999',
              'workoutType': 'running',
              'distance': 7.5,
              'duration': 2700.0,
              'startDate': DateTime.now().subtract(const Duration(minutes: 45)).toIso8601String(),
              'endDate': DateTime.now().toIso8601String(),
              'source': 'Apple Watch',
              'sourceBundleId': 'com.apple.health',
            }
          ];
        }
        return true;
      },
    );

    appGroupService = AppGroupService();
    notificationService = NotificationService();
    healthKitService = HealthKitService();
    processor = AssignmentQueueProcessor(
      appGroupService: appGroupService,
      database: db,
      healthKitService: healthKitService,
    );
  });

  tearDown(() async {
    await db.close();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel(AppConstants.methodChannelName),
      null,
    );
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

  group('[STORY-01] Notification Action & Queue Integration Test', () {
    test('[TEST-01] User taps notification action on lockscreen and Drift DB updates on app launch', () async {
      // 1. Initial State: User has a shoe in their rotation
      await db.insertShoe(
        ShoesCompanion.insert(
          id: 'shoe-hoka',
          name: 'Hoka - Race Day',
          currentDistance: const Value(50.0),
          targetDistance: const Value(400.0),
        ),
      );

      // Verify initial shoe distance is 50.0
      var shoe = await db.getShoeById('shoe-hoka');
      expect(shoe?.currentDistance, 50.0);

      // 2. Workout is completed, Swift notification action "Hoka - Race Day" is tapped on lock screen
      // Simulating Swift appending [workout-999, shoe-hoka] to UserDefaults pending queue
      await appGroupService.appendPendingAssignment(
        workoutId: 'workout-999',
        shoeId: 'shoe-hoka',
      );

      // Verify item is queued in UserDefaults
      var pending = await appGroupService.getPendingAssignments();
      expect(pending.length, 1);
      expect(pending.first.workoutId, 'workout-999');
      expect(pending.first.shoeId, 'shoe-hoka');

      // 3. User opens the app (app launch / foreground event)
      final processedCount = await processor.processQueue();
      expect(processedCount, 1);

      // 4. Verify Drift database state:
      // a. Activity was created and assigned to shoe-hoka
      final activity = await db.getActivityByWorkoutId('workout-999');
      expect(activity, isNotNull);
      expect(activity?.shoeId, 'shoe-hoka');
      expect(activity?.distance, 7.5);

      // b. Shoe's currentDistance was incremented by 7.5 miles (50.0 + 7.5 = 57.5)
      shoe = await db.getShoeById('shoe-hoka');
      expect(shoe?.currentDistance, 57.5);

      // c. Pending queue in UserDefaults is now drained and empty
      pending = await appGroupService.getPendingAssignments();
      expect(pending, isEmpty);
    });

    test('NotificationService requests permission and updates categories', () async {
      final granted = await notificationService.requestPermissions();
      expect(granted, true);
      expect(notificationCalls.any((c) => c.method == 'requestPermissions'), true);

      final updated = await notificationService.updateCategories();
      expect(updated, true);
      expect(notificationCalls.any((c) => c.method == 'updateCategories'), true);
    });
  });
}
