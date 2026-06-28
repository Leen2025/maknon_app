import 'dart:io';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_strings.dart';

/// Action the user chose while viewing an image full-screen.
enum ImageViewerAction { replace, delete }

/// Full-screen, pinch-to-zoom image viewer with optional replace / delete
/// actions. Pops with an [ImageViewerAction] when the user taps one of the
/// bottom buttons; pops with `null` when simply dismissed.
class FullScreenImageViewer extends StatelessWidget {
  const FullScreenImageViewer({
    super.key,
    required this.imagePath,
    required this.heroTag,
    this.allowEditing = true,
  });

  final String imagePath;
  final String heroTag;
  final bool allowEditing;

  static Future<ImageViewerAction?> open(
    BuildContext context, {
    required String imagePath,
    required String heroTag,
    bool allowEditing = true,
  }) {
    return Navigator.of(context).push<ImageViewerAction>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => FullScreenImageViewer(
          imagePath: imagePath,
          heroTag: heroTag,
          allowEditing: allowEditing,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Zoomable image, fills available space.
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Center(
                  child: Hero(
                    tag: heroTag,
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.white,
                        size: 64,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Close button (top-start).
            PositionedDirectional(
              top: AppSpacing.sm,
              start: AppSpacing.sm,
              child: _CircleButton(
                icon: Icons.close,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),

            // Replace / delete actions.
            if (allowEditing)
              Positioned(
                left: 0,
                right: 0,
                bottom: AppSpacing.xl,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ActionPill(
                      icon: Icons.image_outlined,
                      label: AppStrings.changeImage,
                      onTap: () => Navigator.of(context)
                          .pop(ImageViewerAction.replace),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _ActionPill(
                      icon: Icons.delete_outline,
                      label: AppStrings.deleteImage,
                      danger: true,
                      onTap: () =>
                          Navigator.of(context).pop(ImageViewerAction.delete),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.4),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(icon, color: AppColors.white),
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.white;
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
