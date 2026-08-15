import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_chip.dart';
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
            return _EmptyFarmBody(onAdd: () => context.push('/farm/add'));
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
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.huge,
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
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF064E3B), Color(0xFF065F46)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF022C22).withValues(alpha: 0.35),
            blurRadius: 20,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              icon: Icons.grass_rounded,
              tint: const Color(0xFF065F46),
              color: const Color(0xFFA7F3D0),
              value: '$farms',
              label: AppStrings.farms,
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: const Color(0xFFA7F3D0).withValues(alpha: 0.18),
          ),
          Expanded(
            child: _SummaryItem(
              icon: Icons.straighten_rounded,
              tint: const Color(0xFF047857),
              color: const Color(0xFFBBF7D0),
              value: acres.toStringAsFixed(1),
              label: AppStrings.acres,
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: const Color(0xFFA7F3D0).withValues(alpha: 0.18),
          ),
          Expanded(
            child: _SummaryItem(
              icon: Icons.eco_rounded,
              tint: const Color(0xFF10B981),
              color: const Color(0xFFD1FAE5),
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
        Text(
          value,
          style: AppTextStyles.stat.copyWith(color: const Color(0xFFF0FDF4)),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: const Color(0xFFA7F3D0)),
        ),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF065F46), Color(0xFF064E3B)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF022C22).withValues(alpha: 0.40),
            blurRadius: 22,
            spreadRadius: -6,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          splashColor: const Color(0xFF34D399).withValues(alpha: 0.18),
          highlightColor: const Color(0xFF10B981).withValues(alpha: 0.12),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF10B981), Color(0xFF047857)],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF022C22).withValues(alpha: 0.45),
                        blurRadius: 14,
                        spreadRadius: -4,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.grass_rounded,
                    color: Color(0xFFD1FAE5),
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farm.name,
                        style: AppTextStyles.title.copyWith(
                          color: const Color(0xFFD1FAE5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: const Color(
                              0xFFA7F3D0,
                            ).withValues(alpha: 0.85),
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              farm.location,
                              style: AppTextStyles.caption.copyWith(
                                color: const Color(0xFFA7F3D0),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        height: 1,
                        color: const Color(0xFFA7F3D0).withValues(alpha: 0.18),
                      ),
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
                              color: const Color(0xFFD1FAE5),
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
                      style: AppTextStyles.stat.copyWith(
                        fontSize: 26,
                        color: const Color(0xFFF0FDF4),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.crops,
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFFA7F3D0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
                  _RoundIconButton(icon: Icons.add_rounded, onTap: onAdd),
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
