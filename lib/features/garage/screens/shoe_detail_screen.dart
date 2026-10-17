import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/rotation_analytics_calculator.dart';
import '../../../core/utils/unit_formatter.dart';
import '../../../data/database/database.dart';
import '../../../data/providers.dart';
import '../widgets/edit_shoe_sheet.dart';

class ShoeDetailScreen extends ConsumerWidget {
  final String shoeId;

  const ShoeDetailScreen({super.key, required this.shoeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoeAsync = ref.watch(shoeByIdProvider(shoeId));
    final activitiesAsync = ref.watch(activitiesForShoeProvider(shoeId));
    final defaultShoeMap = ref.watch(defaultShoeMapProvider);
    final unit = ref.watch(unitPreferenceProvider);

    return shoeAsync.when(
      data: (shoe) {
        if (shoe == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Shoe Details')),
            body: const Center(child: Text('Shoe not found')),
          );
        }

        final activities = activitiesAsync.asData?.value ?? [];
        final defaultWorkoutTypes = defaultShoeMap.entries
            .where((e) => e.value == shoe.id)
            .map((e) => e.key)
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(
              shoe.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Shoe',
                onPressed: () => _openEditSheet(context, shoe),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (val) {
                  switch (val) {
                    case 'photo':
                      _handlePhotoAction(context, ref, shoe);
                      break;
                    case 'set_default':
                      _showSetDefaultSheet(context, ref, shoe);
                      break;
                    case 'add_miles':
                      _showAddMilesDialog(context, ref, shoe, unit);
                      break;
                    case 'set_price':
                      _showPriceDialog(context, ref, shoe);
                      break;
                    case 'retire':
                      _confirmRetirement(context, ref, shoe, unit);
                      break;
                    case 'unretire':
                      _showUnretireDialog(context, ref, shoe, unit);
                      break;
                    case 'delete':
                      _confirmDelete(context, ref, shoe);
                      break;
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'photo',
                    child: Row(
                      children: [
                        Icon(Icons.photo_camera_outlined, color: Colors.purple),
                        SizedBox(width: 8),
                        Expanded(child: Text('Shoe Photo')),
                      ],
                    ),
                  ),
                  if (!shoe.isRetired)
                    const PopupMenuItem(
                      value: 'set_default',
                      child: Row(
                        children: [
                          Icon(Icons.star_outline, color: Colors.amber),
                          SizedBox(width: 8),
                          Expanded(child: Text('Workout Defaults')),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'add_miles',
                    child: Row(
                      children: [
                        const Icon(Icons.add_road_outlined, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Add ${UnitFormatter.unitFullLabel(unit)}')),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'set_price',
                    child: Row(
                      children: [
                        Icon(Icons.attach_money, color: Colors.green),
                        SizedBox(width: 8),
                        Expanded(child: Text('Set / Edit Price')),
                      ],
                    ),
                  ),
                  if (!shoe.isRetired)
                    const PopupMenuItem(
                      value: 'retire',
                      child: Row(
                        children: [
                          Icon(Icons.archive_outlined, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(child: Text('Retire Shoe')),
                        ],
                      ),
                    )
                  else
                    const PopupMenuItem(
                      value: 'unretire',
                      child: Row(
                        children: [
                          Icon(Icons.unarchive_outlined, color: Colors.green),
                          SizedBox(width: 8),
                          Expanded(child: Text('Un-retire Shoe')),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Expanded(child: Text('Delete Shoe', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              _buildHeaderCard(context, ref, shoe, defaultWorkoutTypes),
              const SizedBox(height: 16),
              _buildProgressCard(context, shoe, unit),
              const SizedBox(height: 16),
              _buildRetirementProjectionCard(context, ref, shoe, unit),
              const SizedBox(height: 16),
              _buildCostPerMileCard(context, ref, shoe, unit),
              const SizedBox(height: 16),
              _buildCareerStatsCard(context, activities, unit),
              const SizedBox(height: 20),
              _buildWorkoutHistorySection(context, activities, unit),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    WidgetRef ref,
    Shoe shoe,
    List<String> defaultWorkoutTypes,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnail(context, ref, shoe),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shoe.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (shoe.brand != null && shoe.brand!.isNotEmpty) shoe.brand,
                      if (shoe.model != null && shoe.model!.isNotEmpty) shoe.model,
                    ].join(' • '),
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (shoe.category != null && shoe.category!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            shoe.category!.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: shoe.isRetired
                              ? Colors.brown.withValues(alpha: 0.15)
                              : Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          shoe.isRetired ? 'RETIRED' : 'ACTIVE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: shoe.isRetired ? Colors.brown : Colors.green.shade700,
                          ),
                        ),
                      ),
                      ...defaultWorkoutTypes.map(
                        (type) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade400, width: 0.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, size: 12, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                'DEFAULT (${type.toUpperCase()})',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, WidgetRef ref, Shoe shoe) {
    final hasPhoto = shoe.photoUri != null && shoe.photoUri!.isNotEmpty && File(shoe.photoUri!).existsSync();

    return InkWell(
      onTap: () => _handlePhotoAction(context, ref, shoe),
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (hasPhoto)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(shoe.photoUri!),
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.directions_run,
                size: 38,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 2,
                ),
              ),
              child: Icon(
                hasPhoto ? Icons.edit : Icons.add_a_photo,
                size: 11,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, Shoe shoe, DistanceUnit unit) {
    final ratio = shoe.targetDistance > 0 ? (shoe.currentDistance / shoe.targetDistance).clamp(0.0, 1.0) : 1.0;
    final percent = (ratio * 100).toInt();

    Color color;
    if (ratio >= 0.90) {
      color = Colors.red;
    } else if (ratio >= 0.75) {
      color = Colors.orange;
    } else {
      color = const Color(0xFF4CAF50);
    }

    final remainingCanonical = (shoe.targetDistance - shoe.currentDistance).clamp(0.0, double.infinity);

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
              children: [
                Icon(Icons.battery_charging_full, size: 20, color: color),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'LIFESPAN & BATTERY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Text(
                  '$percent%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 12,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${UnitFormatter.formatDistance(shoe.currentDistance, unit, includeUnit: false)} / ${UnitFormatter.formatTarget(shoe.targetDistance, unit)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                Text(
                  shoe.isRetired
                      ? 'Archived'
                      : '${UnitFormatter.formatDistance(remainingCanonical, unit)} remaining',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetirementProjectionCard(
    BuildContext context,
    WidgetRef ref,
    Shoe shoe,
    DistanceUnit unit,
  ) {
    if (shoe.isRetired) {
      return const SizedBox.shrink();
    }

    final projection = ref.watch(shoeProjectionProvider(shoe.id));
    if (projection == null) {
      return const SizedBox.shrink();
    }

    Color color;
    IconData icon;
    switch (projection.urgency) {
      case RetirementUrgency.due:
        color = Colors.red;
        icon = Icons.error_outline;
        break;
      case RetirementUrgency.retiringSoon:
        color = Colors.deepOrange;
        icon = Icons.warning_amber_rounded;
        break;
      case RetirementUrgency.approaching:
        color = Colors.amber.shade800;
        icon = Icons.timelapse;
        break;
      case RetirementUrgency.healthy:
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case RetirementUrgency.idle:
        color = Colors.blueGrey;
        icon = Icons.bedtime_outlined;
        break;
    }

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: (projection.urgency == RetirementUrgency.due || projection.urgency == RetirementUrgency.retiringSoon)
              ? color.withValues(alpha: 0.5)
              : Colors.transparent,
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, size: 20, color: color),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'RETIREMENT PROJECTION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                        projection.urgencyLabel(),
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
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        projection.formattedWearRate(unit),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Recent wear rate (30 days)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 38, color: Theme.of(context).dividerColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${projection.rotationSharePercent.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Rotation share',
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
            const SizedBox(height: 12),
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
                      projection.formattedTimeline(unit),
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
    );
  }

  Widget _buildCostPerMileCard(BuildContext context, WidgetRef ref, Shoe shoe, DistanceUnit unit) {
    final hasPrice = shoe.price != null && shoe.price! > 0;
    final costString = UnitFormatter.formatCostPerUnit(shoe.price, shoe.currentDistance, unit);

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
              children: [
                const Icon(Icons.monetization_on_outlined, size: 20, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'COST PER ${UnitFormatter.unitPerLabel(unit).toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: Colors.grey,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _showPriceDialog(context, ref, shoe),
                  child: Text(hasPrice ? 'Edit Price' : 'Set Price'),
                ),
              ],
            ),
            if (hasPrice) ...[
              const SizedBox(height: 4),
              Text(
                costString,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${shoe.price!.toStringAsFixed(2)} purchase price across ${UnitFormatter.formatDistance(shoe.currentDistance, unit)} logged',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                'Track what you paid for this pair to evaluate wear value over time.',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCareerStatsCard(BuildContext context, List<Activity> activities, DistanceUnit unit) {
    final count = activities.length;
    double maxDistance = 0.0;
    double totalDistance = 0.0;
    double totalSeconds = 0.0;

    for (final act in activities) {
      if (act.distance > maxDistance) {
        maxDistance = act.distance;
      }
      totalDistance += act.distance;
      totalSeconds += act.duration;
    }

    final avgPaceStr = UnitFormatter.formatPace(totalDistance, totalSeconds, unit);

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            Expanded(child: _buildStatItem(context, count.toString(), 'Assigned Runs', Icons.format_list_numbered)),
            Container(width: 1, height: 36, color: Theme.of(context).dividerColor),
            Expanded(child: _buildStatItem(context, UnitFormatter.formatDistance(maxDistance, unit), 'Longest Run', Icons.flag_outlined)),
            Container(width: 1, height: 36, color: Theme.of(context).dividerColor),
            Expanded(child: _buildStatItem(context, avgPaceStr, 'Avg Pace', Icons.speed)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildWorkoutHistorySection(BuildContext context, List<Activity> activities, DistanceUnit unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'WORKOUT HISTORY (${activities.length})',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: Colors.grey,
            ),
          ),
        ),
        if (activities.isEmpty)
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No workouts have been assigned to this shoe yet.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          )
        else
          ...activities.map((act) => _buildWorkoutCard(context, act, unit)),
      ],
    );
  }

  Widget _buildWorkoutCard(BuildContext context, Activity act, DistanceUnit unit) {
    final dateStr = '${act.startDate.month}/${act.startDate.day}/${act.startDate.year}';
    final durMinutes = (act.duration / 60).floor();
    final durSeconds = (act.duration % 60).round();
    final durationStr = "${durMinutes}m ${durSeconds}s";
    final paceStr = UnitFormatter.formatPace(act.distance, act.duration, unit);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.directions_run, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          UnitFormatter.formatDistance(act.distance, unit, decimals: 2),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          [
            dateStr,
            durationStr,
            if (paceStr != '—') paceStr,
            if (act.source != null && act.source!.isNotEmpty) act.source,
          ].join(' • '),
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  void _openEditSheet(BuildContext context, Shoe shoe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => EditShoeSheet(shoe: shoe),
    );
  }

  void _showPriceDialog(BuildContext context, WidgetRef ref, Shoe shoe) {
    final controller = TextEditingController(
      text: shoe.price != null ? shoe.price!.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '') : '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Purchase Price for ${shoe.name}'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Price',
              prefixText: '\$ ',
              hintText: 'e.g. 160.00',
              border: OutlineInputBorder(),
              helperText: 'Used to track your real-time cost per mile',
            ),
            validator: (val) {
              if (val != null && val.trim().isNotEmpty) {
                final p = double.tryParse(val.trim());
                if (p == null || p < 0) {
                  return 'Please enter a valid price';
                }
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final text = controller.text.trim();
                final price = text.isEmpty ? null : double.tryParse(text);
                await ref.read(databaseProvider).updateShoePrice(
                      shoeId: shoe.id,
                      price: price,
                    );
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddMilesDialog(BuildContext context, WidgetRef ref, Shoe shoe, DistanceUnit unit) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final currentInUnit = UnitFormatter.toDisplayDistance(shoe.currentDistance, unit);
    final presets = unit == DistanceUnit.miles
        ? [1.0, 3.1, 5.0, 10.0, 13.1]
        : [1.0, 5.0, 10.0, 15.0, 21.1];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          final addedVal = double.tryParse(controller.text) ?? 0.0;
          final newTotal = currentInUnit + addedVal;

          return AlertDialog(
            title: Text('Add ${UnitFormatter.unitFullLabel(unit)} to ${shoe.name}'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Distance: ${UnitFormatter.formatDistance(shoe.currentDistance, unit)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: '${UnitFormatter.unitFullLabel(unit)} to Add',
                      hintText: unit == DistanceUnit.miles ? 'e.g. 5.0' : 'e.g. 8.0',
                      border: const OutlineInputBorder(),
                      suffixText: UnitFormatter.unitLabel(unit),
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (val) {
                      final parsed = double.tryParse(val ?? '');
                      if (parsed == null || parsed <= 0) {
                        return 'Please enter a valid distance (> 0)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: presets.map((preset) {
                      return ActionChip(
                        label: Text('+$preset ${UnitFormatter.unitLabel(unit)}'),
                        onPressed: () {
                          setState(() {
                            controller.text = preset.toString();
                          });
                        },
                      );
                    }).toList(),
                  ),
                  if (addedVal > 0) ...[
                    const SizedBox(height: 12),
                    Text(
                      'New Total: ${newTotal.toStringAsFixed(1)} ${UnitFormatter.unitLabel(unit)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final entered = double.parse(controller.text);
                    final canonicalMiles = UnitFormatter.toCanonicalMiles(entered, unit);
                    Navigator.of(ctx).pop();
                    await ref.read(databaseProvider).addMilesToShoe(
                          shoeId: shoe.id,
                          additionalMiles: canonicalMiles,
                        );
                  }
                },
                child: Text('Add ${UnitFormatter.unitFullLabel(unit)}'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showUnretireDialog(BuildContext context, WidgetRef ref, Shoe shoe, DistanceUnit unit) {
    final currentInUnit = UnitFormatter.toDisplayDistance(shoe.currentDistance, unit);
    final extraSuggested = unit == DistanceUnit.miles ? 100.0 : 160.0;
    final suggested = (currentInUnit + extraSuggested).roundToDouble();
    final controller = TextEditingController(text: suggested.toStringAsFixed(0));
    final formKey = GlobalKey<FormState>();
    final presets = unit == DistanceUnit.miles ? [50.0, 100.0, 200.0] : [80.0, 150.0, 300.0];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Un-retire ${shoe.name}?'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Moving this shoe back to your active garage rotation. It currently has logged ${UnitFormatter.formatDistance(shoe.currentDistance, unit)}.',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'New Target Lifespan (${UnitFormatter.unitLabel(unit)})',
                      border: const OutlineInputBorder(),
                      suffixText: UnitFormatter.unitLabel(unit),
                    ),
                    validator: (val) {
                      final parsed = double.tryParse(val ?? '');
                      if (parsed == null || parsed <= currentInUnit) {
                        return 'Must be greater than ${currentInUnit.toStringAsFixed(1)} ${UnitFormatter.unitLabel(unit)}';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: presets.map((extra) {
                      final val = (currentInUnit + extra).roundToDouble();
                      return ActionChip(
                        label: Text('+$extra ${UnitFormatter.unitLabel(unit)} (${val.toInt()} ${UnitFormatter.unitLabel(unit)})'),
                        onPressed: () {
                          setState(() {
                            controller.text = val.toStringAsFixed(0);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final enteredTarget = double.parse(controller.text);
                    final canonicalTargetMiles = UnitFormatter.toCanonicalMiles(enteredTarget, unit);
                    Navigator.of(ctx).pop();
                    await ref.read(databaseProvider).unretireShoe(
                          shoeId: shoe.id,
                          newTargetDistance: canonicalTargetMiles,
                        );
                  }
                },
                child: const Text('Un-retire Shoe'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmRetirement(BuildContext context, WidgetRef ref, Shoe shoe, DistanceUnit unit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Retire Shoe?'),
        content: Text(
          'Retiring "${shoe.name}" will move it out of your active rotation into the Nursing Home. Its lifespan target will snap to its current mileage (${UnitFormatter.formatDistance(shoe.currentDistance, unit)}).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(databaseProvider).retireShoe(shoe.id);
            },
            child: const Text('Retire Shoe'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Shoe shoe) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${shoe.name}?'),
        content: Text(
          'Are you sure you want to delete "${shoe.name}"? Any past workouts assigned to this shoe will become unassigned. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(databaseProvider).deleteShoe(shoe.id);
              if (context.mounted) {
                Navigator.of(context).pop(); // Exit detail screen
              }
            },
            child: const Text('Delete Shoe'),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePhotoAction(BuildContext context, WidgetRef ref, Shoe shoe) async {
    final hasPhoto = shoe.photoUri != null && File(shoe.photoUri!).existsSync();

    final action = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Shoe Photo',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (hasPhoto)
              ListTile(
                leading: const Icon(Icons.fullscreen),
                title: const Text('View Full Screen'),
                onTap: () => Navigator.of(ctx).pop('view'),
              ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(hasPhoto ? 'Take New Photo' : 'Take Photo'),
              onTap: () => Navigator.of(ctx).pop('camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Library'),
              onTap: () => Navigator.of(ctx).pop('gallery'),
            ),
            if (hasPhoto) ...[
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.of(ctx).pop('remove'),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (action == null || !context.mounted) return;

    if (action == 'view') {
      _showFullScreenPhoto(context, shoe.photoUri!);
      return;
    }

    final photoService = ref.read(shoePhotoServiceProvider);
    final db = ref.read(databaseProvider);

    if (action == 'remove') {
      await photoService.deleteShoePhoto(shoe.photoUri);
      await db.updateShoePhoto(shoeId: shoe.id, photoUri: null);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo removed')),
        );
      }
      return;
    }

    final source = action == 'camera' ? ImageSource.camera : ImageSource.gallery;
    final picked = await photoService.pickImage(source: source);
    if (picked != null && context.mounted) {
      final savedUri = await photoService.saveShoePhoto(sourcePath: picked, shoeId: shoe.id);
      if (shoe.photoUri != null && shoe.photoUri != savedUri) {
        await photoService.deleteShoePhoto(shoe.photoUri);
      }
      await db.updateShoePhoto(shoeId: shoe.id, photoUri: savedUri);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shoe photo updated')),
        );
      }
    }
  }

  void _showFullScreenPhoto(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                child: Image.file(
                  File(path),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            IconButton.filled(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _showSetDefaultSheet(BuildContext context, WidgetRef ref, Shoe shoe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Consumer(
          builder: (context, ref, _) {
            final defaultMap = ref.watch(defaultShoeMapProvider);
            final workoutConfigs = [
              ('running', 'Running', Icons.directions_run),
              ('walking', 'Walking', Icons.directions_walk),
              ('hiking', 'Hiking / Trail', Icons.hiking),
              ('other', 'Other Workouts', Icons.fitness_center),
            ];

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
                              'Default for Workouts',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Text(
                        'Automatically assign new workouts to ${shoe.brand} ${shoe.model} by activity type.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Divider(height: 24),
                    ...workoutConfigs.map((config) {
                      final type = config.$1;
                      final title = config.$2;
                      final icon = config.$3;
                      final isCurrentDefault = defaultMap[type] == shoe.id;

                      return SwitchListTile(
                        secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
                        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          isCurrentDefault
                              ? 'Default shoe for $title'
                              : (defaultMap[type] != null
                                  ? 'Currently assigned to another shoe'
                                  : 'No default assigned'),
                          style: TextStyle(
                            fontSize: 12,
                            color: isCurrentDefault
                                ? Colors.green.shade700
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        value: isCurrentDefault,
                        onChanged: (val) async {
                          await ref.read(databaseProvider).setWorkoutDefault(
                                workoutType: type,
                                shoeId: val ? shoe.id : null,
                              );
                        },
                      );
                    }),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
