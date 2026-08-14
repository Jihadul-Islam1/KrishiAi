import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/crop.dart';
import '../../../data/models/profit_estimate.dart';
import '../../providers/app_providers.dart';

class ProfitCalculatorScreen extends ConsumerStatefulWidget {
  const ProfitCalculatorScreen({super.key});

  @override
  ConsumerState<ProfitCalculatorScreen> createState() =>
      _ProfitCalculatorScreenState();
}

class _ProfitCalculatorScreenState
    extends ConsumerState<ProfitCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _landController = TextEditingController();
  final _yieldController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();
  final _cropNameController = TextEditingController();
  String? _selectedCropId;
  String? _selectedCropName;

  @override
  void dispose() {
    _landController.dispose();
    _yieldController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _cropNameController.dispose();
    super.dispose();
  }

  void _applyCrop(Crop c) {
    setState(() {
      _selectedCropId = c.id;
      _selectedCropName = c.name;
      _cropNameController.text = c.name;
      _landController.text = c.landSizeAcres.toStringAsFixed(2);
      if (c.estimatedYieldKg != null) {
        _yieldController.text = c.estimatedYieldKg!.toStringAsFixed(0);
      }
    });
  }

  ProfitEstimate? _buildEstimate() {
    if (!_formKey.currentState!.validate()) return null;
    return ProfitEstimate(
      cropName: _cropNameController.text.trim(),
      landSizeAcres: double.tryParse(_landController.text.trim()) ?? 0,
      estimatedProductionKg:
          double.tryParse(_yieldController.text.trim()) ?? 0,
      sellingPricePerKg:
          double.tryParse(_priceController.text.trim()) ?? 0,
      totalCost: double.tryParse(_costController.text.trim()) ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cropsAsync = ref.watch(cropsProvider);
    final estimate = _buildEstimate();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'লাভের হিসাব',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xxxl,
        ),
        child: Form(
          key: _formKey,
          onChanged: () => setState(() {}),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ফসল নির্বাচন', style: AppTextStyles.bodyBold),
              const SizedBox(height: AppSpacing.sm),
              cropsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Center(child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary,
                  )),
                ),
                error: (_, _) => AppCard(
                  color: AppColors.surface,
                  child: Row(children: const [
                    Icon(Icons.info_outline, color: AppColors.warning),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'ফসলের তালিকা লোড করা যায়নি। নিচে নাম লিখে\nহিসাব করুন।',
                        style: AppTextStyles.bodySecondary,
                      ),
                    ),
                  ]),
                ),
                data: (crops) {
                  if (crops.isEmpty) {
                    return AppCard(
                      color: AppColors.surface,
                      child: Row(children: const [
                        Icon(Icons.info_outline, color: AppColors.textMuted),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'কোনো ফসল যোগ করা হয়নি। নিচে নাম লিখে\nহিসাব করুন।',
                            style: AppTextStyles.bodySecondary,
                          ),
                        ),
                      ]),
                    );
                  }
                  return SizedBox(
                    height: 56,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: crops.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (_, i) {
                        final c = crops[i];
                        final selected = c.id == _selectedCropId;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xs,
                          ),
                          child: ChoiceChip(
                            label: Text(c.name),
                            selected: selected,
                            onSelected: (_) => _applyCrop(c),
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.surface,
                            labelStyle: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            side: BorderSide(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text('তথ্য পূরণ করুন', style: AppTextStyles.bodyBold),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      label: 'ফসলের নাম',
                      hint: 'যেমন: ধান',
                      controller: _cropNameController,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'নাম দিন'
                          : null,
                      prefixIcon: Icons.spa_outlined,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(children: [
                      Expanded(
                        child: AppTextField(
                          label: 'জমি (একর)',
                          hint: '0',
                          controller: _landController,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          validator: (v) {
                            final n = double.tryParse((v ?? '').trim());
                            if (n == null || n <= 0) return 'সঠিক সংখ্যা';
                            return null;
                          },
                          prefixIcon: Icons.landscape_outlined,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppTextField(
                          label: 'উৎপাদন (কেজি)',
                          hint: '0',
                          controller: _yieldController,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          validator: (v) {
                            final n = double.tryParse((v ?? '').trim());
                            if (n == null || n < 0) return 'সঠিক সংখ্যা';
                            return null;
                          },
                          prefixIcon: Icons.scale_outlined,
                        ),
                      ),
                    ]),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'বিক্রয়মূল্য (৳/কেজি)',
                      hint: '0',
                      controller: _priceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        final n = double.tryParse((v ?? '').trim());
                        if (n == null || n < 0) return 'সঠিক মূল্য';
                        return null;
                      },
                      prefixIcon: Icons.sell_outlined,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'মোট খরচ (৳)',
                      hint: '0',
                      controller: _costController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        final n = double.tryParse((v ?? '').trim());
                        if (n == null || n < 0) return 'সঠিক পরিমাণ';
                        return null;
                      },
                      prefixIcon: Icons.payments_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text('ফলাফল', style: AppTextStyles.bodyBold),
              const SizedBox(height: AppSpacing.sm),
              _ResultCard(estimate: estimate),
              if (estimate != null) ...[
                const SizedBox(height: AppSpacing.lg),
                _BreakdownCard(
                  estimate: estimate,
                  selectedCropName: _selectedCropName,
                ),
                const SizedBox(height: AppSpacing.lg),
                _BreakevenCard(estimate: estimate),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.estimate});
  final ProfitEstimate? estimate;

  @override
  Widget build(BuildContext context) {
    if (estimate == null) {
      return AppCard(
        color: AppColors.surface,
        child: Row(children: const [
          Icon(Icons.calculate_outlined, color: AppColors.textMuted),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'ফলাফল দেখতে সব তথ্য পূরণ করুন।',
              style: AppTextStyles.bodySecondary,
            ),
          ),
        ]),
      );
    }
    final profit = estimate!.estimatedProfit;
    final profitable = estimate!.isProfitable;
    final base = profitable ? AppColors.success : AppColors.danger;
    final dark = profitable ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C);
    return AppCard(
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          gradient: LinearGradient(
            colors: [base, dark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(
                profitable
                    ? Icons.trending_up_outlined
                    : Icons.trending_down_outlined,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                profitable ? 'মোট লাভ' : 'মোট ক্ষতি',
                style: AppTextStyles.bodySecondary.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ]),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppNumber.money(profit),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'ফসল: ${estimate!.cropName.isEmpty ? "—" : estimate!.cropName}',
              style: AppTextStyles.bodySecondary.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({
    required this.estimate,
    required this.selectedCropName,
  });
  final ProfitEstimate estimate;
  final String? selectedCropName;

  @override
  Widget build(BuildContext context) {
    final revenue = estimate.estimatedRevenue;
    final cost = estimate.totalCost;
    final profit = estimate.estimatedProfit;
    final margin = revenue > 0 ? (profit / revenue) * 100 : 0.0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('বিস্তারিত হিসাব', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.md),
          _Row(label: 'আনুমানিক আয়', value: AppNumber.money(revenue)),
          const Divider(height: AppSpacing.xl),
          _Row(label: 'মোট খরচ', value: AppNumber.money(cost)),
          const Divider(height: AppSpacing.xl),
          _Row(
            label: 'লাভের পার্থক্য',
            value: AppNumber.money(profit),
            valueColor:
                estimate.isProfitable ? AppColors.success : AppColors.danger,
          ),
          const Divider(height: AppSpacing.xl),
          _Row(
            label: 'মুনাফার হার',
            value: AppNumber.percent(margin),
            valueColor:
                estimate.isProfitable ? AppColors.success : AppColors.danger,
          ),
          if (estimate.landSizeAcres > 0) ...[
            const Divider(height: AppSpacing.xl),
            _Row(
              label: 'একর প্রতি লাভ',
              value: AppNumber.money(profit / estimate.landSizeAcres),
            ),
          ],
          if (selectedCropName != null && selectedCropName!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Row(children: [
              const Icon(Icons.eco_outlined,
                  size: 16, color: AppColors.textMuted),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'নির্বাচিত ফসল: $selectedCropName',
                  style: AppTextStyles.caption,
                ),
              ),
            ]),
          ],
        ],
      ),
    );
  }
}

