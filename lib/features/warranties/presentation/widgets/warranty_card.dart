import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/countdown_badge.dart';
import '../../domain/entities/warranty.dart';

class WarrantyCard extends StatelessWidget {
  const WarrantyCard({super.key, required this.warranty, this.onTap});

  final Warranty warranty;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.border, width: 0.6),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
                ),
                child: const Icon(Icons.shield_outlined,
                    color: AppColors.success, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      warranty.productName,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ينتهي في ${DateUtilsX.formatShort(warranty.endDate)}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              CountdownBadge(target: warranty.endDate),
            ],
          ),
        ),
      ),
    );
  }
}
