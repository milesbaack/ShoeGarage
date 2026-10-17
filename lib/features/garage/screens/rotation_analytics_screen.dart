import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/rotation_analytics_calculator.dart';
import '../../../core/utils/unit_formatter.dart';
import '../../../data/providers.dart';
import 'shoe_detail_screen.dart';

class RotationAnalyticsScreen extends ConsumerWidget {
  const RotationAnalyticsScreen({super.key});

  Color _urgencyColor(RetirementUrgency urgency) {
    switch (urgency) {
      case RetirementUrgency.due:
        return Colors.red;
      case RetirementUrgency.retiringSoon:
        return Colors.deepOrange;
      case RetirementUrgency.approaching:
        return Colors.amber.shade800;
      case RetirementUrgency.healthy:
        return Colors.green;
      case RetirementUrgency.idle:
        return Colors.blueGrey;
    }
  }

  IconData _urgencyIcon(RetirementUrgency urgency) {
    switch (urgency) {
      case RetirementUrgency.due:
        return Icons.error_outline;
      case RetirementUrgency.retiringSoon:
        return Icons.warning_amber_rounded;
      case RetirementUrgency.approaching:
        return Icons.timelapse;
      case RetirementUrgency.healthy:
        return Icons.check_circle_outline;
      case RetirementUrgency.idle:
        return Icons.bedtime_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(rotationAnalyticsProvider);
    final unit = ref.watch(unitPreferenceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rotation Analytics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: analytics.activeShoeCount == 0
          ? _buildEmptyState(context)
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Top Summary Row
                _buildSummaryHeader(context, analytics, unit),
                const SizedBox(height: 16),

                // Mileage Share Card
                _buildMileageShareSection(context, analytics, unit),
                const SizedBox(height: 16),

                // Category Distribution
                if (analytics.categoryCounts.isNotEmpty) ...[
                  _buildCategorySection(context, analytics, unit),
                  const SizedBox(height: 16),
                ],

                // Retirement Projections Section
                _buildProjectionsSection(context, analytics, unit),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insights,
              size: 72,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Active Shoes in Rotation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Add active shoes to your Garage to view rotation mileage shares, wear velocity, and retirement date forecasts.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(
    BuildContext context,
    RotationAnalytics analytics,
    DistanceUnit unit,
  ) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GARAGE ROTATION SUMMARY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryMetric(
                    context,
                    label: 'Rotation Distance',
                    value: UnitFormatter.formatDistance(analytics.totalActiveMiles, unit),
                    icon: Icons.speed,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Container(width: 1, height: 42, color: Theme.of(context).dividerColor),
                Expanded(
                  child: _buildSummaryMetric(
                    context,
                    label: 'Active Shoes',
                    value: '${analytics.activeShoeCount} in rotation',
                    icon: Icons.directions_run,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            if (analytics.shoesNeedingAttentionCount > 0) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.deepOrange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notification_important, size: 18, color: Colors.deepOrange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${analytics.shoesNeedingAttentionCount} shoe${analytics.shoesNeedingAttentionCount > 1 ? "s" : ""} reaching end of target lifespan soon',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMetric(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMileageShareSection(
    BuildContext context,
    RotationAnalytics analytics,
    DistanceUnit unit,
  ) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ROTATION MILEAGE SHARE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                if (analytics.primaryWorkhorse != null)
                  Flexible(
                    child: Text(
                      'Workhorse: ${analytics.primaryWorkhorse!.shoe.name}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            ...analytics.shoeProjections.map((p) {
              final share = p.rotationSharePercent;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ShoeDetailScreen(shoeId: p.shoe.id),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                _buildMiniThumbnail(p.shoe.photoUri),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    p.shoe.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${share.toStringAsFixed(1)}% (${UnitFormatter.formatDistance(p.currentMiles, unit)})',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: share > 0 ? (share / 100.0) : 0.0,
                          minHeight: 6,
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    RotationAnalytics analytics,
    DistanceUnit unit,
  ) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CATEGORY BREAKDOWN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: analytics.categoryMiles.entries.map((entry) {
                final catName = entry.key.toUpperCase();
                final miles = entry.value;
                final count = analytics.categoryCounts[entry.key] ?? 1;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        catName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        UnitFormatter.formatDistance(miles, unit),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '$count shoe${count > 1 ? "s" : ""}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectionsSection(
    BuildContext context,
    RotationAnalytics analytics,
    DistanceUnit unit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RETIREMENT PROJECTIONS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Forecasts calculated using your last 30 days wear rate',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...analytics.shoeProjections.map((p) {
          final color = _urgencyColor(p.urgency);
          final icon = _urgencyIcon(p.urgency);
          final ratio = p.targetMiles > 0 ? (p.currentMiles / p.targetMiles).clamp(0.0, 1.0) : 1.0;

          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: (p.urgency == RetirementUrgency.due || p.urgency == RetirementUrgency.retiringSoon)
                    ? color.withValues(alpha: 0.5)
                    : Colors.transparent,
                width: 1.2,
              ),
            ),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ShoeDetailScreen(shoeId: p.shoe.id),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Name and Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              _buildMiniThumbnail(p.shoe.photoUri),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.shoe.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (p.shoe.brand != null || p.shoe.model != null)
                                      Text(
                                        [p.shoe.brand, p.shoe.model].whereType<String>().join(' • '),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: color.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon, size: 12, color: color),
                              const SizedBox(width: 4),
                              Text(
                                p.urgencyLabel(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 8,
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Key metrics
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            context,
                            label: 'Remaining',
                            value: UnitFormatter.formatDistance(p.remainingMiles, unit),
                          ),
                        ),
                        Container(width: 1, height: 32, color: Theme.of(context).dividerColor),
                        Expanded(
                          child: _buildMetricTile(
                            context,
                            label: 'Wear Rate (30d)',
                            value: p.formattedWearRate(unit),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Forecast timeline row
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.event_outlined, size: 16, color: color),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              p.formattedTimeline(unit),
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniThumbnail(String? photoUri) {
    final hasPhoto = photoUri != null && photoUri.isNotEmpty && File(photoUri).existsSync();
    if (hasPhoto) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          File(photoUri),
          width: 28,
          height: 28,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.directions_run, size: 16, color: Colors.grey),
    );
  }
}
