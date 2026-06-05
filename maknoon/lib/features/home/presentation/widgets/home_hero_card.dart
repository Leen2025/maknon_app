import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';

class HomeHeroCard extends StatelessWidget {
  const HomeHeroCard({
    super.key,
    required this.monthlyTotal,
    required this.receiptsCount,
    required this.warrantiesCount,
    required this.subscriptionsCount,
  });

  final double monthlyTotal;
  final int receiptsCount;
  final int warrantiesCount;
  final int subscriptionsCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.totalMonthlySubs,
            style: TextStyle(color: AppColors.goldSoft, fontSize: 12),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                CurrencyFormatter.format(monthlyTotal),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                AppStrings.sar,
                style: TextStyle(color: AppColors.gold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            height: 0.6,
            color: AppColors.goldSoft.withValues(alpha: 0.25),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _Stat(value: receiptsCount, label: AppStrings.navReceipts),
              _Divider(),
              _Stat(value: warrantiesCount, label: AppStrings.navWarranties),
              _Divider(),
              _Stat(
                value: subscriptionsCount,
                label: AppStrings.navSubscriptions,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.goldSoft, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.6,
      height: 28,
      color: AppColors.goldSoft.withValues(alpha: 0.25),
    );
  }
}
