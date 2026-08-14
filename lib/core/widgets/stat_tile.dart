import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'icon_badge.dart';

/// Compact stat tile with leading tinted icon, label, and value.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.delta,
    this.tint = AppColors.tintGreen,
    this.color = AppColors.primary,
  });
  final String label;
  final String value;
  final IconData? icon;
  final String? delta;
  final Color tint;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          IconBadge(icon: icon!, tint: tint, color: color, size: 36),
          const SizedBox(height: AppSpacing.md),
        ],
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: AppSpacing.xxs),
        Text(value, style: AppTextStyles.stat),
        if (delta != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(delta!, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
        ],
      ],
    );
  }
}
