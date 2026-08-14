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
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/states.dart';
import '../../../data/models/crop.dart';
import '../../../data/models/farm.dart';
import '../../providers/app_providers.dart';

class MyFarmScreen extends ConsumerWidget {
  const MyFarmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farmsAsync = ref.watch(farmsProvider);
    final cropsAsync = ref.watch(cropsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: farmsAsync.when(
        loading: () => const _LoadingShell(),
        error: (e, _) => Scaffold(
          body: ErrorStateView(
            message: e.toString(),
            onRetry: () => ref.invalidate(farmsProvider),
          ),
        ),
        data: (farms) {
          final crops = cropsAsync.maybeWhen(
            data: (c) => c,
            orElse: () => <Crop>[],
          );
          if (farms.isEmpty) {
            return _EmptyFarmBody(
              onAdd: () => context.push('/farm/add'),
            );
          }
          return _FarmBody(
            farms: farms,
            crops: crops,
            onRefresh: () async => ref.invalidate(farmsProvider),
          );
        },
      ),
    );
  }
}

class _LoadingShell extends StatelessWidget {
  const _LoadingShell();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScreenHeader(
          eyebrow: 'OVERVIEW',
          title: AppStrings.tabFarm,
          actionIcon: Icons.add_rounded,
          onAction: () => context.push('/farm/add'),
        ),
        const Expanded(child: LoadingState()),
      ],
    );
  }
}

class _FarmBody extends StatelessWidget {
  const _FarmBody({
    required this.farms,
    required this.crops,
    required this.onRefresh,
  });
  final List<Farm> farms;
  final List<Crop> crops;
  final Future<void> Function() onRefresh;

  int _cropsForFarm(String farmId) =>
      crops.where((c) => c.farmId == farmId).length;

  @override
  Widget build(BuildContext context) {
    final totalAcres = farms.fold<double>(0, (s, f) => s + f.sizeAcres);
    final cropsCount = crops.length;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: ScreenHeader(
              eyebrow: 'OVERVIEW',
              title: AppStrings.tabFarm,
              actionIcon: Icons.add_rounded,
              onAction: () => context.push('/farm/add'),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.huge,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                _SummaryStrip(
                  farms: farms.length,
                  acres: totalAcres,
                  crops: cropsCount,
                ),
                const SizedBox(height: AppSpacing.xxl),
                SectionHeader(
                  eyebrow: 'YOUR FIELDS',
                  title: AppStrings.myFarms,
                  actionLabel: AppStrings.add,
                  onAction: () => context.push('/farm/add'),
                ),
                const SizedBox(height: AppSpacing.md),
                for (final farm in farms) ...[
                  _FarmCard(
                    farm: farm,
                    cropsCount: _cropsForFarm(farm.id),
                    onTap: () => context.push('/farm/crops/${farm.id}'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.16),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({
    required this.farms,
    required this.acres,
    required this.crops,
  });
  final int farms;
  final double acres;
  final int crops;

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
              icon: Icons.grass_rounded,
              tint: AppColors.tintGreen,
              color: AppColors.primary,
              value: '$farms',
              label: AppStrings.farms,
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: AppColors.divider,
          ),
          Expanded(
            child: _SummaryItem(
              icon: Icons.straighten_rounded,
              tint: AppColors.tintAmber,
              color: AppColors.accentDark,
              value: acres.toStringAsFixed(1),
              label: AppStrings.acres,
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: AppColors.divider,
          ),
          Expanded(
            child: _SummaryItem(
              icon: Icons.eco_rounded,
              tint: AppColors.tintBlue,
              color: AppColors.info,
              value: '$crops',
              label: AppStrings.crops,
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
    required this.label,
  });
  final IconData icon;
  final Color tint;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconBadge(icon: icon, tint: tint, color: color, size: 40, iconSize: 20),
        const SizedBox(height: AppSpacing.sm),
        Text(value, style: AppTextStyles.stat),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _FarmCard extends StatelessWidget {
  const _FarmCard({
    required this.farm,
    required this.cropsCount,
    required this.onTap,
  });
  final Farm farm;
  final int cropsCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      elevation: AppElevation.card,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconBadge(
            icon: Icons.grass_rounded,
            tint: AppColors.tintGreen,
            color: AppColors.primary,
            size: 48,
            iconSize: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  farm.name,
                  style: AppTextStyles.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        farm.location,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                AppDivider(),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    AppChip(
                      label: farm.soilType.bangla,
                      icon: Icons.terrain_rounded,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${farm.sizeAcres.toStringAsFixed(1)} ${AppStrings.acres}',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$cropsCount',
                style: AppTextStyles.stat.copyWith(fontSize: 26),
              ),
              const SizedBox(height: 2),
              Text(AppStrings.crops, style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyFarmBody extends StatelessWidget {
  const _EmptyFarmBody({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('OVERVIEW', style: AppTextStyles.overline),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(AppStrings.tabFarm, style: AppTextStyles.h1),
                      ],
                    ),
                  ),
                  _RoundIconButton(
                    icon: Icons.add_rounded,
                    onTap: onAdd,
                  ),
                ],
              ),
              const Spacer(),
              const EmptyState(
                icon: Icons.grass_rounded,
                title: AppStrings.noFarmsYet,
                message: AppStrings.addFirstFarm,
                actionLabel: AppStrings.addFarm,
              ),
              const Spacer(),
              PrimaryButton(
                label: AppStrings.addFarm,
                icon: Icons.add_rounded,
                onPressed: onAdd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
