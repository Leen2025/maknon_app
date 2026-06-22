import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/countdown_badge.dart';
import '../../domain/entities/receipt.dart';

class ReceiptCard extends StatelessWidget {
  const ReceiptCard({
    super.key,
    required this.receipt,
    this.onTap,
  });

  final Receipt receipt;
  final VoidCallback? onTap;

  DateTime? get _nearestDeadline {
    final r = receipt.returnDeadline;
    final e = receipt.exchangeDeadline;
    if (r == null && e == null) return null;
    if (r == null) return e;
    if (e == null) return r;
    return r.isBefore(e) ? r : e;
  }

  @override
  Widget build(BuildContext context) {
    final deadline = _nearestDeadline;
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
                  color: AppColors.sandSoft,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.warning,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receipt.merchant,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${CurrencyFormatter.format(receipt.amount)} ${AppStrings.sar}  •  ${DateUtilsX.formatShort(receipt.purchaseDate)}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              if (deadline != null) ...[
                const SizedBox(width: AppSpacing.sm),
                CountdownBadge(target: deadline),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
