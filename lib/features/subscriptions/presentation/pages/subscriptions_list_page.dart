import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../cubit/subscriptions_cubit.dart';
import '../widgets/subscription_card.dart';

class SubscriptionsListPage extends StatefulWidget {
  const SubscriptionsListPage({super.key});

  @override
  State<SubscriptionsListPage> createState() => _SubscriptionsListPageState();
}

class _SubscriptionsListPageState extends State<SubscriptionsListPage> {
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: AppStrings.subscriptions,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        onPressed: () => context.pushNamed(AppRoutes.subscriptionForm),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<SubscriptionsCubit, SubscriptionsState>(
        builder: (context, state) {
          if (state.status == SubscriptionsStatus.initial ||
              state.status == SubscriptionsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == SubscriptionsStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.errorMessage ?? AppStrings.genericError,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () =>
                        context.read<SubscriptionsCubit>().load(),
                    child: const Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }
          if (state.subscriptions.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.autorenew_outlined,
              title: AppStrings.noSubscriptions,
              message: AppStrings.noSubscriptionsHint,
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            children: [
              _MonthlyTotalCard(total: state.monthlyTotal),
              const SizedBox(height: AppSpacing.lg),
              ...state.subscriptions.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: SubscriptionCard(
                    subscription: s,
                    onTap: () => context.pushNamed(
                      AppRoutes.subscriptionDetails,
                      pathParameters: {'id': s.id},
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MonthlyTotalCard extends StatelessWidget {
  const _MonthlyTotalCard({required this.total});
  final double total;

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
                CurrencyFormatter.format(total),
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
        ],
      ),
    );
  }
}
