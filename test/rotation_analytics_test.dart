import 'package:flutter_test/flutter_test.dart';
import 'package:shoe_garage/core/utils/rotation_analytics_calculator.dart';
import 'package:shoe_garage/core/utils/unit_formatter.dart';
import 'package:shoe_garage/data/database/database.dart';

void main() {
  group('RotationAnalyticsCalculator Unit Tests [TEST-ROTATION-ANALYTICS]', () {
    final refDate = DateTime(2026, 10, 17, 12, 0);

    test('Calculates empty analytics when no active shoes', () {
      final analytics = RotationAnalyticsCalculator.calculate(
        activeShoes: [],
        assignedActivities: [],
        referenceDate: refDate,
      );

      expect(analytics.activeShoeCount, 0);
      expect(analytics.totalActiveMiles, 0.0);
      expect(analytics.shoeProjections, isEmpty);
      expect(analytics.primaryWorkhorse, isNull);
      expect(analytics.shoesNeedingAttentionCount, 0);
    });

    test('Calculates mileage shares, categories, and wear rates correctly', () {
      final shoe1 = Shoe(
        id: 'shoe-1',
        name: 'Daily Trainer (Ghost 15)',
        brand: 'Brooks',
        model: 'Ghost 15',
        category: 'road',
        currentDistance: 200.0,
        targetDistance: 400.0,
        isRetired: false,
        createdAt: refDate.subtract(const Duration(days: 60)),
      );

      final shoe2 = Shoe(
        id: 'shoe-2',
        name: 'Speed Shoe (Endorphin Speed 3)',
        brand: 'Saucony',
        model: 'Speed 3',
        category: 'road',
        currentDistance: 100.0,
        targetDistance: 400.0,
        isRetired: false,
        createdAt: refDate.subtract(const Duration(days: 40)),
      );

      final shoe3 = Shoe(
        id: 'shoe-3',
        name: 'Trail Cruiser (Speedcross 6)',
        brand: 'Salomon',
        model: 'Speedcross 6',
        category: 'trail',
        currentDistance: 100.0,
        targetDistance: 400.0,
        isRetired: false,
        createdAt: refDate.subtract(const Duration(days: 30)),
      );

      // Activities in the last 30 days:
      // shoe1: 60 miles logged in last 30 days -> wear rate: (60/30)*7 = 14.0 mi/week
      // shoe2: 15 miles logged in last 30 days -> wear rate: (15/30)*7 = 3.5 mi/week
      // shoe3: 0 miles logged in last 30 days -> wear rate: 0.0 mi/week (idle)
      // Old activity > 30 days ago for shoe1 (should be excluded from 30d wear rate)
      final activities = [
        Activity(
          id: 'act-1',
          workoutId: 'wk-1',
          workoutType: 'running',
          distance: 30.0,
          duration: 10000.0,
          startDate: refDate.subtract(const Duration(days: 10)),
          endDate: refDate.subtract(const Duration(days: 10)),
          shoeId: 'shoe-1',
          createdAt: refDate,
        ),
        Activity(
          id: 'act-2',
          workoutId: 'wk-2',
          workoutType: 'running',
          distance: 30.0,
          duration: 10000.0,
          startDate: refDate.subtract(const Duration(days: 20)),
          endDate: refDate.subtract(const Duration(days: 20)),
          shoeId: 'shoe-1',
          createdAt: refDate,
        ),
        Activity(
          id: 'act-old',
          workoutId: 'wk-old',
          workoutType: 'running',
          distance: 140.0,
          duration: 40000.0,
          startDate: refDate.subtract(const Duration(days: 45)), // > 30 days
          endDate: refDate.subtract(const Duration(days: 45)),
          shoeId: 'shoe-1',
          createdAt: refDate,
        ),
        Activity(
          id: 'act-3',
          workoutId: 'wk-3',
          workoutType: 'running',
          distance: 15.0,
          duration: 5000.0,
          startDate: refDate.subtract(const Duration(days: 5)),
          endDate: refDate.subtract(const Duration(days: 5)),
          shoeId: 'shoe-2',
          createdAt: refDate,
        ),
      ];

      final analytics = RotationAnalyticsCalculator.calculate(
        activeShoes: [shoe1, shoe2, shoe3],
        assignedActivities: activities,
        referenceDate: refDate,
      );

      expect(analytics.activeShoeCount, 3);
      expect(analytics.totalActiveMiles, 400.0); // 200 + 100 + 100

      // Category metrics
      expect(analytics.categoryCounts['road'], 2);
      expect(analytics.categoryCounts['trail'], 1);
      expect(analytics.categoryMiles['road'], 300.0);
      expect(analytics.categoryMiles['trail'], 100.0);

      // Primary workhorse should be shoe-1 (60 miles in last 30d)
      expect(analytics.primaryWorkhorse?.shoe.id, 'shoe-1');

      // Check shoe-1 projection:
      // remaining: 400 - 200 = 200 miles
      // weeklyWearRate: 14.0 mi/wk
      // weeksRemaining: 200 / 14 = 14.28 wks
      // status: healthy (> 8 wks and 50% worn)
      // share: 200 / 400 = 50.0%
      final proj1 = analytics.shoeProjections.firstWhere((p) => p.shoe.id == 'shoe-1');
      expect(proj1.currentMiles, 200.0);
      expect(proj1.remainingMiles, 200.0);
      expect(proj1.milesLast30Days, 60.0);
      expect(proj1.weeklyWearRate, closeTo(14.0, 0.01));
      expect(proj1.weeksRemaining, closeTo(14.28, 0.1));
      expect(proj1.urgency, RetirementUrgency.healthy);
      expect(proj1.rotationSharePercent, 50.0);
      expect(proj1.formattedWearRate(DistanceUnit.miles), '14.0 mi/wk');
      // In km: 14.0 * 1.609344 = 22.5 km/wk
      expect(proj1.formattedWearRate(DistanceUnit.kilometers), '22.5 km/wk');

      // Check shoe-3 projection:
      // 0 miles in last 30d -> idle
      final proj3 = analytics.shoeProjections.firstWhere((p) => p.shoe.id == 'shoe-3');
      expect(proj3.milesLast30Days, 0.0);
      expect(proj3.weeklyWearRate, 0.0);
      expect(proj3.weeksRemaining, isNull);
      expect(proj3.urgency, RetirementUrgency.idle);
      expect(proj3.urgencyLabel(), 'IDLE');
      expect(proj3.formattedTimeline(DistanceUnit.miles), 'Idle (No runs logged in 30 days)');
    });

    test('Assigns correct urgency statuses: due, retiringSoon, and approaching', () {
      // Shoe due (100% reached)
      final dueShoe = Shoe(
        id: 'shoe-due',
        name: 'Worn Out Pegasus',
        currentDistance: 405.0,
        targetDistance: 400.0,
        isRetired: false,
        createdAt: refDate,
      );

      // Shoe retiring soon (<= 3 weeks remaining)
      // 370 / 400 mi -> 30 mi remaining, 60 mi in 30d (14 mi/wk) -> ~2.1 weeks remaining
      final soonShoe = Shoe(
        id: 'shoe-soon',
        name: 'Retiring Soon Racer',
        currentDistance: 370.0,
        targetDistance: 400.0,
        isRetired: false,
        createdAt: refDate,
      );

      // Shoe approaching (<= 8 weeks remaining)
      // 320 / 400 mi -> 80 mi remaining, 60 mi in 30d (14 mi/wk) -> ~5.7 weeks remaining
      final approachingShoe = Shoe(
        id: 'shoe-approaching',
        name: 'Approaching Trainer',
        currentDistance: 320.0,
        targetDistance: 400.0,
        isRetired: false,
        createdAt: refDate,
      );

      final activities = [
        Activity(
          id: 'act-soon',
          workoutId: 'wk-s',
          workoutType: 'running',
          distance: 60.0,
          duration: 20000.0,
          startDate: refDate.subtract(const Duration(days: 10)),
          endDate: refDate.subtract(const Duration(days: 10)),
          shoeId: 'shoe-soon',
          createdAt: refDate,
        ),
        Activity(
          id: 'act-app',
          workoutId: 'wk-a',
          workoutType: 'running',
          distance: 60.0,
          duration: 20000.0,
          startDate: refDate.subtract(const Duration(days: 10)),
          endDate: refDate.subtract(const Duration(days: 10)),
          shoeId: 'shoe-approaching',
          createdAt: refDate,
        ),
      ];

      final analytics = RotationAnalyticsCalculator.calculate(
        activeShoes: [dueShoe, soonShoe, approachingShoe],
        assignedActivities: activities,
        referenceDate: refDate,
      );

      final pDue = analytics.shoeProjections.firstWhere((p) => p.shoe.id == 'shoe-due');
      expect(pDue.urgency, RetirementUrgency.due);
      expect(pDue.urgencyLabel(), 'DUE');
      expect(pDue.formattedTimeline(DistanceUnit.miles), 'Target Lifespan Reached');

      final pSoon = analytics.shoeProjections.firstWhere((p) => p.shoe.id == 'shoe-soon');
      expect(pSoon.urgency, RetirementUrgency.retiringSoon);
      expect(pSoon.urgencyLabel(), 'RETIRING SOON');
      expect(pSoon.weeksRemaining, closeTo(2.14, 0.1));
      expect(pSoon.formattedTimeline(DistanceUnit.miles), contains('In ~2 weeks'));

      final pApp = analytics.shoeProjections.firstWhere((p) => p.shoe.id == 'shoe-approaching');
      expect(pApp.urgency, RetirementUrgency.approaching);
      expect(pApp.urgencyLabel(), 'APPROACHING');
      expect(pApp.weeksRemaining, closeTo(5.71, 0.1));
      expect(pApp.formattedTimeline(DistanceUnit.miles), contains('In ~6 weeks'));

      // Both due and retiring soon count towards needing attention (2 shoes)
      expect(analytics.shoesNeedingAttentionCount, 2);

      // Projections are sorted with highest urgency first (due -> retiringSoon -> approaching)
      expect(analytics.shoeProjections[0].shoe.id, 'shoe-due');
      expect(analytics.shoeProjections[1].shoe.id, 'shoe-soon');
      expect(analytics.shoeProjections[2].shoe.id, 'shoe-approaching');
    });
  });
}
