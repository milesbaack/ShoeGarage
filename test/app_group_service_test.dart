import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoe_garage/core/constants/app_constants.dart';
import 'package:shoe_garage/data/database/database.dart';
import 'package:shoe_garage/data/services/app_group_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppGroupService service;
  final List<MethodCall> methodCalls = [];
  String? mockSharedActiveShoes;
  List<Map<String, dynamic>> mockPendingAssignments = [];

  setUp(() {
    methodCalls.clear();
    mockSharedActiveShoes = null;
    mockPendingAssignments = [];

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel(AppConstants.methodChannelName),
      (MethodCall methodCall) async {
        methodCalls.add(methodCall);
        switch (methodCall.method) {
          case 'saveActiveShoes':
            final args = methodCall.arguments as Map<dynamic, dynamic>;
            mockSharedActiveShoes = args['shoesJson'] as String;
            return true;
          case 'getActiveShoes':
            return mockSharedActiveShoes;
          case 'getPendingAssignments':
            return mockPendingAssignments;
          case 'clearPendingAssignments':
            mockPendingAssignments.clear();
            return true;
          case 'appendPendingAssignment':
            final args = methodCall.arguments as Map<dynamic, dynamic>;
            mockPendingAssignments.add({
              'workoutId': args['workoutId'],
              'shoeId': args['shoeId'],
              'timestamp': 123456789.0,
            });
            return true;
          default:
            return null;
        }
      },
    );

    service = AppGroupService();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel(AppConstants.methodChannelName),
      null,
    );
  });

  group('AppGroupService Unit Tests', () {
    test('syncActiveShoes sends JSON data to MethodChannel', () async {
      final shoe = Shoe(
        id: 'shoe-1',
        name: 'Hoka Clifton',
        brand: 'Hoka',
        model: 'Clifton 9',
        category: 'road',
        currentDistance: 120.5,
        targetDistance: 400.0,
        isRetired: false,
        createdAt: DateTime.now(),
      );

      final success = await service.syncActiveShoes([shoe]);
      expect(success, true);
      expect(mockSharedActiveShoes, isNotNull);

      final List<dynamic> decoded = jsonDecode(mockSharedActiveShoes!);
      expect(decoded.length, 1);
      expect(decoded.first['id'], 'shoe-1');
      expect(decoded.first['name'], 'Hoka Clifton');
      expect(decoded.first['currentDistance'], 120.5);
    });

    test('getPendingAssignments and clearPendingAssignments operate correctly', () async {
      mockPendingAssignments = [
        {
          'workoutId': 'hk-1',
          'shoeId': 'shoe-1',
          'timestamp': 1000.0,
        }
      ];

      final pending = await service.getPendingAssignments();
      expect(pending.length, 1);
      expect(pending.first.workoutId, 'hk-1');
      expect(pending.first.shoeId, 'shoe-1');

      final cleared = await service.clearPendingAssignments();
      expect(cleared, true);

      final pendingAfterClear = await service.getPendingAssignments();
      expect(pendingAfterClear, isEmpty);
    });
  });
}
