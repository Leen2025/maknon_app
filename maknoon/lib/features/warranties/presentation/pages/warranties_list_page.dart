import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../cubit/warranties_cubit.dart';
import '../widgets/warranty_card.dart';

class WarrantiesListPage extends StatefulWidget {
  const WarrantiesListPage({super.key});

  @override
  State<WarrantiesListPage> createState() => _WarrantiesListPageState();
}

class _WarrantiesListPageState extends State<WarrantiesListPage> {
  @override
  void initState() {
    super.initState();
    context.read<WarrantiesCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: AppStrings.warranties,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        onPressed: () => context.pushNamed(AppRoutes.warrantyForm),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<WarrantiesCubit, WarrantiesState>(
        builder: (context, state) {
          if (state.status == WarrantiesStatus.initial ||
              state.status == WarrantiesStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == WarrantiesStatus.error) {
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
                    onPressed: () => context.read<WarrantiesCubit>().load(),
                    child: const Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }
          if (state.warranties.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.shield_outlined,
              title: AppStrings.noWarranties,
              message: AppStrings.noWarrantiesHint,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            itemCount: state.warranties.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (_, i) {
              final w = state.warranties[i];
              return WarrantyCard(
                warranty: w,
                onTap: () => context.pushNamed(
                  AppRoutes.warrantyDetails,
                  pathParameters: {'id': w.id},
                ),
              );
            },
          );
        },
      ),
    );
  }
}
