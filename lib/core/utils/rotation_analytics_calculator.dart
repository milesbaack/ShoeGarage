import 'dart:math' as math;
import '../../data/database/database.dart';
import 'unit_formatter.dart';

enum RetirementUrgency {
  due, // 100% reached or exceeded target
  retiringSoon, // <= 3 weeks remaining OR >= 90% worn
  approaching, // <= 8 weeks remaining OR >= 75% worn
  healthy, // > 8 weeks remaining and < 75% worn
  idle, // No activities in last 30 days and not due
}

class ShoeProjection {
  final Shoe shoe;
  final double currentMiles;
  final double targetMiles;
  final double remainingMiles;
  final double milesLast30Days;
  final double weeklyWearRate; // canonical miles / week
  final double? weeksRemaining;
  final DateTime? projectedRetirementDate;
  final RetirementUrgency urgency;
  final double rotationSharePercent; // 0.0 to 100.0

  const ShoeProjection({
    required this.shoe,
    required this.currentMiles,
    required this.targetMiles,
    required this.remainingMiles,
    required this.milesLast30Days,
    required this.weeklyWearRate,
    required this.weeksRemaining,
    required this.projectedRetirementDate,
    required this.urgency,
    required this.rotationSharePercent,
  });

  String formattedWearRate(DistanceUnit unit) {
    if (weeklyWearRate <= 0) {
      return '0.0 ${UnitFormatter.unitLabel(unit)}/wk';
    }
    final display = UnitFormatter.toDisplayDistance(weeklyWearRate, unit);
    return '${display.toStringAsFixed(1)} ${UnitFormatter.unitLabel(unit)}/wk';
  }

  String formattedTimeline(DistanceUnit unit) {
    switch (urgency) {
      case RetirementUrgency.due:
        return 'Target Lifespan Reached';
      case RetirementUrgency.idle:
        return 'Idle (No runs logged in 30 days)';
      case RetirementUrgency.retiringSoon:
      case RetirementUrgency.approaching:
      case RetirementUrgency.healthy:
        if (weeksRemaining == null || projectedRetirementDate == null) {
          return 'No wear rate available';
        }
        final weeks = weeksRemaining!.round();
        final dateStr = _formatDate(projectedRetirementDate!);
        if (weeks <= 1) {
          return 'In ~1 week ($dateStr)';
        }
        return 'In ~$weeks weeks ($dateStr)';
    }
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[date.month - 1];
    return '$month ${date.day}, ${date.year}';
  }

  String urgencyLabel() {
    switch (urgency) {
      case RetirementUrgency.due:
        return 'DUE';
      case RetirementUrgency.retiringSoon:
        return 'RETIRING SOON';
      case RetirementUrgency.approaching:
        return 'APPROACHING';
      case RetirementUrgency.healthy:
        return 'HEALTHY';
      case RetirementUrgency.idle:
        return 'IDLE';
    }
  }
}

class RotationAnalytics {
  final List<ShoeProjection> shoeProjections;
  final double totalActiveMiles;
  final int activeShoeCount;
  final Map<String, double> categoryMiles;
  final Map<String, int> categoryCounts;
  final ShoeProjection? primaryWorkhorse;
  final int shoesNeedingAttentionCount;

  const RotationAnalytics({
    required this.shoeProjections,
    required this.totalActiveMiles,
    required this.activeShoeCount,
    required this.categoryMiles,
    required this.categoryCounts,
    required this.primaryWorkhorse,
    required this.shoesNeedingAttentionCount,
  });
}