class _BreakevenCard extends StatelessWidget {
  const _BreakevenCard({required this.estimate});
  final ProfitEstimate estimate;

  @override
  Widget build(BuildContext context) {
    final price = estimate.sellingPricePerKg;
    final yieldKg = estimate.estimatedProductionKg;
    final cost = estimate.totalCost;
    final breakevenPrice = yieldKg > 0 ? cost / yieldKg : 0.0;
    final aboveBreakeven = price > breakevenPrice && breakevenPrice > 0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.flag_outlined, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            const Expanded(
              child: Text('সমতা মূল্য', style: AppTextStyles.h3),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: aboveBreakeven
                    ? AppColors.success.withValues(alpha: 0.12)
                    : AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                aboveBreakeven ? 'নিরাপদ' : 'ঝুঁকিপূর্ণ',
                style: AppTextStyles.caption.copyWith(
                  color: aboveBreakeven
                      ? AppColors.success
                      : AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ]),
          const SizedBox(height: AppSpacing.md),
          Text(
            'প্রতি কেজি ৳${breakevenPrice.toStringAsFixed(2)} এ বিক্রি\nকরলে কোনো লাভ বা ক্ষতি হবে না।',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: breakevenPrice == 0
                ? 0
                : (price / (breakevenPrice * 2)).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: AppColors.surfaceVariant,
            color: aboveBreakeven ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(children: [
            Text('আপনার মূল্য: ${AppNumber.money(price)}/কেজি',
                style: AppTextStyles.caption),
            const Spacer(),
            Text('সমতা: ${AppNumber.money(breakevenPrice)}/কেজি',
                style: AppTextStyles.caption),
          ]),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.valueColor,
  });
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(children: [
        Expanded(child: Text(label, style: AppTextStyles.body)),
        Text(
          value,
          style: AppTextStyles.bodyBold.copyWith(color: valueColor),
        ),
      ]),
    );
  }
}
