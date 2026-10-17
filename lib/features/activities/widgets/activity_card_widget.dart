import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_haptics.dart';
import '../../../core/utils/unit_formatter.dart';
import '../../../data/database/database.dart';
import '../../../data/providers.dart';

class ActivityCardWidget extends ConsumerWidget {
  final Activity activity;
  final List<Shoe> activeShoes;
  final ValueChanged<String> onAssignShoe;
  final String? defaultShoeId;

  const ActivityCardWidget({
    super.key,
    required this.activity,
    required this.activeShoes,
    required this.onAssignShoe,
    this.defaultShoeId,
  });

  String _formatDuration(double durationSeconds) {
    final totalSeconds = durationSeconds.round();
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    } else {
      return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, ${date.year} • $hour:$minute $ampm';
  }

  IconData _workoutIcon(String type) {
    switch (type.toLowerCase()) {
      case 'walking':
        return Icons.directions_walk;
      case 'hiking':
        return Icons.hiking;
      default:
        return Icons.directions_run;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(unitPreferenceProvider);
    final formattedDistance = UnitFormatter.formatDistance(activity.distance, unit, decimals: 2);
    final pace = UnitFormatter.formatPace(activity.distance, activity.duration, unit);
    final formattedDuration = _formatDuration(activity.duration);
    final formattedDate = _formatDate(activity.startDate);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultShoe = defaultShoeId != null
        ? activeShoes.where((s) => s.id == defaultShoeId).firstOrNull
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Row: Type, Date, Source Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          width: 0.8,
                        ),
                      ),
                      child: Icon(
                        _workoutIcon(activity.workoutType),
                        size: 22,
                        color: isDark ? AppColors.volt : AppColors.hyperOrange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.workoutType.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 0.6,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (activity.source != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCardHighlight : AppColors.lightCardHighlight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? const Color(0x22FFFFFF) : const Color(0x11000000),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      activity.source!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),

            // Metrics Telemetry Strip: Distance, Duration, Avg Pace
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricColumn(
                    context,
                    label: 'DISTANCE',
                    value: formattedDistance,
                    icon: Icons.straighten,
                    valueColor: isDark ? AppColors.volt : AppColors.hyperOrange,
                    isDark: isDark,
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                  _buildMetricColumn(
                    context,
                    label: 'DURATION',
                    value: formattedDuration,
                    icon: Icons.timer_outlined,
                    isDark: isDark,
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                  _buildMetricColumn(
                    context,
                    label: 'AVG PACE',
                    value: pace,
                    icon: Icons.speed,
                    valueColor: AppColors.cyanPulse,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (defaultShoe != null) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.star, size: 18),
                  label: Text(
                    'Assign to Default (${defaultShoe.name})',
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: isDark ? AppColors.volt : AppColors.hyperOrange,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  onPressed: () {
                    AppHaptics.medium();
                    onAssignShoe(defaultShoe.id);
                  },
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'OR CHOOSE ANOTHER SHOE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
              const SizedBox(height: 10),
            ] else ...[
              Text(
                'ASSIGN TO SHOE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: isDark ? AppColors.volt : AppColors.hyperOrange,
                ),
              ),
              const SizedBox(height: 10),
            ],

            if (activeShoes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No active shoes in your Garage. Add a shoe to assign mileage.',
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              )
            else
              Builder(
                builder: (context) {
                  final sortedShoes = List<Shoe>.from(activeShoes);
                  if (defaultShoeId != null) {
                    sortedShoes.sort((a, b) {
                      if (a.id == defaultShoeId) return -1;
                      if (b.id == defaultShoeId) return 1;
                      return 0;
                    });
                  }

                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: sortedShoes.map((shoe) {
                      final isDefault = shoe.id == defaultShoeId;
                      return ActionChip(
                        avatar: Icon(
                          isDefault ? Icons.star : Icons.check_circle_outline,
                          size: 16,
                          color: isDefault ? Colors.amber : (isDark ? AppColors.volt : AppColors.hyperOrange),
                        ),
                        backgroundColor: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
                        side: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          width: 0.8,
                        ),
                        label: Text(
                          isDefault ? '${shoe.name} ★' : shoe.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        onPressed: () {
                          AppHaptics.medium();
                          onAssignShoe(shoe.id);
                        },
                      );
                    }).toList(),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
    required bool isDark,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: valueColor ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
        ),
      ],
    );
  }
}