class RotationAnalyticsCalculator {
  /// Calculates comprehensive rotation analytics given active shoes and all assigned activities.
  static RotationAnalytics calculate({
    required List<Shoe> activeShoes,
    required List<Activity> assignedActivities,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final cutoffDate = now.subtract(const Duration(days: 30));

    final totalActiveMiles = activeShoes.fold<double>(
      0.0,
      (sum, s) => sum + s.currentDistance,
    );

    final categoryMiles = <String, double>{};
    final categoryCounts = <String, int>{};

    for (final shoe in activeShoes) {
      final category = (shoe.category != null && shoe.category!.trim().isNotEmpty)
          ? shoe.category!.toLowerCase().trim()
          : 'road';
      categoryMiles[category] = (categoryMiles[category] ?? 0.0) + shoe.currentDistance;
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    final projections = <ShoeProjection>[];

    for (final shoe in activeShoes) {
      // Find activities for this shoe in the last 30 days
      final recentActivities = assignedActivities.where((a) {
        return a.shoeId == shoe.id && a.startDate.isAfter(cutoffDate);
      });

      final milesLast30Days = recentActivities.fold<double>(
        0.0,
        (sum, a) => sum + a.distance,
      );

      final weeklyWearRate = (milesLast30Days / 30.0) * 7.0;
      final remainingMiles = math.max(0.0, shoe.targetDistance - shoe.currentDistance);

      final double? weeksRemaining;
      final DateTime? projectedDate;
      final RetirementUrgency urgency;

      final ratio = shoe.targetDistance > 0 ? (shoe.currentDistance / shoe.targetDistance) : 1.0;

      if (remainingMiles <= 0 || ratio >= 1.0) {
        weeksRemaining = 0.0;
        projectedDate = now;
        urgency = RetirementUrgency.due;
      } else if (weeklyWearRate > 0) {
        weeksRemaining = remainingMiles / weeklyWearRate;
        final days = (weeksRemaining * 7.0).round();
        projectedDate = now.add(Duration(days: days));

        if (weeksRemaining <= 3 || ratio >= 0.90) {
          urgency = RetirementUrgency.retiringSoon;
        } else if (weeksRemaining <= 8 || ratio >= 0.75) {
          urgency = RetirementUrgency.approaching;
        } else {
          urgency = RetirementUrgency.healthy;
        }
      } else {
        // No runs in last 30 days
        weeksRemaining = null;
        projectedDate = null;
        urgency = RetirementUrgency.idle;
      }

      final share = totalActiveMiles > 0
          ? (shoe.currentDistance / totalActiveMiles) * 100.0
          : 0.0;

      projections.add(ShoeProjection(
        shoe: shoe,
        currentMiles: shoe.currentDistance,
        targetMiles: shoe.targetDistance,
        remainingMiles: remainingMiles,
        milesLast30Days: milesLast30Days,
        weeklyWearRate: weeklyWearRate,
        weeksRemaining: weeksRemaining,
        projectedRetirementDate: projectedDate,
        urgency: urgency,
        rotationSharePercent: share,
      ));
    }

    // Sort projections by urgency: Due -> RetiringSoon -> Approaching -> Healthy -> Idle
    projections.sort((a, b) {
      final urgencyCompare = a.urgency.index.compareTo(b.urgency.index);
      if (urgencyCompare != 0) return urgencyCompare;
      // If same urgency, sort by remaining miles ascending
      return a.remainingMiles.compareTo(b.remainingMiles);
    });

    // Primary workhorse: shoe with highest 30-day mileage (fallback to highest current distance)
    ShoeProjection? workhorse;
    if (projections.isNotEmpty) {
      workhorse = projections.reduce((curr, next) {
        if (curr.milesLast30Days != next.milesLast30Days) {
          return curr.milesLast30Days > next.milesLast30Days ? curr : next;
        }
        return curr.currentMiles > next.currentMiles ? curr : next;
      });
    }

    final needingAttention = projections.where((p) {
      return p.urgency == RetirementUrgency.due || p.urgency == RetirementUrgency.retiringSoon;
    }).length;

    return RotationAnalytics(
      shoeProjections: projections,
      totalActiveMiles: totalActiveMiles,
      activeShoeCount: activeShoes.length,
      categoryMiles: categoryMiles,
      categoryCounts: categoryCounts,
      primaryWorkhorse: workhorse,
      shoesNeedingAttentionCount: needingAttention,
    );
  }
}
