import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_haptics.dart';
import '../../../core/widgets/pressable_scale.dart';
import '../../../data/providers.dart';
// import '../../settings/widgets/tip_jar_sheet.dart'; // Uncomment when re-enabling Tip Jar

class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;

  const OnboardingScreen({super.key, this.onComplete});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const int _totalPages = 5;

  Future<void> _completeOnboarding() async {
    AppHaptics.heavy();
    final db = ref.read(databaseProvider);
    await db.setSetting(AppConstants.onboardingCompletedKey, 'true');
    if (widget.onComplete != null) {
      widget.onComplete!();
    } else if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _nextPage() {
    AppHaptics.selection();
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _openReview() async {
    AppHaptics.selection();
    final uri = Uri.parse(AppConstants.websiteUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening Shoe Garage page...')),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Progress & Skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Indicators
                  Row(
                    children: List.generate(_totalPages, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 6),
                        width: isActive ? 22 : 6,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.volt
                              : AppColors.border(context),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  if (_currentPage < _totalPages - 1)
                    TextButton(
                      onPressed: () {
                        AppHaptics.light();
                        _pageController.animateToPage(
                          _totalPages - 1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                        );
                      },
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 48),
                ],
              ),
            ),

            // Main Carousel
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildSlide(
                    context,
                    stepBadge: '01 / 05 • SHOE MILEAGE',
                    icon: Icons.directions_run,
                    iconColor: AppColors.volt,
                    title: 'Track Shoes, Not Runs.',
                    subtitle: 'Your shoes’ automated odometer',
                    description:
                        'Apple Health tracks your workout. Shoe Garage automatically logs those miles onto your shoes.',
                    bullets: const [
                      'Auto-syncs miles from Apple Health',
                      '1-tap shoe assign from lock screen',
                    ],
                  ),
                  _buildSlide(
                    context,
                    stepBadge: '02 / 05 • ZERO SERVERS',
                    icon: Icons.shield_outlined,
                    iconColor: AppColors.cyanPulse,
                    title: 'Zero Servers. Pure Privacy.',
                    subtitle: 'Your data stays on your iPhone',
                    description:
                        'We literally have no servers. Everything stays on your device and Apple Health.',
                    bullets: const [
                      '100% offline local database',
                      'No accounts, tracking, or ads',
                    ],
                  ),
                  _buildSlide(
                    context,
                    stepBadge: '03 / 05 • INJURY PREVENTION',
                    icon: Icons.health_and_safety_outlined,
                    iconColor: AppColors.hyperOrange,
                    title: 'Never Run on Dead Shoes.',
                    subtitle: 'Protect your joints & tendons',
                    description:
                        'Cushioning breaks down long before shoes look worn. Live fuel gauges warn you before injury strikes.',
                    bullets: const [
                      'Visual mileage fuel gauges',
                      'Cost-per-mile & rotation forecasts',
                    ],
                  ),
                  _buildStorySlide(context),
                  _buildMakerNoteSlide(context),
                ],
              ),
            ),

            // Bottom Navigation CTA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: _currentPage < _totalPages - 1
                  ? PressableScale(
                      onTap: _nextPage,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: AppColors.volt,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.volt.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.black, size: 20),
                          ],
                        ),
                      ),
                    )
                  : PressableScale(
                      onTap: _completeOnboarding,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.volt, AppColors.hyperOrange],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.volt.withValues(alpha: 0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Let’s Run • Enter Your Garage',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.check, color: Colors.black, size: 20),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(
    BuildContext context, {
    required String stepBadge,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String description,
    required List<String> bullets,
  }) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          // Step pill badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: iconColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              stepBadge,
              style: TextStyle(
                color: iconColor,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Glowing circular icon hero
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cardElevated(context),
              border: Border.all(color: iconColor.withValues(alpha: 0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.25),
                  blurRadius: 32,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 42),
          ),
          const SizedBox(height: 28),

          // Title & Subtitle
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 14),

          // Paragraph description
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // Bullet Cards
          ...bullets.map((bullet) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cardElevated(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: iconColor, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      bullet,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStorySlide(BuildContext context) {
    final theme = Theme.of(context);
    const accentColor = AppColors.amber;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentColor.withValues(alpha: 0.3)),
            ),
            child: const Text(
              '04 / 05 • THE ORIGIN STORY',
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 28),

          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cardElevated(context),
              border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.25),
                  blurRadius: 32,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.terrain, color: accentColor, size: 42),
          ),
          const SizedBox(height: 28),

          const Text(
            'Born from Injury.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'An ultra runner’s wake-up call',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 14),

          Text(
            'As an ultra runner, training on dead shoes caused a severe injury that benched me.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardElevated(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.sentiment_dissatisfied, color: accentColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Running was my mental outlet. Losing it led to depression. I built Shoe Garage to keep you healthy and running.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMakerNoteSlide(BuildContext context) {
    final theme = Theme.of(context);
    const accentColor = Color(0xFFFFDD00);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentColor.withValues(alpha: 0.3)),
            ),
            child: const Text(
              '05 / 05 • BUILT FOR RUNNERS',
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 24),

          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cardElevated(context),
              border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.25),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.favorite, color: accentColor, size: 38),
          ),
          const SizedBox(height: 20),

          const Text(
            'Free Forever. No Paywalls.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Zero subscriptions • Just indie craft',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'Shoe Garage is 100% free. If it helps you stay healthy, leaving a review gives me runway to build more free tools for everyone.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Support Actions: Review Button (Tip Jar commented out for initial submission)
          Row(
            children: [
              /*
              // NOTE: In-App Purchases / Tip Jar temporarily commented out for initial App Store submission.
              // To re-enable: uncomment this block and the Leave a Tip tile in SettingsScreen.
              Expanded(
                child: PressableScale(
                  onTap: () {
                    AppHaptics.selection();
                    TipJarSheet.show(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.coffee, color: accentColor, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Tip Jar ☕',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              */
              Expanded(
                child: PressableScale(
                  onTap: _openReview,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: AppColors.cardElevated(context),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border(context)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Leave an App Store Review ★★★★★',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
