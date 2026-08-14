import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/farm.dart';
import '../../providers/app_providers.dart';

const _uuid = Uuid();

class AddFarmScreen extends ConsumerStatefulWidget {
  const AddFarmScreen({super.key});

  @override
  ConsumerState<AddFarmScreen> createState() => _AddFarmScreenState();
}

class _AddFarmScreenState extends ConsumerState<AddFarmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _location = TextEditingController();
  final _size = TextEditingController(text: '1.0');
  final _notes = TextEditingController();
  SoilType _soil = SoilType.loam;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _size.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final repo = await ref.read(farmRepoProvider.future);
      await repo.upsert(
        Farm(
          id: _uuid.v4(),
          name: _name.text.trim(),
          location: _location.text.trim(),
          sizeAcres: double.tryParse(_size.text.trim()) ?? 1.0,
          soilType: _soil,
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          createdAt: DateTime.now(),
        ),
      );
      ref.invalidate(farmsProvider);
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.addFarm),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            AppTextField(
              label: AppStrings.farmName,
              controller: _name,
              hint: AppStrings.farmNameHint,
                              validator: (v) => (v == null || v.trim().isEmpty) ? AppStrings.fieldRequired : null,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: AppStrings.farmLocation,
              controller: _location,
              hint: AppStrings.farmLocationHint,
                              validator: (v) => (v == null || v.trim().isEmpty) ? AppStrings.fieldRequired : null,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: AppStrings.farmSize,
              controller: _size,
              keyboardType: TextInputType.number,
                              validator: (v) => (v == null || v.trim().isEmpty) ? AppStrings.fieldRequired : null,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(AppStrings.soilType,
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in SoilType.values)
                  ChoiceChip(
                    label: Text(s.bangla),
                    selected: _soil == s,
                    onSelected: (_) => setState(() => _soil = s),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: AppStrings.notesOptional,
              controller: _notes,
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              onPressed: _saving ? null : _save,
              label: _saving ? AppStrings.saving : AppStrings.save,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}