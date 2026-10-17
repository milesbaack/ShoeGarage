import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_haptics.dart';

class DockDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int badgeCount;

  const DockDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badgeCount = 0,
  });
}

/// A floating, frosted glass navigation dock inspired by iOS 17/18 and Apple Design Award winners.
class FloatingFrostedDock extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<DockDestination> destinations;

  const FloatingFrostedDock({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(18, 0, 18, bottomPadding > 0 ? bottomPadding : 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xE0131620) : const Color(0xEAFFFFFF),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark ? const Color(0x33FFFFFF) : const Color(0x1F000000),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(destinations.length, (index) {
                final dest = destinations[index];
                final isSelected = index == selectedIndex;

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (!isSelected) {
                        AppHaptics.selection();
                        onDestinationSelected(index);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? AppColors.volt.withValues(alpha: 0.16) : AppColors.hyperOrange.withValues(alpha: 0.12))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected
                            ? Border.all(
                                color: isDark
                                    ? AppColors.volt.withValues(alpha: 0.35)
                                    : AppColors.hyperOrange.withValues(alpha: 0.30),
                                width: 0.8,
                              )
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                isSelected ? dest.selectedIcon : dest.icon,
                                size: 22,
                                color: isSelected
                                    ? (isDark ? AppColors.volt : AppColors.hyperOrange)
                                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                              ),
                              if (dest.badgeCount > 0)
                                Positioned(
                                  right: -6,
                                  top: -3,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.crimson,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            dest.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              letterSpacing: -0.2,
                              color: isSelected
                                  ? (isDark ? AppColors.volt : AppColors.hyperOrange)
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
