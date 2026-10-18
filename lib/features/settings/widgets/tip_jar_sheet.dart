import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_haptics.dart';
import '../../../core/widgets/pressable_scale.dart';
import '../../../data/providers.dart';
import '../../../data/services/tip_jar_service.dart';

class TipJarSheet extends ConsumerStatefulWidget {
  const TipJarSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TipJarSheet(),
    );
  }

  @override
  ConsumerState<TipJarSheet> createState() => _TipJarSheetState();
}

class _TipJarSheetState extends ConsumerState<TipJarSheet> {
  String? _purchasingId;

  @override
  Widget build(BuildContext context) {
    final tipService = ref.watch(tipJarServiceProvider);
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: tipService,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.border(context)),
          ),
          padding: EdgeInsets.only(
            top: 16,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).padding.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header icon & title
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFDD00).withValues(alpha: 0.15),
                  border: Border.all(color: const Color(0xFFFFDD00).withValues(alpha: 0.4)),
                ),
                child: const Icon(Icons.favorite, color: Color(0xFFFFDD00), size: 28),
              ),
              const SizedBox(height: 12),
              const Text(
                'Indie Tip Jar',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Shoe Garage is 100% free, private, and ad-free.\nTips directly support continuous updates & new features.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Success banner
              if (tipService.purchaseSuccess)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.volt.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.volt.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.volt, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Thank you so much for fueling Shoe Garage! 🏃‍♂️⚡',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.volt,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Error banner
              if (tipService.lastError != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.crimson.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.crimson.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.crimson, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tipService.lastError!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.crimson,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Tip Options
              ...TipJarService.fallbackTiers.map((tier) {
                final liveProduct = tipService.products.cast().where(
                      (p) => p.id == tier.id,
                    ).firstOrNull;
                final displayPrice = liveProduct?.price ?? tier.priceString;
                final isPurchasing = _purchasingId == tier.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: PressableScale(
                    onTap: isPurchasing
                        ? null
                        : () async {
                            AppHaptics.selection();
                            setState(() => _purchasingId = tier.id);
                            try {
                              await tipService.buyTip(tier.id);
                            } finally {
                              if (mounted) {
                                setState(() => _purchasingId = null);
                              }
                            }
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.cardElevated(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isPurchasing
                              ? AppColors.volt
                              : AppColors.border(context),
                          width: isPurchasing ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.card(context),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              tier.emoji,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tier.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  tier.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.volt.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.volt.withValues(alpha: 0.5),
                              ),
                            ),
                            child: isPurchasing
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.volt,
                                    ),
                                  )
                                : Text(
                                    displayPrice,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: AppColors.volt,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 8),
              Text(
                'Tips are processed securely via Apple StoreKit In-App Purchase.\nNo subscription or recurring charges.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
