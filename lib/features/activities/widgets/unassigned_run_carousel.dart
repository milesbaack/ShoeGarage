import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_haptics.dart';
import '../../../data/database/database.dart';
import '../../../data/providers.dart';
import 'activity_card_widget.dart';

class UnassignedRunCarousel extends ConsumerStatefulWidget {
  final List<Activity> activities;
  final List<Shoe> activeShoes;

  const UnassignedRunCarousel({
    super.key,
    required this.activities,
    required this.activeShoes,
  });

  @override
  ConsumerState<UnassignedRunCarousel> createState() => _UnassignedRunCarouselState();
}

class _UnassignedRunCarouselState extends ConsumerState<UnassignedRunCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _assignActivity(Activity activity, String shoeId) async {
    final db = ref.read(databaseProvider);
    final targetShoe = widget.activeShoes.where((s) => s.id == shoeId).firstOrNull;

    await db.assignActivityToShoe(
      activityId: activity.id,
      shoeId: shoeId,
    );

    AppHaptics.medium();

    if (mounted) {
      final shoeName = targetShoe?.name ?? 'shoe';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Assigned ${activity.distance.toStringAsFixed(2)} mi to $shoeName!'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultShoeMap = ref.watch(defaultShoeMapProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.activities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.done_all,
                    size: 48,
                    color: isDark ? AppColors.volt : AppColors.hyperOrange,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'All Caught Up! 🎉',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'All your runs have been assigned to shoes in your Garage. Completed runs from Apple Health will arrive here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final totalRuns = widget.activities.length;
    // Keep page index within bounds
    final pageIndex = _currentPage.clamp(0, totalRuns - 1);

    return Column(
      children: [
        // Top Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Unassigned Inbox ($totalRuns)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              Text(
                'Run ${pageIndex + 1} of $totalRuns',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Carousel of Run Cards
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: totalRuns,
            onPageChanged: (idx) {
              AppHaptics.selection();
              setState(() => _currentPage = idx);
            },
            itemBuilder: (context, index) {
              final activity = widget.activities[index];
              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 90),
                child: ActivityCardWidget(
                  activity: activity,
                  activeShoes: widget.activeShoes,
                  defaultShoeId: defaultShoeMap[activity.workoutType],
                  onAssignShoe: (shoeId) => _assignActivity(activity, shoeId),
                ),
              );
            },
          ),
        ),

        // Bottom Page Indicators
        if (totalRuns > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 96, top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                totalRuns.clamp(1, 10), // Show up to 10 dot indicators
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: index == pageIndex ? 20 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: index == pageIndex
                        ? (isDark ? AppColors.volt : AppColors.hyperOrange)
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
