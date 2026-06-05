import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/image_storage_service.dart';

class ImagePickerSheet {
  ImagePickerSheet._();

  static Future<String?> show(
    BuildContext context,
    ImageStorageService service,
  ) async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined,
                    color: AppColors.primary),
                title: const Text(AppStrings.pickFromGallery),
                onTap: () async {
                  final p = await service.pickAndStore(
                    source: ImageSource.gallery,
                  );
                  if (ctx.mounted) Navigator.pop(ctx, p);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined,
                    color: AppColors.primary),
                title: const Text(AppStrings.pickFromCamera),
                onTap: () async {
                  final p = await service.pickAndStore(
                    source: ImageSource.camera,
                  );
                  if (ctx.mounted) Navigator.pop(ctx, p);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
