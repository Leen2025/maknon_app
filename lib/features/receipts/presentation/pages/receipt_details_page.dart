import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/image_storage_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/countdown_badge.dart';
import '../../../../core/widgets/detail_image.dart';
import '../../../../core/widgets/full_screen_image_viewer.dart';
import '../../../../core/widgets/image_picker_sheet.dart';
import '../../domain/entities/receipt.dart';
import '../cubit/receipts_cubit.dart';
import '../cubit/receipts_state.dart';

class ReceiptDetailsPage extends StatelessWidget {
  const ReceiptDetailsPage({super.key, required this.id});

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
      await context.read<ReceiptsCubit>().deleteReceipt(id);
      if (context.mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: AppStrings.receipts,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => context.pushNamed(
            AppRoutes.receiptForm,
            queryParameters: {'id': id},
          ),
        ),
      ],
      body: BlocBuilder<ReceiptsCubit, ReceiptsState>(
        builder: (_, state) {
          final r = state.receipts.where((x) => x.id == id).firstOrNull;
          if (r == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return _DetailsBody(
            receipt: r,
            onDelete: () => _delete(context),
          );
        },
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({required this.receipt, required this.onDelete});

  final Receipt receipt;
  final VoidCallback onDelete;

  Future<void> _openImage(BuildContext context) async {
    final action = await FullScreenImageViewer.open(
      context,
      imagePath: receipt.imagePath!,
      heroTag: 'receipt-image-${receipt.id}',
    );
    if (action == null || !context.mounted) return;

    final cubit = context.read<ReceiptsCubit>();
    final messenger = ScaffoldMessenger.of(context);

    if (action == ImageViewerAction.replace) {
      final path =
          await ImagePickerSheet.show(context, sl<ImageStorageService>());
      if (path != null) {
        final oldPath = receipt.imagePath;
        await cubit.saveReceipt(receipt.copyWith(imagePath: path));
        await sl<ImageStorageService>().delete(oldPath);
      }
    } else if (action == ImageViewerAction.delete) {
      await sl<ImageStorageService>().delete(receipt.imagePath);
      await cubit.saveReceipt(_withoutImage(receipt));
      messenger.showSnackBar(
        const SnackBar(content: Text(AppStrings.imageDeleted)),
      );
    }
  }

  /// copyWith can't null out [imagePath], so rebuild explicitly.
  Receipt _withoutImage(Receipt r) => Receipt(
        id: r.id,
        merchant: r.merchant,
        amount: r.amount,
        purchaseDate: r.purchaseDate,
        returnDeadline: r.returnDeadline,
        exchangeDeadline: r.exchangeDeadline,
        imagePath: null,
        notes: r.notes,
      );

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        if (receipt.imagePath != null)
          DetailImage(
            imagePath: receipt.imagePath!,
            heroTag: 'receipt-image-${receipt.id}',
            onTap: () => _openImage(context),
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
              Text(receipt.merchant,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${CurrencyFormatter.format(receipt.amount)} ${AppStrings.sar}',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _Row(
                label: AppStrings.purchaseDate,
                value: DateUtilsX.formatArabic(receipt.purchaseDate),
              ),
              if (receipt.returnDeadline != null)
                _DeadlineRow(
                  label: AppStrings.returnDeadline,
                  date: receipt.returnDeadline!,
                ),
              if (receipt.exchangeDeadline != null)
                _DeadlineRow(
                  label: AppStrings.exchangeDeadline,
                  date: receipt.exchangeDeadline!,
                ),
              if (receipt.notes != null && receipt.notes!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                const Divider(),
                const SizedBox(height: AppSpacing.md),
                Text(AppStrings.notes,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(receipt.notes!,
                    style: Theme.of(context).textTheme.bodyLarge),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton.icon(
          icon: const Icon(Icons.delete_outline, color: AppColors.danger),
          label: const Text(
            AppStrings.delete,
            style: TextStyle(color: AppColors.danger),
          ),
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
            child: Text(label,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _DeadlineRow extends StatelessWidget {
  const _DeadlineRow({required this.label, required this.date});

  final String label;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            DateUtilsX.formatShort(date),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(width: AppSpacing.sm),
          CountdownBadge(target: date),
        ],
      ),
    );
  }
}
