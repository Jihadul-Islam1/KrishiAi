import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_divider.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/icon_badge.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/states.dart';
import '../../../data/models/crop.dart';

import '../../providers/app_providers.dart';

/// AI Crop Doctor — three-step diagnosis flow:
///   1. Pick a crop (from your farm).
///   2. Optionally capture or select a photo of the affected plant.
///   3. Add notes about symptoms, then let the stub analyzer run.
///
/// The analyzer is the same `analyzeImagePlaceholder` used by the rest of the
/// AI module — it returns a sample `Diagnosis` matched against the disease
/// library. The picked image, if any, is forwarded to the result screen so
/// the user can see what they scanned next to the diagnosis.
class CropDoctorScreen extends ConsumerStatefulWidget {
  const CropDoctorScreen({super.key});

  @override
  ConsumerState<CropDoctorScreen> createState() => _CropDoctorScreenState();
}

class _CropDoctorScreenState extends ConsumerState<CropDoctorScreen> {
  final _notesController = TextEditingController();
  final _picker = ImagePicker();
  String? _selectedCropName;
  String? _imagePath;
  bool _analyzing = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  bool get _canAnalyze =>
      _selectedCropName != null && _selectedCropName!.isNotEmpty && !_analyzing;

  Future<void> _pick(ImageSource source) async {
    try {
      final xfile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (xfile == null) return;
      if (!mounted) return;
      setState(() => _imagePath = xfile.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ছবি নেওয়া যায়নি: $e')),
      );
    }
  }

