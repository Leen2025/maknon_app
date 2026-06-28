import 'dart:io';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_strings.dart';

/// Shows a stored image in full (never cropped) inside a detail page.
/// Tapping it opens the full-screen zoomable viewer via [onTap].
class DetailImage extends StatelessWidget {
  const DetailImage({
    super.key,
    required this.imagePath,
    required this.heroTag,
    required this.onTap,
  });

  final String imagePath;
  final String heroTag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                minHeight: 180,
                maxHeight: 340,
              ),
              color: AppColors.primarySoft,
              child: Hero(
                tag: heroTag,
                child: Image.file(
                  File(imagePath),
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox(
                    height: 180,
                    child: Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.textMuted,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // "Tap to zoom" hint chip (bottom-end).
            PositionedDirectional(
              bottom: AppSpacing.sm,
              end: AppSpacing.sm,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.zoom_in, color: AppColors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      AppStrings.tapToView,
                      style: TextStyle(color: AppColors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
