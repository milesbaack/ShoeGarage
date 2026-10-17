import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_haptics.dart';
import '../../../core/utils/unit_formatter.dart';
import '../../../data/database/database.dart';
import '../../../data/providers.dart';
import 'reassign_shoe_sheet.dart';

class AssignedActivityCard extends ConsumerWidget {
  final Activity activity;
  final Shoe? assignedShoe;

  const AssignedActivityCard({
    super.key,
    required this.activity,
    this.assignedShoe,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(unitPreferenceProvider);
    final dateStr = '${activity.startDate.month}/${activity.startDate.day}/${activity.startDate.year}';
    final durMinutes = (activity.duration / 60).floor();
    final durSeconds = (activity.duration % 60).round();
    final durationStr = "${durMinutes}m ${durSeconds}s";
    final formattedDistance = UnitFormatter.formatDistance(activity.distance, unit, decimals: 2);
    final paceStr = UnitFormatter.formatPace(activity.distance, activity.duration, unit);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Date, workout type & Source
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCardHighlight : AppColors.lightCardHighlight,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDark ? const Color(0x22FFFFFF) : const Color(0x11000000),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        activity.workoutType.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          color: isDark ? AppColors.volt : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (activity.source != null && activity.source!.isNotEmpty)
                  Text(
                    activity.source!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Middle: Metrics Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDistance,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: isDark ? AppColors.volt : AppColors.hyperOrange,
                        ),
                      ),
                      Text(
                        'Distance',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        durationStr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        'Duration',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (paceStr != '—')
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          paceStr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.cyanPulse,
                          ),
                        ),
                        Text(
                          'Pace',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(
              height: 1,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            const SizedBox(height: 10),

            // Bottom: Assigned Shoe & Reassign Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.directions_run,
                        size: 18,
                        color: isDark ? AppColors.volt : AppColors.hyperOrange,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          assignedShoe != null ? assignedShoe!.name : 'Assigned Shoe',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.swap_horiz, size: 16),
                  label: const Text('Reassign', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    visualDensity: VisualDensity.compact,
                    foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    side: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  onPressed: () {
                    AppHaptics.light();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (_) => ReassignShoeSheet(
                        activity: activity,
                        currentShoe: assignedShoe,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
