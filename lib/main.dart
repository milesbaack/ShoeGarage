import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_haptics.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/unit_formatter.dart';
import 'core/widgets/floating_frosted_dock.dart';
import 'core/widgets/pressable_scale.dart';
import 'data/database/database.dart';
import 'data/providers.dart';
import 'features/activities/screens/activities_screen.dart';
import 'features/garage/screens/nursing_home_screen.dart';
import 'features/garage/screens/rotation_analytics_screen.dart';
import 'features/garage/widgets/add_shoe_sheet.dart';
import 'features/garage/widgets/shoe_card_widget.dart';
import 'features/settings/screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: ShoeGarageApp(),
    ),
  );
}

class ShoeGarageApp extends StatelessWidget {
  const ShoeGarageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shoe Garage',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to Performance Studio OLED Dark
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // User returned to app or unlocked phone: drain pending assignments queue
      ref.read(assignmentQueueProcessorProvider).processQueue();
    }
  }

  Future<void> _initApp() async {
    // 1. Drain pending queue
    await ref.read(assignmentQueueProcessorProvider).processQueue();

    // 2. Request Health permissions
    final healthKitService = ref.read(healthKitServiceProvider);
    final healthAvailable = await healthKitService.isHealthDataAvailable();
    if (healthAvailable) {
      await healthKitService.requestAuthorization();
    }

    // 3. Request Notification permissions
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.requestPermissions();

    // 4. Initial 30-Day HealthKit sync (unassigned runs route to Inbox, notifications suppressed)
    if (healthAvailable) {
      await ref.read(historicalSyncServiceProvider).syncLast30Days();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeShoesAsync = ref.watch(activeShoesProvider);
    final retiredShoesAsync = ref.watch(retiredShoesProvider);
    final unassignedAsync = ref.watch(unassignedActivitiesProvider);
    final unassignedCount = unassignedAsync.asData?.value.length ?? 0;
    final retiredShoes = retiredShoesAsync.asData?.value ?? [];
    final unit = ref.watch(unitPreferenceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Keep active shoes in sync with App Group UserDefaults and notification buttons
    ref.listen(activeShoesProvider, (prev, next) {
      next.whenData((shoes) {
        ref.read(appGroupServiceProvider).syncActiveShoes(shoes);
        ref.read(notificationServiceProvider).updateCategories();
      });
    });

    // Keep distance unit in sync with App Group UserDefaults
    ref.listen(distanceUnitSettingProvider, (prev, next) {
      next.whenData((unitVal) {
        if (unitVal != null) {
          ref.read(appGroupServiceProvider).syncDistanceUnit(unitVal);
        }
      });
    });

    final defaultShoeMap = ref.watch(defaultShoeMapProvider);

    final screens = [
      _buildGarageTab(activeShoesAsync, retiredShoesAsync, defaultShoeMap, unit, isDark),
      const ActivitiesScreen(),
      const SettingsScreen(),
    ];

    final titles = ['Shoe Garage', 'Activities', 'Settings'];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(
          titles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        actions: [
          if (_currentIndex == 0) ...[
            IconButton(
              icon: const Icon(Icons.insights_outlined),
              tooltip: 'Rotation Analytics',
              onPressed: () {
                AppHaptics.light();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RotationAnalyticsScreen()),
                );
              },
            ),
            IconButton(
              icon: retiredShoes.isNotEmpty
                  ? Badge.count(
                      count: retiredShoes.length,
                      backgroundColor: AppColors.hyperOrange,
                      textColor: Colors.white,
                      child: const Icon(Icons.archive_outlined),
                    )
                  : const Icon(Icons.archive_outlined),
              tooltip: 'Nursing Home',
              onPressed: () {
                AppHaptics.light();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NursingHomeScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Shoe',
              onPressed: () {
                AppHaptics.light();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (_) => const AddShoeSheet(),
                );
              },
            ),
          ] else if (_currentIndex == 1) ...[
            IconButton(
              icon: const Icon(Icons.sync),
              tooltip: 'Import Last 30 Days',
              onPressed: () async {
                AppHaptics.light();
                final result = await ref.read(historicalSyncServiceProvider).syncLast30Days();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Imported ${result.insertedCount} workouts into Inbox')),
                  );
                }
              },
            ),
          ],
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: FloatingFrostedDock(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          const DockDestination(
            icon: Icons.directions_run_outlined,
            selectedIcon: Icons.directions_run,
            label: 'Garage',
          ),
          DockDestination(
            icon: Icons.history_outlined,
            selectedIcon: Icons.history,
            label: 'Activities',
            badgeCount: unassignedCount,
          ),
          const DockDestination(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildGarageTab(
    AsyncValue<List<Shoe>> activeShoesAsync,
    AsyncValue<List<Shoe>> retiredShoesAsync,
    Map<String, String?> defaultShoeMap,
    DistanceUnit unit,
    bool isDark,
  ) {
    return activeShoesAsync.when(
      data: (shoes) {
        final retiredShoes = retiredShoesAsync.asData?.value ?? [];

        if (shoes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
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
                    child: Center(
                      child: Icon(
                        Icons.directions_run,
                        size: 42,
                        color: isDark ? AppColors.volt : AppColors.hyperOrange,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your Garage is Empty',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your active shoe rotation.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  PressableScale(
                    onTap: () {
                      AppHaptics.light();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (_) => const AddShoeSheet(),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.volt : AppColors.hyperOrange,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark ? AppColors.volt : AppColors.hyperOrange).withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add,
                            size: 18,
                            color: isDark ? Colors.black : Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Add First Pair',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.black : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (retiredShoes.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    TextButton.icon(
                      icon: const Icon(Icons.archive_outlined, size: 18),
                      label: Text('View Nursing Home (${retiredShoes.length} shoes)'),
                      onPressed: () {
                        AppHaptics.light();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const NursingHomeScreen()),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        final hasRetiredFooter = retiredShoes.isNotEmpty;
        final totalCount = shoes.length + 1 + (hasRetiredFooter ? 1 : 0);
        final totalFleetDistance = shoes.fold<double>(0.0, (sum, s) => sum + s.currentDistance);

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
          itemCount: totalCount,
          itemBuilder: (context, index) {
            // Header 0: Telemetry summary bar
            if (index == 0) {
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.volt : AppColors.hyperOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ACTIVE ROTATION (${shoes.length})',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${UnitFormatter.formatDistance(totalFleetDistance, unit)} FLEET',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: isDark ? AppColors.volt : AppColors.hyperOrange,
                      ),
                    ),
                  ],
                ),
              );
            }

            final shoeIndex = index - 1;
            if (shoeIndex == shoes.length) {
              return PressableScale(
                onTap: () {
                  AppHaptics.light();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NursingHomeScreen()),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 4, bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.archive_outlined, color: AppColors.hyperOrange, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nursing Home',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${retiredShoes.length} retired shoes resting here',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ],
                  ),
                ),
              );
            }

            final shoe = shoes[shoeIndex];
            final defaultsForThisShoe = defaultShoeMap.entries
                .where((e) => e.value == shoe.id)
                .map((e) => e.key)
                .toList();

            return ShoeCardWidget(
              shoe: shoe,
              defaultForWorkoutTypes: defaultsForThisShoe,
              onRetire: () async {
                AppHaptics.medium();
                await ref.read(databaseProvider).retireShoe(shoe.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Retired ${shoe.name}')),
                  );
                }
              },
              onAddMiles: (miles) async {
                AppHaptics.medium();
                await ref.read(databaseProvider).addMilesToShoe(
                      shoeId: shoe.id,
                      additionalMiles: miles,
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added ${UnitFormatter.formatDistance(miles, unit)} to ${shoe.name}')),
                  );
                }
              },
              onDelete: () async {
                AppHaptics.light();
                await ref.read(databaseProvider).deleteShoe(shoe.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deleted ${shoe.name}')),
                  );
                }
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
