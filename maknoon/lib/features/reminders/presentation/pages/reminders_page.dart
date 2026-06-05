import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/deadline_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../domain/entities/reminder.dart';
import '../cubit/reminders_cubit.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  @override
  void initState() {
    super.initState();
    context.read<RemindersCubit>().load();
  }

  ({IconData icon, Color color, Color bg}) _styleFor(ReminderKind k) {
    switch (k) {
      case ReminderKind.returnDeadline:
      case ReminderKind.exchangeDeadline:
        return (
          icon: Icons.history_outlined,
          color: AppColors.danger,
          bg: AppColors.dangerSoft,
        );
      case ReminderKind.warrantyExpiry:
        return (
          icon: Icons.shield_outlined,
          color: AppColors.success,
          bg: AppColors.successSoft,
        );
      case ReminderKind.subscriptionRenewal:
        return (
          icon: Icons.autorenew_outlined,
          color: AppColors.warning,
          bg: AppColors.warningSoft,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: AppStrings.reminders,
      body: BlocBuilder<RemindersCubit, RemindersState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.reminders.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.notifications_none_outlined,
              title: AppStrings.noReminders,
              message: AppStrings.noRemindersHint,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            itemCount: state.reminders.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (_, i) {
              final r = state.reminders[i];
              final s = _styleFor(r.kind);
              return DeadlineCard(
                title: r.title,
                subtitle:
                    '${r.subtitle} • ${DateUtilsX.formatShort(r.due)}',
                icon: s.icon,
                iconColor: s.color,
                iconBg: s.bg,
                deadline: r.due,
              );
            },
          );
        },
      ),
    );
  }
}
