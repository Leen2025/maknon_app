import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../utils/date_utils.dart';

enum CountdownTone { neutral, warning, danger, success }

class CountdownBadge extends StatelessWidget {
  const CountdownBadge({
    super.key,
    required this.target,
  });

  final DateTime target;

  CountdownTone get _tone {
    final days = DateUtilsX.daysUntil(target);
    if (days < 0) return CountdownTone.danger;
    if (days <= 3) return CountdownTone.danger;
    if (days <= 14) return CountdownTone.warning;
    return CountdownTone.success;
  }

  ({Color bg, Color fg}) _palette() {
    switch (_tone) {
      case CountdownTone.danger:
        return (bg: AppColors.dangerSoft, fg: AppColors.danger);
      case CountdownTone.warning:
        return (bg: AppColors.warningSoft, fg: AppColors.warning);
      case CountdownTone.success:
        return (bg: AppColors.successSoft, fg: AppColors.success);
      case CountdownTone.neutral:
        return (bg: AppColors.sandMuted, fg: AppColors.textSecondary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: palette.bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        DateUtilsX.countdownLabel(target),
        style: TextStyle(
          color: palette.fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
