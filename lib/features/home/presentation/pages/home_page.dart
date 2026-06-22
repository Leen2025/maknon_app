import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/deadline_card.dart';
import '../../../reminders/domain/entities/reminder.dart';
import '../cubit/home_cubit.dart';
import '../widgets/home_hero_card.dart';
import '../widgets/quick_action_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().load();
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
    return RefreshIndicator(
      onRefresh: () => context.read<HomeCubit>().load(),
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            children: [
              const _Header(),
              const SizedBox(height: AppSpacing.lg),
              HomeHeroCard(
                monthlyTotal: state.monthlyTotal,
                receiptsCount: state.receiptsCount,
                warrantiesCount: state.warrantiesCount,
                subscriptionsCount: state.subscriptionsCount,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSectionHeader(
                title: AppStrings.upcomingDeadlines,
                onSeeAll: () => context.goNamed(AppRoutes.reminders),
              ),
              if (state.upcoming.isEmpty)
                const _NoUpcoming()
              else
                ...state.upcoming.map((r) {
                  final s = _styleFor(r.kind);
                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: DeadlineCard(
                      title: r.title,
                      subtitle:
                          '${r.subtitle} • ${DateUtilsX.formatShort(r.due)}',
                      icon: s.icon,
                      iconColor: s.color,
                      iconBg: s.bg,
                      deadline: r.due,
                      onTap: () => _routeForReminder(context, r),
                    ),
                  );
                }),
              const SizedBox(height: AppSpacing.lg),
              const AppSectionHeader(title: AppStrings.quickAdd),
              Row(
                children: [
                  Expanded(
                    child: QuickActionTile(
                      label: AppStrings.newReceipt,
                      icon: Icons.receipt_long_outlined,
                      bg: AppColors.successSoft,
                      color: AppColors.primary,
                      onTap: () =>
                          context.pushNamed(AppRoutes.receiptForm),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: QuickActionTile(
                      label: AppStrings.newWarranty,
                      icon: Icons.shield_outlined,
                      bg: AppColors.warningSoft,
                      color: AppColors.warning,
                      onTap: () =>
                          context.pushNamed(AppRoutes.warrantyForm),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              QuickActionTile(
                label: AppStrings.newSubscription,
                icon: Icons.autorenew_outlined,
                bg: AppColors.sandSoft,
                color: AppColors.gold,
                onTap: () =>
                    context.pushNamed(AppRoutes.subscriptionForm),
              ),
            ],
          );
        },
      ),
    );
  }

  void _routeForReminder(BuildContext context, Reminder r) {
    switch (r.kind) {
      case ReminderKind.returnDeadline:
      case ReminderKind.exchangeDeadline:
        context.pushNamed(
          AppRoutes.receiptDetails,
          pathParameters: {'id': r.entityId},
        );
        break;
      case ReminderKind.warrantyExpiry:
        context.pushNamed(
          AppRoutes.warrantyDetails,
          pathParameters: {'id': r.entityId},
        );
        break;
      case ReminderKind.subscriptionRenewal:
        context.pushNamed(
          AppRoutes.subscriptionDetails,
          pathParameters: {'id': r.entityId},
        );
        break;
    }
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.appName,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 2),
        Text(
          AppStrings.welcomeText,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          AppStrings.tagline,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _NoUpcoming extends StatelessWidget {
  const _NoUpcoming();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border, width: 0.6),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.success),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'لا توجد مواعيد قريبة',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
