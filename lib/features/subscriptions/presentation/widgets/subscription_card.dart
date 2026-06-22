import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/countdown_badge.dart';
import '../../domain/entities/subscription.dart';

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({super.key, required this.subscription, this.onTap});

  final Subscription subscription;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cycleLabel = subscription.cycle == BillingCycle.monthly
        ? AppStrings.monthly
        : AppStrings.yearly;
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
                  color: AppColors.warningSoft,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
                ),
                child: const Icon(Icons.autorenew_outlined,
                    color: AppColors.warning, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.name,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${CurrencyFormatter.format(subscription.price)} ${AppStrings.sar} • $cycleLabel',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              CountdownBadge(target: subscription.nextRenewalDate),
            ],
          ),
        ),
      ),
    );
  }
}
