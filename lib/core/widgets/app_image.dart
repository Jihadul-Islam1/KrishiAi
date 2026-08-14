import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// A network/asset image with consistent placeholder and error fallback.
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.iconSize = 32,
  });

  final ImageProvider source;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.md);
    return ClipRRect(
      borderRadius: radius,
      child: Image(
        image: source,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: AppColors.surfaceVariant,
            alignment: Alignment.center,
            child: Icon(
              Icons.image_not_supported_outlined,
              size: iconSize,
              color: AppColors.textMuted,
            ),
          );
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height,
            color: AppColors.surfaceVariant,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      ),
    );
  }
}

/// A circular avatar with fallback initials.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 44,
  });

  final String name;
  final String? imageUrl;
  final double size;

  String _initials() {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(),
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}
