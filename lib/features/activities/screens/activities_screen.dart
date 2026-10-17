import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_haptics.dart';
import '../../../data/database/database.dart';
import '../../../data/providers.dart';
import '../widgets/assigned_activity_card.dart';
import '../widgets/unassigned_run_carousel.dart';

class ActivitiesScreen extends ConsumerStatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  ConsumerState<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends ConsumerState<ActivitiesScreen> {
  int _selectedSegment = 0;

  @override
  Widget build(BuildContext context) {
    final unassignedAsync = ref.watch(unassignedActivitiesProvider);
    final assignedAsync = ref.watch(assignedActivitiesProvider);
    final activeShoesAsync = ref.watch(activeShoesProvider);
    final retiredShoesAsync = ref.watch(retiredShoesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final unassigned = unassignedAsync.asData?.value ?? [];
    final assigned = assignedAsync.asData?.value ?? [];
    final activeShoes = activeShoesAsync.asData?.value ?? [];
    final retiredShoes = retiredShoesAsync.asData?.value ?? [];

    // Map of all shoes to resolve shoe names for assigned workouts
    final allShoesMap = <String, Shoe>{
      for (final s in [...activeShoes, ...retiredShoes]) s.id: s,
    };

    return Column(
      children: [
        // Top Segmented Bar: Inbox vs History
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment<int>(
                  value: 0,
                  icon: const Icon(Icons.inbox_outlined),
                  label: Text('Inbox (${unassigned.length})'),
                ),
                ButtonSegment<int>(
                  value: 1,
                  icon: const Icon(Icons.history),
                  label: Text('History (${assigned.length})'),
                ),
              ],
              selected: {_selectedSegment},
              onSelectionChanged: (newSelection) {
                AppHaptics.selection();
                setState(() {
                  _selectedSegment = newSelection.first;
                });
              },
            ),
          ),
        ),

        // Body content based on segment
        Expanded(
          child: _selectedSegment == 0
              ? unassignedAsync.when(
                  data: (activities) => UnassignedRunCarousel(
                    activities: activities,
                    activeShoes: activeShoes,
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                )
              : assignedAsync.when(
                  data: (activities) {
                    if (activities.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  Icons.history,
                                  size: 42,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'No Assigned Workouts',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Assigned runs from your Inbox will appear here.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final activity = activities[index];
                        final shoe = activity.shoeId != null ? allShoesMap[activity.shoeId!] : null;
                        return AssignedActivityCard(
                          activity: activity,
                          assignedShoe: shoe,
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
        ),
      ],
    );
  }
}
