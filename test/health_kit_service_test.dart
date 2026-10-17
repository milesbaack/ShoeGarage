import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoe_garage/data/services/health_kit_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late HealthKitService service;
  final List<MethodCall> methodCalls = [];
  bool mockAvailable = true;
  bool mockAuthorized = true;
  List<Map<String, dynamic>> mockWorkouts = [];

  setUp(() {
    methodCalls.clear();
    mockAvailable = true;
    mockAuthorized = true;
    mockWorkouts = [];

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel(HealthKitService.channelName),
      (MethodCall methodCall) async {
        methodCalls.add(methodCall);
        switch (methodCall.method) {
          case 'isHealthDataAvailable':
            return mockAvailable;
          case 'requestAuthorization':
            if (!mockAuthorized) {
              throw PlatformException(
                code: 'AUTH_DENIED',
                message: 'User denied Apple Health access',
              );
            }
            return true;
          case 'startObserver':
            return true;
          case 'fetchRecentWorkouts':
            return mockWorkouts;
          default:
            return null;
        }
      },
    );

    service = HealthKitService();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel(HealthKitService.channelName),
      null,
    );
  });

  group('HealthKitService Unit Tests [ENABLER-02]', () {
    test('isHealthDataAvailable returns status', () async {
      expect(await service.isHealthDataAvailable(), true);

      mockAvailable = false;
      expect(await service.isHealthDataAvailable(), false);
    });

    test('requestAuthorization succeeds when permitted', () async {
      final granted = await service.requestAuthorization();
      expect(granted, true);
      expect(methodCalls.any((call) => call.method == 'requestAuthorization'), true);
    });

    test('requestAuthorization handles denial gracefully [Scenario 2: Permission Handling]', () async {
      mockAuthorized = false;
      final granted = await service.requestAuthorization();
      expect(granted, false);
    });

    test('fetchRecentWorkouts correctly parses HealthWorkout models', () async {
      final now = DateTime.now();
      mockWorkouts = [
        {
          'workoutId': 'hk-workout-1',
          'workoutType': 'running',
          'distance': 6.2,
          'duration': 2400.0,
          'startDate': now.subtract(const Duration(minutes: 40)).toIso8601String(),
          'endDate': now.toIso8601String(),
          'source': 'Apple Watch Ultra',
          'sourceBundleId': 'com.apple.health',
        }
      ];

      final workouts = await service.fetchRecentWorkouts(days: 7);
      expect(workouts.length, 1);
      final workout = workouts.first;
      expect(workout.workoutId, 'hk-workout-1');
      expect(workout.workoutType, 'running');
      expect(workout.distance, 6.2);
      expect(workout.duration, 2400.0);
      expect(workout.source, 'Apple Watch Ultra');
      expect(workout.sourceBundleId, 'com.apple.health');
    });
  });
}
