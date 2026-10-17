import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/unit_formatter.dart';
import '../../../data/database/database.dart';
import '../../../data/providers.dart';

class ReassignShoeSheet extends ConsumerWidget {
  final Activity activity;
  final Shoe? currentShoe;

  const ReassignShoeSheet({
    super.key,
    required this.activity,
    this.currentShoe,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeShoesAsync = ref.watch(activeShoesProvider);
    final activeShoes = activeShoesAsync.asData?.value ?? [];
    final unit = ref.watch(unitPreferenceProvider);

    final dateStr = '${activity.startDate.month}/${activity.startDate.day}/${activity.startDate.year}';
    final durMinutes = (activity.duration / 60).floor();
    final durSeconds = (activity.duration % 60).round();
    final durationStr = "${durMinutes}m ${durSeconds}s";
    final paceStr = UnitFormatter.formatPace(activity.distance, activity.duration, unit);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reassign Workout',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Workout info header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${UnitFormatter.formatDistance(activity.distance, unit, decimals: 2)} • $dateStr',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      durationStr,
                      if (paceStr != '—') paceStr,
                      if (activity.source != null) activity.source,
                    ].join(' • '),
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (currentShoe != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Currently assigned to: ${currentShoe!.name}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'SELECT NEW SHOE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),

            if (activeShoes.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('No active shoes available in your Garage.'),
              )
            else
              ...activeShoes.map((shoe) {
                final isCurrent = shoe.id == activity.shoeId;
                return Card(
                  elevation: 0,
                  color: isCurrent
                      ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
                      : Theme.of(context).colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isCurrent
                        ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5)
                        : BorderSide.none,
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.directions_run,
                      color: isCurrent ? Theme.of(context).colorScheme.primary : Colors.grey,
                    ),
                    title: Text(
                      shoe.name,
                      style: TextStyle(
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                    subtitle: Text('${UnitFormatter.formatDistance(shoe.currentDistance, unit)} logged'),
                    trailing: isCurrent
                        ? Chip(
                            label: const Text('Current', style: TextStyle(fontSize: 11)),
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: isCurrent
                        ? null
                        : () async {
                            await ref.read(databaseProvider).reassignActivityShoe(
                                  activityId: activity.id,
                                  newShoeId: shoe.id,
                                );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Reassigned ${UnitFormatter.formatDistance(activity.distance, unit, decimals: 2)} to ${shoe.name}',
                                  ),
                                ),
                              );
                              Navigator.of(context).pop();
                            }
                          },
                  ),
                );
              }),

            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.inbox_outlined, color: Colors.orange),
              label: const Text(
                'Move to Inbox (Unassign)',
                style: TextStyle(color: Colors.orange),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.orange),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () async {
                await ref.read(databaseProvider).unassignActivity(activity.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Unassigned ${activity.distance.toStringAsFixed(2)} mi run and moved it to Inbox',
                      ),
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
