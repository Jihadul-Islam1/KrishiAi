import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_divider.dart';
import '../../../core/widgets/icon_badge.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/states.dart';
import '../../../data/models/farm.dart';
import '../../../data/models/farmer.dart';
import '../../providers/app_providers.dart';

const _kProfileHeader = ScreenHeader(
  eyebrow: AppStrings.profileEyebrow,
  title: AppStrings.profileTitle,
  leadingIcon: Icons.person_rounded,
  gradient: [AppColors.weatherCard, AppColors.fieldCard],
);

/// Profile tab. Shows the current farmer, summary stats (land size, farms,
/// crops), and routes into the secondary settings/management screens.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  double? _totalLandAcres(List<Farm>? farms) {
    if (farms == null) return null;
    double sum = 0;
    for (final f in farms) {
      sum += f.sizeAcres;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farmerAsync = ref.watch(currentFarmerProvider);
    final farmsAsync = ref.watch(farmsProvider);
    final cropsAsync = ref.watch(cropsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _kProfileHeader,
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(currentFarmerProvider);
                ref.invalidate(farmsProvider);
                ref.invalidate(cropsProvider);
                await Future.wait([
                  ref.read(currentFarmerProvider.future),
                  ref.read(farmsProvider.future),
                  ref.read(cropsProvider.future),
                ]);
              },
              color: AppColors.primary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.huge,
                ),
                children: [
                  farmerAsync.when(
                    loading: () => const _ProfileCardSkeleton(),
                    error: (e, _) => ErrorStateView(
                      message:
                          '${AppStrings.profileLoadFailedPrefix}: $e',
                      onRetry: () => ref.invalidate(currentFarmerProvider),
                    ),
                    data: (farmer) => _ProfileCard(farmer: farmer),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SummaryStrip(
                    farms: (farmsAsync.valueOrNull as List?)?.length,
                    crops: (cropsAsync.valueOrNull as List?)?.length,
                    landAcres: _totalLandAcres(farmsAsync.valueOrNull) ??
                        farmerAsync.valueOrNull?.farmSizeAcres ??
                        0,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const SectionHeader(
                    eyebrow: 'ACCOUNT',
                    title: AppStrings.profileAccount,
                    subtitle: AppStrings.profileAccountSubtitle,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    padding: EdgeInsets.zero,
                    elevation: AppElevation.card,
                    child: Column(
                      children: [
                        _NavRow(
                          icon: Icons.person_outline_rounded,
                          tint: AppColors.tintGreen,
                          color: AppColors.primary,
                          title: AppStrings.settingsEditProfile,
                          subtitle: farmerAsync.valueOrNull?.name ??
                              AppStrings.profileUnknownName,
                          onTap: () => context.push('/profile/edit'),
                        ),
                        const AppDivider(),
                        _NavRow(
                          icon: Icons.notifications_outlined,
                          tint: AppColors.tintAmber,
                          color: AppColors.accentDark,
                          title: AppStrings.notifications,
                          subtitle: AppStrings.profileNotificationsSubtitle,
                          onTap: () => context.push('/notifications'),
                        ),
                        const AppDivider(),
                        _NavRow(
                          icon: Icons.workspace_premium_outlined,
                          tint: AppColors.tintBlue,
                          color: AppColors.info,
                          title: AppStrings.settingsSubscription,
                          subtitle: AppStrings.profileSubscriptionSubtitle,
                          onTap: () => context.push('/subscription'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const SectionHeader(
                    eyebrow: 'SUPPORT',
                    title: AppStrings.profileHelpLabel,
                    subtitle: AppStrings.profileHelpSubtitle,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    padding: EdgeInsets.zero,
                    elevation: AppElevation.card,
                    child: Column(
                      children: [
                        _NavRow(
                          icon: Icons.help_outline_rounded,
                          tint: AppColors.tintGreen,
                          color: AppColors.primary,
                          title: AppStrings.settingsHelp,
                          subtitle: AppStrings.profileFaqSubtitle,
                          onTap: () => context.push('/help'),
                        ),
                        const AppDivider(),
                        _NavRow(
                          icon: Icons.privacy_tip_outlined,
                          tint: AppColors.tintSlate,
                          color: AppColors.textSecondary,
                          title: AppStrings.settingsPrivacy,
                          subtitle: AppStrings.profilePrivacySubtitle,
                          onTap: () => context.push('/privacy'),
                        ),
                        const AppDivider(),
                        _NavRow(
                          icon: Icons.info_outline_rounded,
                          tint: AppColors.tintBlue,
                          color: AppColors.info,
                          title: AppStrings.settingsAbout,
                          subtitle: AppStrings.profileAboutSubtitle,
                          onTap: () => context.push('/about'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _LogoutCard(
                    onLogout: () => _confirmLogout(context, ref),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: Text(
                      AppStrings.profileAppFooter,
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.profileConfirmTitle),
        content: const Text(AppStrings.profileConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.profileCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(AppStrings.profileConfirmLogout),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final repo = await ref.read(farmerRepoProvider.future);
      await repo.clear();
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.remove('onboarding_complete');
      ref.invalidate(currentFarmerProvider);
      ref.invalidate(farmsProvider);
      ref.invalidate(cropsProvider);
      ref.invalidate(onboardingCompleteProvider);
      if (context.mounted) context.go('/onboarding');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppStrings.profileLogoutFailedPrefix}: $e',
            ),
          ),
        );
      }
    }
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Profile identity card
// ────────────────────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.farmer});
  final Farmer? farmer;

  @override
  Widget build(BuildContext context) {
    final name = farmer?.name ?? AppStrings.profileUnknownName;
    final district = farmer?.district ?? '';
    final upazila = farmer?.upazila ?? '';
    final location = [upazila, district]
        .where((s) => s.isNotEmpty)
        .join(', ');
    final initials = _initialsFor(name);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      color: AppColors.primaryContainer.withValues(alpha: 0.6),
      borderColor: AppColors.primary.withValues(alpha: 0.15),
      elevation: AppElevation.card,
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.textOnDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.h2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (location.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Expanded(
                        child: Text(
                          location,
                          style: AppTextStyles.bodySecondary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                if (farmer != null)
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      AppChip(
                        label: farmer!.mainCrop.isEmpty
                            ? AppStrings.profileCropNone
                            : '${AppStrings.profileCropPrefix}: ${farmer!.mainCrop}',
                        icon: Icons.agriculture_outlined,
                        tint: AppColors.tintGreen,
                        color: AppColors.primary,
                      ),
                      AppChip(
                        label:
                            '${AppStrings.profileExperiencePrefix} ${farmer!.experienceYears} ${AppStrings.profileExperienceUnit}',
                        icon: Icons.timeline_rounded,
                        tint: AppColors.tintAmber,
                        color: AppColors.accentDark,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initialsFor(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'ক';
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}

class _ProfileCardSkeleton extends StatelessWidget {
  const _ProfileCardSkeleton();
  @override
  Widget build(BuildContext context) {
    return const AppCard(
      padding: EdgeInsets.all(AppSpacing.xl),
      elevation: AppElevation.card,
      child: SizedBox(
        height: 96,
        child: Center(child: LoadingState()),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Summary stats strip
// ────────────────────────────────────────────────────────────────────────────

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({
    required this.farms,
    required this.crops,
    required this.landAcres,
  });

  final int? farms;
  final int? crops;
  final double landAcres;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      elevation: AppElevation.card,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              icon: Icons.landscape_outlined,
              tint: AppColors.tintGreen,
              color: AppColors.primary,
              value: landAcres > 0
                  ? landAcres.toStringAsFixed(1)
                  : '—',
              unit: AppStrings.profileLandUnit,
              label: AppStrings.profileLandLabel,
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.divider),
          Expanded(
            child: _SummaryItem(
              icon: Icons.home_work_outlined,
              tint: AppColors.tintAmber,
              color: AppColors.accentDark,
              value: farms?.toString() ?? '—',
              unit: AppStrings.profileFarmsUnit,
              label: AppStrings.profileFarmsLabel,
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.divider),
          Expanded(
            child: _SummaryItem(
              icon: Icons.eco_outlined,
              tint: AppColors.tintBlue,
              color: AppColors.info,
              value: crops?.toString() ?? '—',
              unit: AppStrings.profileCropsUnit,
              label: AppStrings.profileCropsLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.tint,
    required this.color,
    required this.value,
    required this.unit,
    required this.label,
  });

  final IconData icon;
  final Color tint;
  final Color color;
  final String value;
  final String unit;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconBadge(
          icon: icon,
          tint: tint,
          color: color,
          size: 40,
          iconSize: 20,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(value, style: AppTextStyles.stat),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Generic nav row used by the menu cards
// ────────────────────────────────────────────────────────────────────────────

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.tint,
    required this.color,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color tint;
  final Color color;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            IconBadge(
              icon: icon,
              tint: tint,
              color: color,
              size: 40,
              iconSize: 20,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.title),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Logout card
// ────────────────────────────────────────────────────────────────────────────

class _LogoutCard extends StatelessWidget {
  const _LogoutCard({required this.onLogout});
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      borderColor: AppColors.danger.withValues(alpha: 0.25),
      elevation: AppElevation.card,
      child: Row(
        children: [
          IconBadge(
            icon: Icons.logout_rounded,
            tint: AppColors.tintRed,
            color: AppColors.danger,
            size: 40,
            iconSize: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.profileLogout,
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.profileLogoutSubtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onLogout,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.danger,
            ),
            child: const Text(AppStrings.profileConfirmLogout),
          ),
        ],
      ),
    );
  }
}
