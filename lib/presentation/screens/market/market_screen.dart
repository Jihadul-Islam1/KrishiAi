import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';

import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/icon_badge.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/states.dart';
import '../../../data/models/market_price.dart';
import '../../providers/app_providers.dart';

/// Marketplace with live DAM prices + district-aware bundled fallback.
/// Rewritten on the home_dashboard minimalist pattern: gradient `_Header`,
/// `AppCard`, `IconBadge`, `SectionHeader`, `AppChip`, `AppTextStyles`.
class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  String? _selectedCategory;
  bool _showFavoritesOnly = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pricesAsync = ref.watch(marketPricesProvider);
    final categoriesAsync = ref.watch(marketCategoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: pricesAsync.when(
        loading: () => const _LoadingShell(),
        error: (e, _) => ErrorStateView(
          message: 'বাজারদর লোড করা যায়নি।',
          onRetry: () => ref.invalidate(marketPricesProvider),
        ),
        data: (all) {
          final categories = categoriesAsync.valueOrNull ?? const <String>[];
          final filtered = _filter(all, categories: categories);
          return _MarketBody(
            all: all,
            filtered: filtered,
            categories: categories,
            searchCtrl: _searchCtrl,
            query: _query,
            onQueryChanged: (v) => setState(() => _query = v),
            onClear: () {
              _searchCtrl.clear();
              setState(() => _query = '');
            },
            selectedCategory: _selectedCategory,
            onCategoryTap: (cat) =>
                setState(() => _selectedCategory = cat),
            showFavoritesOnly: _showFavoritesOnly,
            onToggleFavorites: () =>
                setState(() => _showFavoritesOnly = !_showFavoritesOnly),
            onRefresh: () async {
              ref.invalidate(marketPricesProvider);
              ref.invalidate(marketCategoriesProvider);
              await Future<void>.delayed(
                const Duration(milliseconds: 600),
              );
            },
            onToggleFavorite: (price) async {
              final repo = ref.read(marketRepoProvider);
              final updated = await repo.toggleFavorite(price);
              ref.invalidate(marketPricesProvider);
              ref.invalidate(marketFavoritesProvider);
              if (!context.mounted) return;
              _showFavoriteSnack(updated.isFavorite);
            },
          );
        },
      ),
    );
  }

  List<MarketPrice> _filter(
    List<MarketPrice> all, {
    required List<String> categories,
  }) {
    var list = all;
    if (_showFavoritesOnly) {
      list = list.where((m) => m.isFavorite).toList();
    }
    if (_selectedCategory != null) {
      list = list.where((m) => m.category == _selectedCategory).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.trim().toLowerCase();
      list = list
          .where((m) =>
              m.cropName.toLowerCase().contains(q) ||
              m.category.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  void _showFavoriteSnack(bool nowFav) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          nowFav ? 'প্রিয় তালিকায় যোগ হলো' : 'প্রিয় থেকে সরানো হলো',
        ),
      ),
    );
  }
}

// ============================================================================
// Header / chrome
// ============================================================================

class _LoadingShell extends StatelessWidget {
  const _LoadingShell();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _Header(
          showFavoritesOnly: false,
          onToggleFavorites: _noop,
          onRefresh: _noop,
        ),
        Expanded(
          child: LoadingState(message: 'বাজারদর লোড হচ্ছে...'),
        ),
      ],
    );
  }
}

class _MarketBody extends StatelessWidget {
  const _MarketBody({
    required this.all,
    required this.filtered,
    required this.categories,
    required this.searchCtrl,
    required this.query,
    required this.onQueryChanged,
    required this.onClear,
    required this.selectedCategory,
    required this.onCategoryTap,
    required this.showFavoritesOnly,
    required this.onToggleFavorites,
    required this.onRefresh,
    required this.onToggleFavorite,
  });

