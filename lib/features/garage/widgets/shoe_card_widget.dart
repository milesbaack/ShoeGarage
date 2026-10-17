import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_haptics.dart';
import '../../../core/utils/unit_formatter.dart';
import '../../../core/widgets/pressable_scale.dart';
import '../../../data/database/database.dart';
import '../../../data/providers.dart';
import '../screens/shoe_detail_screen.dart';
import 'edit_shoe_sheet.dart';

class ShoeCardWidget extends ConsumerWidget {
  final Shoe shoe;
  final VoidCallback? onRetire;
  final void Function(double newTargetDistance)? onUnretire;
  final void Function(double additionalMiles)? onAddMiles;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final List<String>? defaultForWorkoutTypes;

  const ShoeCardWidget({
    super.key,
    required this.shoe,
    this.onRetire,
    this.onUnretire,
    this.onAddMiles,
    this.onEdit,
    this.onDelete,
    this.onTap,
    this.defaultForWorkoutTypes,
  });

  /// Computes the ratio of current distance to target distance.
  double get progressRatio {
    if (shoe.targetDistance <= 0) return 1.0;
    return (shoe.currentDistance / shoe.targetDistance).clamp(0.0, 1.0);
  }

  /// Determines the indicator color based on lifespan completion:
  /// - >= 90%: Warning / Error Red
  /// - >= 75%: Caution Orange
  /// - < 75%: Healthy Green
  Color get progressColor {
    if (progressRatio >= 0.90) {
      return Colors.red;
    } else if (progressRatio >= 0.75) {
      return Colors.orange;
    } else {
      return const Color(0xFF4CAF50);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(unitPreferenceProvider);
    final percent = (progressRatio * 100).toInt();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final remainingMiles = (shoe.targetDistance - shoe.currentDistance).clamp(0.0, double.infinity);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: PressableScale(
        onTap: onTap ??
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ShoeDetailScreen(shoeId: shoe.id),
                ),
              );
            },
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Thumbnail, Name, Brand/Model, Badges, and Overflow Menu
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShoeThumbnail(context, isDark),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shoe.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            [
                              if (shoe.brand != null && shoe.brand!.isNotEmpty) shoe.brand,
                              if (shoe.model != null && shoe.model!.isNotEmpty) shoe.model,
                            ].join(' • '),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              if (shoe.category != null && shoe.category!.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.darkCardHighlight
                                        : AppColors.lightCardHighlight,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isDark ? const Color(0x22FFFFFF) : const Color(0x11000000),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    shoe.category!.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.4,
                                      color: isDark ? AppColors.volt : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                ),
                              if (defaultForWorkoutTypes != null)
                                ...defaultForWorkoutTypes!.map(
                                  (type) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.amber.withValues(alpha: 0.4), width: 0.5),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star, size: 10, color: Colors.amber),
                                        const SizedBox(width: 4),
                                        Text(
                                          'DEFAULT (${type.toUpperCase()})',
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.3,
                                            color: Colors.amber,
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
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_horiz,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      onSelected: (value) {
                        AppHaptics.light();
                        switch (value) {
                          case 'add_miles':
                            _showAddMilesDialog(context, unit);
                            break;
                          case 'edit':
                            _openEditSheet(context);
                            break;
                          case 'retire':
                            _confirmRetirement(context, unit);
                            break;
                          case 'unretire':
                            _showUnretireDialog(context, unit);
                            break;
                          case 'delete':
                            _confirmDelete(context);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        if (!shoe.isRetired) ...[
                          PopupMenuItem(
                            value: 'add_miles',
                            child: Row(
                              children: [
                                const Icon(Icons.add_road_outlined, color: AppColors.cyanPulse, size: 20),
                                const SizedBox(width: 10),
                                Text('Add ${UnitFormatter.unitFullLabel(unit)}'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 20),
                                SizedBox(width: 10),
                                Text('Edit Shoe'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'retire',
                            child: Row(
                              children: [
                                Icon(Icons.archive_outlined, color: AppColors.amber, size: 20),
                                SizedBox(width: 10),
                                Text('Retire Shoe'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: AppColors.crimson, size: 20),
                                SizedBox(width: 10),
                                Text('Delete Shoe', style: TextStyle(color: AppColors.crimson)),
                              ],
                            ),
                          ),
                        ] else ...[
                          const PopupMenuItem(
                            value: 'unretire',
                            child: Row(
                              children: [
                                Icon(Icons.unarchive_outlined, color: Color(0xFF4CAF50), size: 20),
                                SizedBox(width: 10),
                                Text('Un-retire Shoe'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 20),
                                SizedBox(width: 10),
                                Text('Edit Shoe'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: AppColors.crimson, size: 20),
                                SizedBox(width: 10),
                                Text('Delete Shoe', style: TextStyle(color: AppColors.crimson)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Mileage & Battery Progress Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.battery_charging_full,
                                size: 16,
                                color: progressColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${UnitFormatter.formatDistance(shoe.currentDistance, unit, includeUnit: false)} / ${UnitFormatter.formatTarget(shoe.targetDistance, unit)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  letterSpacing: -0.2,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              if (!shoe.isRetired) ...[
                                Text(
                                  '${UnitFormatter.formatDistance(remainingMiles, unit)} left',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                '$percent%',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: progressColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Linear Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          key: ValueKey('shoe_progress_bar_${shoe.id}'),
                          value: progressRatio,
                          minHeight: 8,
                          backgroundColor: isDark ? const Color(0xFF232734) : const Color(0xFFE2E6F0),
                          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                        ),
                      ),
                    ],
                  ),
                ),

                if (shoe.isRetired && shoe.retiredAt != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Retired on ${shoe.retiredAt!.month}/${shoe.retiredAt!.day}/${shoe.retiredAt!.year}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShoeThumbnail(BuildContext context, bool isDark) {
    if (shoe.photoUri != null && shoe.photoUri!.isNotEmpty) {
      final file = File(shoe.photoUri!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 0.8,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Image.file(
              file,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
        );
      }
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.8,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.directions_run,
          size: 28,
          color: isDark ? AppColors.volt : AppColors.hyperOrange,
        ),
      ),
    );
  }

  void _confirmRetirement(BuildContext context, DistanceUnit unit) {
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
            onPressed: () {
              Navigator.of(ctx).pop();
              onRetire?.call();
            },
            child: const Text('Retire Shoe'),
          ),
        ],
      ),
    );
  }

  void _showAddMilesDialog(BuildContext context, DistanceUnit unit) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final currentInUnit = UnitFormatter.toDisplayDistance(shoe.currentDistance, unit);
    final presets = unit == DistanceUnit.miles
        ? [1.0, 3.1, 5.0, 10.0, 13.1]
        : [1.0, 5.0, 10.0, 15.0, 21.1];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
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
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final entered = double.parse(controller.text);
                      final canonicalMiles = UnitFormatter.toCanonicalMiles(entered, unit);
                      Navigator.of(ctx).pop();
                      onAddMiles?.call(canonicalMiles);
                    }
                  },
                  child: Text('Add ${UnitFormatter.unitFullLabel(unit)}'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showUnretireDialog(BuildContext context, DistanceUnit unit) {
    final currentInUnit = UnitFormatter.toDisplayDistance(shoe.currentDistance, unit);
    final extraSuggested = unit == DistanceUnit.miles ? 100.0 : 160.0;
    final suggested = (currentInUnit + extraSuggested).roundToDouble();
    final controller = TextEditingController(text: suggested.toStringAsFixed(0));
    final formKey = GlobalKey<FormState>();
    final presets = unit == DistanceUnit.miles ? [50.0, 100.0, 200.0] : [80.0, 150.0, 300.0];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
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
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final enteredTarget = double.parse(controller.text);
                      final canonicalTargetMiles = UnitFormatter.toCanonicalMiles(enteredTarget, unit);
                      Navigator.of(ctx).pop();
                      onUnretire?.call(canonicalTargetMiles);
                    }
                  },
                  child: const Text('Un-retire Shoe'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${shoe.name}?'),
        content: Text(
          'Are you sure you want to delete "${shoe.name}"? Any workouts assigned to this shoe will become unassigned. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(ctx).pop();
              onDelete?.call();
            },
            child: const Text('Delete Shoe'),
          ),
        ],
      ),
    );
  }

  void _openEditSheet(BuildContext context) {
    if (onEdit != null) {
      onEdit!();
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => EditShoeSheet(shoe: shoe),
      );
    }
  }
}