  Future<void> _analyze() async {
    if (!_canAnalyze) return;
    setState(() => _analyzing = true);
    final repo = await ref.read(aiRepoProvider.future);
    final diag = await repo.analyzeImagePlaceholder(
      cropName: _selectedCropName!,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _analyzing = false);
    context.push(
      '/ai/scan/result',
      extra: <String, dynamic>{
        'cropName': diag.cropName,
        'notes': diag.notes,
        'diagnosis': diag,
        if (_imagePath != null) 'imagePath': _imagePath,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cropsAsync = ref.watch(cropsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: cropsAsync.when(
        loading: () => const _LoadingShell(),
        error: (e, _) => Scaffold(
          backgroundColor: AppColors.background,
          body: ErrorStateView(
            message: 'ফসলের তালিকা লোড করা যায়নি।',
            onRetry: () => ref.invalidate(cropsProvider),
          ),
        ),
        data: (crops) {
          final cropNames = crops.map((c) => c.name).toSet().toList()..sort();
          // Default to first crop if user hasn't picked yet.
          if (_selectedCropName == null && cropNames.isNotEmpty) {
            _selectedCropName = cropNames.first;
          }
          return _DoctorBody(
            cropNames: cropNames,
            crops: crops,
            selectedCropName: _selectedCropName,
            onCropChanged: (v) => setState(() => _selectedCropName = v),
            notesController: _notesController,
            imagePath: _imagePath,
            onCamera: () => _pick(ImageSource.camera),
            onGallery: () => _pick(ImageSource.gallery),
            onClearImage: () => setState(() => _imagePath = null),
            analyzing: _analyzing,
            canAnalyze: _canAnalyze,
            onAnalyze: _analyze,
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
          eyebrow: 'AI CROP DOCTOR',
          title: AppStrings.cropDoctor,
          actionIcon: Icons.history_rounded,
          onAction: () => context.push('/ai/history'),
        ),
        const Expanded(
          child: LoadingState(message: 'ফসলের তালিকা লোড হচ্ছে...'),
        ),
      ],
    );
  }
}

class _DoctorBody extends StatelessWidget {
  const _DoctorBody({
    required this.cropNames,
    required this.crops,
    required this.selectedCropName,
    required this.onCropChanged,
    required this.notesController,
    required this.imagePath,
    required this.onCamera,
    required this.onGallery,
    required this.onClearImage,
    required this.analyzing,
    required this.canAnalyze,
    required this.onAnalyze,
  });

  final List<String> cropNames;
  final List<Crop> crops;
  final String? selectedCropName;
  final ValueChanged<String?> onCropChanged;
  final TextEditingController notesController;
  final String? imagePath;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onClearImage;
  final bool analyzing;
  final bool canAnalyze;
  final VoidCallback onAnalyze;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Riverpod handles its own refresh; nothing else to do here.
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: ScreenHeader(
              eyebrow: 'AI CROP DOCTOR',
              title: AppStrings.cropDoctor,
              actionIcon: Icons.history_rounded,
              onAction: () => context.push('/ai/history'),
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
                _SubHeader(
                  onHistory: () => context.push('/ai/history'),
                  historyCount: 0,
                ),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(
                  eyebrow: 'STEP 1',
                  title: 'ফসল নির্বাচন করুন',
                  subtitle: 'আপনার খামারের ফসলগুলো থেকে একটি বেছে নিন',
                ),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  elevation: AppElevation.card,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: cropNames.isEmpty
                      ? const _NoCropsHint()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppDropdownField<String>(
                              label: AppStrings.cropName,
                              value: selectedCropName,
                              items: cropNames
                                  .map(
                                    (n) => DropdownMenuItem<String>(
                                      value: n,
                                      child: Text(n, style: AppTextStyles.body),
                                    ),
                                  )
                                  .toList(),
                              onChanged: onCropChanged,
                            ),
                            if (selectedCropName != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              AppDivider(),
                              const SizedBox(height: AppSpacing.md),
                              _SelectedCropMeta(
                                cropName: selectedCropName!,
                                crops: crops,
                              ),
                            ],
                          ],
                        ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(
                  eyebrow: 'STEP 2',
                  title: 'ছবি তুলুন (ঐচ্ছিক)',
                  subtitle: 'ভালো নির্ণয়ের জন্য আক্রান্ত পাতার কাছের ছবি দিন',
                ),
                const SizedBox(height: AppSpacing.md),
                _ImagePickerCard(
                  imagePath: imagePath,
                  onCamera: onCamera,
                  onGallery: onGallery,
                  onClear: onClearImage,
                ),
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(
                  eyebrow: 'STEP 3',
                  title: 'লক্ষণ ও নোট',
                  subtitle: 'যা দেখছেন তা লিখুন — AI আরও ভালো পরামর্শ দেবে',
                ),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  elevation: AppElevation.card,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: AppTextField(
                    label: AppStrings.notesOptional,
                    hint: 'যেমন: পাতায় হলুদ দাগ, পাতার নিচে সাদা পাউডার',
                    controller: notesController,
                    minLines: 3,
                    maxLines: 6,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(
                  eyebrow: 'STEP 4',
                  title: 'AI দিয়ে বিশ্লেষণ',
                  subtitle: 'ফসল নির্বাচন বাধ্যতামূলক, ছবি ও নোট ঐচ্ছিক',
                ),
                const SizedBox(height: AppSpacing.md),
                _AnalyzeCard(
                  analyzing: analyzing,
                  canAnalyze: canAnalyze,
                  onAnalyze: onAnalyze,
                  imagePath: imagePath,
                  selectedCropName: selectedCropName,
                ),
                const SizedBox(height: AppSpacing.lg),
                _SafetyNote(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubHeader extends StatelessWidget {
  const _SubHeader({required this.onHistory, required this.historyCount});
  final VoidCallback onHistory;
  final int historyCount;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      elevation: AppElevation.card,
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderColor: AppColors.primary.withValues(alpha: 0.18),
      child: Row(
        children: [
          IconBadge(
            icon: Icons.medical_services_rounded,
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
                  'আপনার ফসলের AI ডাক্তার',
                  style: AppTextStyles.bodyBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'ছবি, ফসল ও নোট দিয়ে প্রাথমিক রোগ নির্ণয় ও পরামর্শ পান',
                  style: AppTextStyles.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppTextButtonInline(
            label: AppStrings.seeAll,
            icon: Icons.history_rounded,
            onPressed: onHistory,
          ),
        ],
      ),
    );
  }
}

class _SelectedCropMeta extends StatelessWidget {
  const _SelectedCropMeta({required this.cropName, required this.crops});
  final String cropName;
  final List<Crop> crops;

  Crop? _findCrop() {
    for (final c in crops) {
      if (c.name == cropName) return c;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final crop = _findCrop();
    return Row(
      children: [
        IconBadge(
          icon: Icons.eco_rounded,
          tint: AppColors.tintGreen,
          color: AppColors.primary,
          size: 40,
          iconSize: 20,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cropName,
                style: AppTextStyles.bodyBold,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                crop == null
                    ? 'বিশ্লেষণের জন্য প্রস্তুত'
                    : '${crop.stage.bangla} • ${crop.landSizeAcres.toStringAsFixed(1)} ${AppStrings.acres}',
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        AppChip(label: 'নির্বাচিত', icon: Icons.check_rounded),
      ],
    );
  }
}

class _ImagePickerCard extends StatelessWidget {
  const _ImagePickerCard({
    required this.imagePath,
    required this.onCamera,
    required this.onGallery,
    required this.onClear,
  });
  final String? imagePath;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;
    return AppCard(
      elevation: AppElevation.card,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: hasImage
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: AppColors.surfaceVariant,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.broken_image_outlined,
                              color: AppColors.textMuted,
                              size: 32,
                            ),
                          ),
                        ),
                        Positioned(
                          top: AppSpacing.sm,
                          right: AppSpacing.sm,
                          child: Material(
                            color: Colors.black.withValues(alpha: 0.55),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: onClear,
                              child: const SizedBox(
                                width: 36,
                                height: 36,
                                child: Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      color: AppColors.surfaceVariant,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconBadge(
                            icon: Icons.add_a_photo_outlined,
                            tint: AppColors.tintGreen,
                            color: AppColors.primary,
                            size: 56,
                            iconSize: 28,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'এখনো কোনো ছবি নেওয়া হয়নি',
                            style: AppTextStyles.bodySecondary,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ক্যামেরা বা গ্যালারি থেকে একটি ছবি যোগ করুন',
                            style: AppTextStyles.caption,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'ক্যামেরা',
                  icon: Icons.camera_alt_rounded,
                  onPressed: onCamera,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: PrimaryButton(
                  label: 'গ্যালারি',
                  icon: Icons.photo_library_rounded,
                  background: AppColors.surface,
                  foreground: AppColors.primary,
                  onPressed: onGallery,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalyzeCard extends StatelessWidget {
  const _AnalyzeCard({
    required this.analyzing,
    required this.canAnalyze,
    required this.onAnalyze,
    required this.imagePath,
    required this.selectedCropName,
  });
  final bool analyzing;
  final bool canAnalyze;
  final VoidCallback onAnalyze;
  final String? imagePath;
  final String? selectedCropName;

  @override
  Widget build(BuildContext context) {
    final hasCrop = selectedCropName != null && selectedCropName!.isNotEmpty;
    final hasImage = imagePath != null && imagePath!.isNotEmpty;
    return AppCard(
      elevation: AppElevation.card,
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderColor: AppColors.primary.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(
                icon: Icons.auto_awesome_rounded,
                tint: AppColors.tintViolet,
                color: AppColors.primary,
                size: 44,
                iconSize: 22,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'AI এই ফসলের সাধারণ রোগ ও পরামর্শ দেবে',
                  style: AppTextStyles.bodyBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'সঠিক নির্ণয়ের জন্য ছবি তুলে আপলোড করলে ভালো ফল পাবেন। এখন শুধু ফসলের নাম ও নোটের ভিত্তিতে প্রাথমিক পরামর্শ দেওয়া হবে।',
            style: AppTextStyles.bodySecondary.copyWith(height: 1.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              AppChip(
                label: hasCrop ? 'ফসল: $selectedCropName' : 'ফসল প্রয়োজন',
                icon: hasCrop ? Icons.check_rounded : Icons.error_outline_rounded,
                tint: hasCrop ? AppColors.tintGreen : AppColors.tintRed,
                color: hasCrop ? AppColors.primary : AppColors.danger,
              ),
              AppChip(
                label: hasImage ? 'ছবি যোগ হয়েছে' : 'ছবি ঐচ্ছিক',
                icon: hasImage ? Icons.check_rounded : Icons.image_outlined,
                tint: hasImage ? AppColors.tintGreen : AppColors.tintSlate,
                color: hasImage ? AppColors.primary : AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: analyzing ? AppStrings.analyzing : 'বিশ্লেষণ শুরু করুন',
            icon: Icons.auto_awesome,
            loading: analyzing,
            onPressed: canAnalyze ? onAnalyze : null,
          ),
          if (!canAnalyze && !analyzing) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              hasCrop
                  ? 'চালিয়ে যেতে প্রস্তুত'
                  : 'একটি ফসল নির্বাচন করুন',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _NoCropsHint extends StatelessWidget {
  const _NoCropsHint();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.eco_outlined, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            AppStrings.needFarmFirst,
            style: AppTextStyles.body,
          ),
        ),
      ],
    );
  }
}

class _SafetyNote extends StatelessWidget {
  const _SafetyNote();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_outlined,
              size: 18, color: AppColors.warning),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              AppStrings.aiDisclaimer,
              style: AppTextStyles.caption.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline text+icon button used in the AI sub-header. Lives here to avoid
/// touching the shared `PrimaryButton`/`AppTextButton` shape for one-off use.
class AppTextButtonInline extends StatelessWidget {
  const AppTextButtonInline({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
  });
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16),
            const SizedBox(width: 4),
          ],
          Text(label, style: AppTextStyles.button.copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}
