import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/primary_button.dart';
import '../../providers/app_providers.dart';

class _OnboardSlide {
  const _OnboardSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

const _slides = <_OnboardSlide>[
  _OnboardSlide(
    title: AppStrings.onboardTitle1,
    subtitle: AppStrings.onboardSubtitle1,
    icon: Icons.smart_toy,
    color: AppColors.primary,
  ),
  _OnboardSlide(
    title: AppStrings.onboardTitle2,
    subtitle: AppStrings.onboardSubtitle2,
    icon: Icons.wb_sunny,
    color: AppColors.accent,
  ),
  _OnboardSlide(
    title: AppStrings.onboardTitle3,
    subtitle: AppStrings.onboardSubtitle3,
    icon: Icons.storefront,
    color: AppColors.primary,
  ),
  _OnboardSlide(
    title: AppStrings.onboardTitle4,
    subtitle: AppStrings.onboardSubtitle4,
    icon: Icons.account_balance_wallet,
    color: AppColors.accent,
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  void _next() async {
    if (_index < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } else {
      await _markVisited();
      if (mounted) context.go('/profile-setup');
    }
  }

  Future<void> _markVisited() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    ref.invalidate(onboardingCompleteProvider);
  }

  void _skip() async {
    await _markVisited();
    if (mounted) context.go('/profile-setup');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 8),
                child: TextButton(
                  onPressed: _skip,
                  child: const Text(AppStrings.skip),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) {
                  final s = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: s.color.withValues(alpha: 0.12),
                          ),
                          child: Icon(s.icon, size: 88, color: s.color),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          s.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          s.subtitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            _Indicator(active: _index, count: _slides.length),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: PrimaryButton(
                onPressed: _next,
                label: _index == _slides.length - 1
                    ? AppStrings.getStarted
                    : AppStrings.continue_,
                fullWidth: true,
                icon: _index == _slides.length - 1
                    ? Icons.arrow_forward
                    : Icons.arrow_forward,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({required this.active, required this.count});
  final int active;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 10,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.black12,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}
