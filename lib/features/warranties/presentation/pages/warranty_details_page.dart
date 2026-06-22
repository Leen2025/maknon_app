import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/countdown_badge.dart';
import '../../domain/entities/warranty.dart';
import '../cubit/warranties_cubit.dart';

class WarrantyDetailsPage extends StatelessWidget {
  const WarrantyDetailsPage({super.key, required this.id});
  final String id;

  Future<void> _delete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dlg) => AlertDialog(
        content: const Text(AppStrings.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlg, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dlg, true),
            child: const Text(
              AppStrings.delete,
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<WarrantiesCubit>().deleteWarranty(id);
      if (context.mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: AppStrings.warranties,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => context.pushNamed(
            AppRoutes.warrantyForm,
            queryParameters: {'id': id},
          ),
        ),
      ],
      body: BlocBuilder<WarrantiesCubit, WarrantiesState>(
        builder: (_, state) {
          final w = state.warranties.where((x) => x.id == id).firstOrNull;
          if (w == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return _Body(
            warranty: w,
            onDelete: () => _delete(context),
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.warranty, required this.onDelete});
  final Warranty warranty;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        if (warranty.imagePath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Image.file(
              File(warranty.imagePath!),
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.border, width: 0.6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      warranty.productName,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  CountdownBadge(target: warranty.endDate),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (warranty.merchant != null && warranty.merchant!.isNotEmpty)
                _Row(
                  label: AppStrings.merchant,
                  value: warranty.merchant!,
                ),
              _Row(
                label: AppStrings.startDate,
                value: DateUtilsX.formatArabic(warranty.startDate),
              ),
              _Row(
                label: AppStrings.endDate,
                value: DateUtilsX.formatArabic(warranty.endDate),
              ),
              if (warranty.notes != null && warranty.notes!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                const Divider(),
                const SizedBox(height: AppSpacing.md),
                Text(AppStrings.notes,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(warranty.notes!,
                    style: Theme.of(context).textTheme.bodyLarge),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton.icon(
          icon: const Icon(Icons.delete_outline, color: AppColors.danger),
          label: const Text(AppStrings.delete,
              style: TextStyle(color: AppColors.danger)),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            side: const BorderSide(color: AppColors.danger),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
          onPressed: onDelete,
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child:
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
