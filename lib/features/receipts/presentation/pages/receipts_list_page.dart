import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../cubit/receipts_cubit.dart';
import '../cubit/receipts_state.dart';
import '../widgets/receipt_card.dart';

class ReceiptsListPage extends StatefulWidget {
  const ReceiptsListPage({super.key});

  @override
  State<ReceiptsListPage> createState() => _ReceiptsListPageState();
}

class _ReceiptsListPageState extends State<ReceiptsListPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReceiptsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: AppStrings.receipts,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        onPressed: () => context.pushNamed(AppRoutes.receiptForm),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<ReceiptsCubit, ReceiptsState>(
        builder: (context, state) {
          if (state.status == ReceiptsStatus.initial ||
              state.status == ReceiptsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ReceiptsStatus.error) {
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
                    onPressed: () => context.read<ReceiptsCubit>().load(),
                    child: const Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }
          if (state.receipts.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              title: AppStrings.noReceipts,
              message: AppStrings.noReceiptsHint,
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<ReceiptsCubit>().load(),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.receipts.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) {
                final r = state.receipts[i];
                return ReceiptCard(
                  receipt: r,
                  onTap: () => context.pushNamed(
                    AppRoutes.receiptDetails,
                    pathParameters: {'id': r.id},
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
