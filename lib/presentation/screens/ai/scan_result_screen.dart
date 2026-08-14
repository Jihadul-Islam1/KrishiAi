import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/diagnosis.dart';
import '../../../data/models/disease.dart';
import '../../providers/app_providers.dart';

/// Full diagnosis result screen. Shows the crop, suspected disease,
/// severity, confidence, symptoms, possible causes, management steps,
/// and prevention. Saved diagnosis records live in `LocalStore` via
/// the `DiagnosisRepository` (key: `diagnoses_v1`).
class ScanResultScreen extends ConsumerStatefulWidget {
  const ScanResultScreen({
    super.key,
    required this.cropName,
    this.notes,
    this.diagnosis,
  });
  final String cropName;
  final String? notes;
  final Diagnosis? diagnosis;

  @override
  ConsumerState<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends ConsumerState<ScanResultScreen> {
  bool _saved = false;
  bool _saving = false;

  Future<void> _save() async {
    final diag = widget.diagnosis;
    if (diag == null || _saving || _saved) return;
    setState(() => _saving = true);
    final repo = await ref.read(diagnosisRepoProvider.future);
    final list = await repo.all();
    final exists = list.any((d) => d.id == diag.id);
    if (!exists) {
      await repo.save(diag);
    }
    if (!mounted) return;
    setState(() {
      _saving = false;
      _saved = true;
    });
    ref.invalidate(diagnosesProvider);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(content: Text(AppStrings.diagnosisSaved)),
    );
  }

  Future<void> _share() async {
    final diag = widget.diagnosis;
    final messenger = ScaffoldMessenger.of(context);
    final text = diag == null
        ? '${widget.cropName} — রোগ নির্ণয় ${AppStrings.aiDisclaimer}'
        : '${diag.cropName} — সম্ভাব্য রোগ: ${diag.diseaseName}\n'
            'তীব্রতা: ${diag.severity.bangla}\n'
            'প্রতিকার: ${diag.management.join(", ")}\n\n'
            '${AppStrings.aiDisclaimer}';
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text('কপি করুন: $text'.substring(0, text.length.clamp(0, 120)))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diag = widget.diagnosis;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'রোগ নির্ণয় ফলাফল',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: diag == null
          ? _EmptyResult(cropName: widget.cropName, notes: widget.notes)
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xxxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(diagnosis: diag),
                  const SizedBox(height: AppSpacing.lg),
                  _SectionList(
                    title: AppStrings.symptoms,
                    icon: Icons.visibility_outlined,
                    color: AppColors.info,
                    items: diag.symptoms,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SectionList(
                    title: AppStrings.possibleCauses,
                    icon: Icons.science_outlined,
                    color: AppColors.warning,
                    items: diag.causes,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SectionList(
                    title: AppStrings.management,
                    icon: Icons.healing_outlined,
                    color: AppColors.success,
                    items: diag.management,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SectionList(
                    title: AppStrings.prevention,
                    icon: Icons.shield_outlined,
                    color: AppColors.primary,
                    items: diag.prevention,
                  ),
                  if (widget.notes != null && widget.notes!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    _NotesCard(notes: widget.notes!),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  _SeekExpert(),
                  const SizedBox(height: AppSpacing.lg),
                  _DisclaimerCard(),
                  const SizedBox(height: AppSpacing.lg),
                  _ActionsRow(
                    saved: _saved,
                    saving: _saving,
                    onSave: _save,
                    onShare: _share,
                    onScanAnother: () => context.go('/ai/scan'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.diagnosis});
  final Diagnosis diagnosis;

  Color get _severityColor {
    switch (diagnosis.severity) {
      case Severity.low:
        return AppColors.severityLow;
      case Severity.medium:
        return AppColors.severityMedium;
      case Severity.high:
        return AppColors.severityHigh;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_severityColor, _severityColor.withValues(alpha: 0.78)],
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.eco_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      diagnosis.cropName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'স্ক্যান: ${AppDate.relativeBangla(diagnosis.scannedAt)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'সম্ভাব্য রোগ',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  diagnosis.diseaseName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _MetricBox(
                  label: AppStrings.severity,
                  value: diagnosis.severity.bangla,
                  icon: Icons.warning_amber_outlined,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MetricBox(
                  label: AppStrings.confidence,
                  value: '${(diagnosis.confidence * 100).round()}%',
                  icon: Icons.verified_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionList extends StatelessWidget {
  const _SectionList({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(title, style: AppTextStyles.title),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (items.isEmpty)
            const Text('তথ্য পাওয়া যায়নি',
                style: AppTextStyles.bodySecondary)
          else
            Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 7),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          items[i],
                          style: AppTextStyles.body.copyWith(height: 1.5),
                        ),
                      ),
                    ],
                  ),
                  if (i != items.length - 1)
                    const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.notes});
  final String notes;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.surfaceVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sticky_note_2_outlined,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text(AppStrings.notes, style: AppTextStyles.title),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(notes, style: AppTextStyles.body.copyWith(height: 1.5)),
        ],
      ),
    );
  }
}

class _SeekExpert extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.support_agent_outlined,
              color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              AppStrings.seekExpert,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline,
              color: AppColors.primaryDark, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              AppStrings.aiDisclaimer,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primaryDark,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  const _ActionsRow({
    required this.saved,
    required this.saving,
    required this.onSave,
    required this.onShare,
    required this.onScanAnother,
  });
  final bool saved;
  final bool saving;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onScanAnother;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PrimaryButton(
          label: saved ? 'সংরক্ষিত ✓' : AppStrings.saveDiagnosis,
          icon: saved ? Icons.check : Icons.bookmark_add_outlined,
          onPressed: (saved || saving) ? null : onSave,
          loading: saving,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: AppStrings.share,
                icon: Icons.share_outlined,
                background: AppColors.surface,
                foreground: AppColors.primary,
                onPressed: onShare,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: PrimaryButton(
                label: AppStrings.scanAnother,
                icon: Icons.refresh,
                background: AppColors.accent,
                onPressed: onScanAnother,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult({required this.cropName, this.notes});
  final String cropName;
  final String? notes;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bug_report_outlined,
                size: 56, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.md),
            const Text('নির্ণয়ের ফলাফল পাওয়া যায়নি',
                style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'ফসলের ছবি ও নোট দিয়ে আবার স্ক্যান করুন।',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: AppStrings.scanAnother,
              icon: Icons.refresh,
              onPressed: () => context.go('/ai/scan'),
            ),
          ],
        ),
      ),
    );
  }
}