  final List<MarketPrice> all;
  final List<MarketPrice> filtered;
  final List<String> categories;
  final TextEditingController searchCtrl;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClear;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryTap;
  final bool showFavoritesOnly;
  final VoidCallback onToggleFavorites;
  final Future<void> Function() onRefresh;
  final Future<void> Function(MarketPrice price) onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: _Header(
              showFavoritesOnly: showFavoritesOnly,
              onToggleFavorites: onToggleFavorites,
              onRefresh: onRefresh,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.huge,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                _SearchHeader(
                  controller: searchCtrl,
                  onChanged: onQueryChanged,
                  onClear: onClear,
                ),
                const SizedBox(height: AppSpacing.md),
                if (categories.isNotEmpty)
                  _CategoryRow(
                    categories: categories,
                    selected: selectedCategory,
                    onTap: onCategoryTap,
                  ),
                const SizedBox(height: AppSpacing.xxl),
                _SummaryStrip(
                  total: all.length,
                  shown: filtered.length,
                  lastUpdated: all.isEmpty
                      ? null
                      : all
                          .map((m) => m.updatedAt)
                          .reduce((a, b) => a.isAfter(b) ? a : b),
                  showFavoritesOnly: showFavoritesOnly,
                ),
                const SizedBox(height: AppSpacing.xxl),
                SectionHeader(
                  eyebrow: 'TODAY',
                  title: showFavoritesOnly
                      ? AppStrings.marketFavorites
                      : AppStrings.marketTitle,
                  subtitle: showFavoritesOnly
                      ? 'আপনার প্রিয় পণ্যগুলো'
                      : '${AppStrings.marketRelated} • ${filtered.length} টি পণ্য',
                  actionLabel: AppStrings.marketRefresh,
                  onAction: onRefresh,
                ),
                const SizedBox(height: AppSpacing.md),
                if (filtered.isEmpty)
                  _EmptyResults(
                    favoritesOnly: showFavoritesOnly,
                  )
                else
                  for (final price in filtered) ...[
                    _PriceCard(
                      key: ValueKey(price.id),
                      price: price,
                      onTap: () => context.push('/market/${price.id}'),
                      onFavorite: () => onToggleFavorite(price),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                const SizedBox(height: AppSpacing.xxl),
                _Disclaimer(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient header mirrors `_Header` in `my_farm_screen.dart`,
/// `crop_doctor_screen.dart`, and `weather_screen.dart`. Two round buttons
/// sit in the trailing slot: favorites toggle + manual refresh.
class _Header extends StatelessWidget {
  const _Header({
    required this.showFavoritesOnly,
    required this.onToggleFavorites,
    required this.onRefresh,
  });

  final bool showFavoritesOnly;
  final VoidCallback onToggleFavorites;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 160,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.weatherCard, AppColors.fieldCard],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(AppRadius.xxl),
              bottomRight: Radius.circular(AppRadius.xxl),
            ),
          ),
        ),
        Positioned(
          right: -40,
          top: -30,
          child: _Blob(
            size: 140,
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
        Positioned(
          left: -50,
          top: 40,
          child: _Blob(
            size: 110,
            color: Colors.white.withValues(alpha: 0.04),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PRICES',
                        style: AppTextStyles.overline.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        AppStrings.marketTitle,
                        style: AppTextStyles.h1.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                _RoundIconButton(
                  icon: showFavoritesOnly
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  tooltip: AppStrings.marketFavorites,
                  onTap: onToggleFavorites,
                ),
                const SizedBox(width: AppSpacing.sm),
                _RefreshButton(onRefresh: onRefresh),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final btn = Material(
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
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}

class _RefreshButton extends StatelessWidget {
  const _RefreshButton({required this.onRefresh});
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: AppStrings.marketRefresh,
      child: Material(
        color: Colors.white.withValues(alpha: 0.16),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onRefresh,
          child: const SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

Future<void> _noop() async {}

// ============================================================================
// Search + category row
// ============================================================================

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: AppStrings.marketSearchHint,
      controller: controller,
      hint: AppStrings.marketSearchHint,
      prefixIcon: Icons.search,
      suffixIcon: controller.text.isEmpty
          ? null
          : IconButton(
              icon: Icon(Icons.close, color: AppColors.textSecondary),
              onPressed: onClear,
              tooltip: 'মুছুন',
            ),
      onChanged: onChanged,
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.categories,
    required this.selected,
    required this.onTap,
  });
  final List<String> categories;
  final String? selected;
  final ValueChanged<String?> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: AppChip(
              label: AppStrings.marketCategoryAll,
              selected: selected == null,
              onTap: () => onTap(null),
              icon: Icons.apps_rounded,
            ),
          ),
          for (final cat in categories)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: AppChip(
                label: cat,
                selected: cat == selected,
                onTap: () => onTap(cat == selected ? null : cat),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// Summary strip + price card + empty + disclaimer
// ============================================================================

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({
    required this.total,
    required this.shown,
    required this.lastUpdated,
    required this.showFavoritesOnly,
  });

  final int total;
  final int shown;
  final DateTime? lastUpdated;
  final bool showFavoritesOnly;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      elevation: AppElevation.card,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              icon: Icons.shopping_basket_outlined,
              tint: AppColors.tintGreen,
              color: AppColors.primary,
              value: '$shown',
              label: showFavoritesOnly
                  ? AppStrings.marketFavoritesCount
                  : AppStrings.marketTotalCount,
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.divider),
          Expanded(
            child: _SummaryItem(
              icon: Icons.checklist_rounded,
              tint: AppColors.tintBlue,
              color: AppColors.info,
              value: '$total',
              label: AppStrings.marketInMarkets,
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.divider),
          Expanded(
            child: _SummaryItem(
              icon: Icons.schedule_rounded,
              tint: AppColors.tintAmber,
              color: AppColors.accentDark,
              value: lastUpdated == null ? '—' : _shortTime(lastUpdated!),
              label: AppStrings.marketUpdated,
            ),
          ),
        ],
      ),
    );
  }

  String _shortTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
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
        IconBadge(
          icon: icon,
          tint: tint,
          color: color,
          size: 36,
          iconSize: 18,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: AppTextStyles.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({
    super.key,
    required this.price,
    required this.onTap,
    required this.onFavorite,
  });
  final MarketPrice price;
  final VoidCallback onTap;
  final Future<void> Function() onFavorite;

  @override
  Widget build(BuildContext context) {
    final trend = price.trend;
    final trendColor = _trendColor(trend);
    final trendIcon = _trendIcon(trend);
    final trendLabel = _trendLabel(trend);
    final changed = price.changePercent;
    final updated = AppDate.relativeBangla(price.updatedAt);
    final trendTint = trend == PriceTrend.up
        ? AppColors.tintRed
        : trend == PriceTrend.down
            ? AppColors.tintGreen
            : AppColors.tintAmber;

    return AppCard(
      onTap: onTap,
      elevation: AppElevation.card,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconBadge(
            icon: _categoryIcon(price.category),
            tint: AppColors.tintGreen,
            color: AppColors.primary,
            size: 48,
            iconSize: 22,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  price.cropName,
                  style: AppTextStyles.h3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.storefront_outlined,
                      size: 13,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        '${price.market} • ${price.category}',
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    IconBadge(
                      icon: trendIcon,
                      tint: trendTint,
                      color: trendColor,
                      size: 22,
                      iconSize: 13,
                      shape: BoxShape.rectangle,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${changed >= 0 ? '+' : ''}${changed.toStringAsFixed(1)}%',
                      style: AppTextStyles.caption.copyWith(
                        color: trendColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '• $trendLabel',
                      style: AppTextStyles.caption.copyWith(
                        color: trendColor,
                      ),
                    ),
                  ],
                ),
                if (price.minPrice != null && price.maxPrice != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${AppStrings.marketMinMax}: ${AppNumber.money(price.minPrice!)} - ${AppNumber.money(price.maxPrice!)}',
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppNumber.money(price.currentPrice),
                style: AppTextStyles.h2.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 2),
              Text(
                '${AppStrings.marketPerUnit} ${price.unit}',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 4),
              Text(updated, style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            tooltip: AppStrings.marketFavorites,
            icon: Icon(
              price.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: price.isFavorite
                  ? AppColors.accent
                  : AppColors.textMuted,
            ),
            onPressed: onFavorite,
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'চাল':
      case 'গম':
        return Icons.rice_bowl_outlined;
      case 'সবজি':
        return Icons.eco_outlined;
      case 'ফল':
        return Icons.apple_outlined;
      case 'মসলা':
        return Icons.local_fire_department_outlined;
      case 'ডাল':
        return Icons.spa_outlined;
      case 'মাছ':
        return Icons.set_meal_outlined;
      case 'দুগ্ধ':
        return Icons.water_drop_outlined;
      case 'প্রাণিজ':
        return Icons.egg_outlined;
      case 'তেলবীজ':
        return Icons.opacity_outlined;
      case 'ফসল':
        return Icons.grass_rounded;
      default:
        return Icons.shopping_basket_outlined;
    }
  }

  IconData _trendIcon(PriceTrend trend) {
    switch (trend) {
      case PriceTrend.up:
        return Icons.trending_up_rounded;
      case PriceTrend.down:
        return Icons.trending_down_rounded;
      case PriceTrend.stable:
        return Icons.trending_flat_rounded;
    }
  }

  Color _trendColor(PriceTrend trend) {
    switch (trend) {
      case PriceTrend.up:
        return AppColors.severityHigh;
      case PriceTrend.down:
        return AppColors.success;
      case PriceTrend.stable:
        return AppColors.warning;
    }
  }

  String _trendLabel(PriceTrend trend) {
    switch (trend) {
      case PriceTrend.up:
        return AppStrings.marketTrendUp;
      case PriceTrend.down:
        return AppStrings.marketTrendDown;
      case PriceTrend.stable:
        return AppStrings.marketTrendStable;
    }
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.favoritesOnly});
  final bool favoritesOnly;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: EmptyState(
        icon: favoritesOnly ? Icons.star_outline_rounded : Icons.search_off_rounded,
        title: favoritesOnly
            ? AppStrings.marketFavoritesEmpty
            : AppStrings.marketNoResults,
        message: favoritesOnly
            ? AppStrings.marketFavoritesEmptyHint
            : AppStrings.marketSearchEmptyHint,
      ),
    );
  }
}

/// Disclaimer footer mirrors `_Disclaimer` in `weather_screen.dart` and
/// `crop_doctor_screen.dart`.
class _Disclaimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.surfaceVariant,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(
            icon: Icons.info_outline,
            tint: AppColors.tintAmber,
            color: AppColors.accentDark,
            size: 36,
            iconSize: 18,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              AppStrings.marketDisclaimer,
              style: AppTextStyles.caption.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}




