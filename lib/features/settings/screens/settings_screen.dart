import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/unit_formatter.dart';
import '../../../data/database/database.dart';
import '../../../data/providers.dart';
import '../../garage/screens/rotation_analytics_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final bool showAppBar;

  const SettingsScreen({super.key, this.showAppBar = false});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isSyncing = false;

  Future<void> _triggerHistoricalSync() async {
    setState(() => _isSyncing = true);
    try {
      final result = await ref.read(historicalSyncServiceProvider).syncLast30Days();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sync Complete: Imported ${result.insertedCount} workouts into Inbox (${result.discardedCount} duplicates skipped)',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  Future<void> _requestNotificationPermissions() async {
    final granted = await ref.read(notificationServiceProvider).requestPermissions();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            granted ? 'Notification permissions granted!' : 'Notification permissions were not granted.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeShoesAsync = ref.watch(activeShoesProvider);
    final retiredShoesAsync = ref.watch(retiredShoesProvider);
    final defaultShoeMap = ref.watch(defaultShoeMapProvider);
    final unit = ref.watch(unitPreferenceProvider);

    final activeShoes = activeShoesAsync.asData?.value ?? [];
    final retiredShoes = retiredShoesAsync.asData?.value ?? [];

    final totalActiveMiles = activeShoes.fold<double>(0.0, (acc, s) => acc + s.currentDistance);
    final totalRetiredMiles = retiredShoes.fold<double>(0.0, (acc, s) => acc + s.currentDistance);
    final totalMiles = totalActiveMiles + totalRetiredMiles;

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Statistics Summary Card
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GARAGE STATS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                        context,
                        count: activeShoes.length.toString(),
                        label: 'Active Shoes',
                        icon: Icons.directions_run,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Container(width: 1, height: 40, color: Theme.of(context).dividerColor),
                      _buildStatColumn(
                        context,
                        count: retiredShoes.length.toString(),
                        label: 'Retired Shoes',
                        icon: Icons.archive_outlined,
                        color: Colors.brown,
                      ),
                      Container(width: 1, height: 40, color: Theme.of(context).dividerColor),
                      _buildStatColumn(
                        context,
                        count: UnitFormatter.formatDistance(totalMiles, unit, decimals: 1, includeUnit: false),
                        label: 'Total ${UnitFormatter.unitFullLabel(unit)}',
                        icon: Icons.speed,
                        color: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RotationAnalyticsScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Row(
                        children: [
                          Icon(Icons.insights, size: 18, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Rotation Analytics & Projections',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                            ),
                          ),
                          Icon(Icons.chevron_right, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Units & Display Section
          _buildSectionHeader('UNITS & DISPLAY'),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.straighten, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Distance Unit',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Display distance and pace in ${UnitFormatter.unitFullLabel(unit).toLowerCase()}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<DistanceUnit>(
                      segments: const [
                        ButtonSegment(
                          value: DistanceUnit.miles,
                          label: Text('Miles (mi)'),
                          icon: Icon(Icons.speed, size: 18),
                        ),
                        ButtonSegment(
                          value: DistanceUnit.kilometers,
                          label: Text('Kilometers (km)'),
                          icon: Icon(Icons.straighten, size: 18),
                        ),
                      ],
                      selected: {unit},
                      onSelectionChanged: (newSelection) async {
                        final selected = newSelection.first;
                        final serialized = UnitFormatter.serializeUnit(selected);
                        await ref.read(databaseProvider).setSetting('distance_unit', serialized);
                        await ref.read(appGroupServiceProvider).syncDistanceUnit(serialized);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Default Workout Shoes Section
          _buildSectionHeader('DEFAULT WORKOUT SHOES'),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _buildDefaultShoeTile(
                  context,
                  workoutType: 'running',
                  title: 'Running',
                  icon: Icons.directions_run,
                  defaultShoeId: defaultShoeMap['running'],
                  activeShoes: activeShoes,
                  unit: unit,
                ),
                const Divider(height: 1),
                _buildDefaultShoeTile(
                  context,
                  workoutType: 'walking',
                  title: 'Walking',
                  icon: Icons.directions_walk,
                  defaultShoeId: defaultShoeMap['walking'],
                  activeShoes: activeShoes,
                  unit: unit,
                ),
                const Divider(height: 1),
                _buildDefaultShoeTile(
                  context,
                  workoutType: 'hiking',
                  title: 'Hiking / Trail',
                  icon: Icons.hiking,
                  defaultShoeId: defaultShoeMap['hiking'],
                  activeShoes: activeShoes,
                  unit: unit,
                ),
                const Divider(height: 1),
                _buildDefaultShoeTile(
                  context,
                  workoutType: 'other',
                  title: 'Other Workouts',
                  icon: Icons.fitness_center,
                  defaultShoeId: defaultShoeMap['other'],
                  activeShoes: activeShoes,
                  unit: unit,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // HealthKit Integration Section
          _buildSectionHeader('HEALTHKIT & WORKOUT SYNC'),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.redAccent),
                  title: const Text('Apple Health Integration'),
                  subtitle: const Text('Background workout delivery active'),
                  trailing: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.sync, color: Colors.blue),
                  title: const Text('Import Last 30 Days'),
                  subtitle: const Text('Fetch recent runs & walks into Inbox'),
                  trailing: _isSyncing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : OutlinedButton(
                          onPressed: _triggerHistoricalSync,
                          child: const Text('Sync Now'),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Notifications Section
          _buildSectionHeader('LOCK SCREEN & NOTIFICATIONS'),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_active, color: Colors.orange),
                  title: const Text('Interactive Notifications'),
                  subtitle: const Text('Quick-assign shoe buttons on lock screen & Apple Watch'),
                  trailing: OutlinedButton(
                    onPressed: _requestNotificationPermissions,
                    child: const Text('Permissions'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // App Group & Diagnostics Section
          _buildSectionHeader('STORAGE & ABOUT'),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.share, color: Colors.teal),
                  title: const Text('App Group Container'),
                  subtitle: const Text('group.com.shoegarage.shared'),
                  trailing: Text(
                    '${activeShoes.length} synced',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.info_outline, color: Colors.blueGrey),
                  title: Text('Shoe Garage'),
                  subtitle: Text('Version 1.0.0 (Build 1) • Offline-First Drift SQLite'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    BuildContext context, {
    required String count,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          count,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
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

  Widget _buildDefaultShoeTile(
    BuildContext context, {
    required String workoutType,
    required String title,
    required IconData icon,
    required String? defaultShoeId,
    required List<Shoe> activeShoes,
    required DistanceUnit unit,
  }) {
    final assignedShoe = defaultShoeId != null
        ? activeShoes.cast<Shoe?>().firstWhere(
            (s) => s?.id == defaultShoeId,
            orElse: () => null,
          )
        : null;

    final shoeName = assignedShoe != null
        ? assignedShoe.name
        : 'None (manual selection)';

    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        shoeName,
        style: TextStyle(
          color: assignedShoe != null
              ? Theme.of(context).colorScheme.onSurface
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (assignedShoe != null)
            const Padding(
              padding: EdgeInsets.only(right: 6),
              child: Icon(Icons.star, color: Colors.amber, size: 18),
            ),
          const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        ],
      ),
      onTap: () => _showDefaultShoePicker(
        context,
        workoutType: workoutType,
        workoutTitle: title,
        currentShoeId: defaultShoeId,
        activeShoes: activeShoes,
        unit: unit,
      ),
    );
  }

  void _showDefaultShoePicker(
    BuildContext context, {
    required String workoutType,
    required String workoutTitle,
    required String? currentShoeId,
    required List<Shoe> activeShoes,
    required DistanceUnit unit,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Default Shoe for $workoutTitle',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Text(
                    'Workouts imported as $workoutTitle will automatically suggest this shoe for 1-tap logging.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const Divider(height: 24),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.black12,
                    child: Icon(Icons.close, color: Colors.grey),
                  ),
                  title: const Text('None (Manual assignment)'),
                  trailing: currentShoeId == null
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () async {
                    await ref.read(databaseProvider).setWorkoutDefault(
                          workoutType: workoutType,
                          shoeId: null,
                        );
                    if (bottomSheetContext.mounted) {
                      Navigator.pop(bottomSheetContext);
                    }
                  },
                ),
                if (activeShoes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text('No active shoes in your garage yet.'),
                    ),
                  )
                else
                  ...activeShoes.map((shoe) {
                    final isSelected = shoe.id == currentShoeId;
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.directions_run),
                      ),
                      title: Text(shoe.name),
                      subtitle: Text(
                        [
                          if (shoe.brand != null && shoe.brand!.isNotEmpty) shoe.brand,
                          if (shoe.model != null && shoe.model!.isNotEmpty) shoe.model,
                          '${UnitFormatter.formatDistance(shoe.currentDistance, unit, includeUnit: false)} / ${UnitFormatter.formatTarget(shoe.targetDistance, unit)}',
                        ].join(' • '),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                      onTap: () async {
                        await ref.read(databaseProvider).setWorkoutDefault(
                              workoutType: workoutType,
                              shoeId: shoe.id,
                            );
                        if (bottomSheetContext.mounted) {
                          Navigator.pop(bottomSheetContext);
                        }
                      },
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}
