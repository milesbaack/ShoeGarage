import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/unit_formatter.dart';
import '../../../data/providers.dart';
import '../widgets/shoe_card_widget.dart';

class NursingHomeScreen extends ConsumerWidget {
  const NursingHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final retiredAsync = ref.watch(retiredShoesProvider);
    final unit = ref.watch(unitPreferenceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nursing Home',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: retiredAsync.when(
        data: (shoes) {
          if (shoes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.archive_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'The Nursing Home is Empty',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Retired shoes and their career stats are archived here.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: shoes.length,
            itemBuilder: (context, index) {
              final shoe = shoes[index];
              return ShoeCardWidget(
                shoe: shoe,
                onUnretire: (newTarget) async {
                  await ref.read(databaseProvider).unretireShoe(
                        shoeId: shoe.id,
                        newTargetDistance: newTarget,
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Un-retired ${shoe.name}! Moved back to Garage.')),
                    );
                  }
                },
                onAddMiles: (miles) async {
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
      ),
    );
  }
}
