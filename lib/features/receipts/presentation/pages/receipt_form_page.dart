import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/services/image_storage_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_picker_helper.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/image_picker_sheet.dart';
import '../../domain/entities/receipt.dart';
import '../cubit/receipts_cubit.dart';

class ReceiptFormPage extends StatefulWidget {
  const ReceiptFormPage({super.key, this.receiptId});

  final String? receiptId;

  @override
  State<ReceiptFormPage> createState() => _ReceiptFormPageState();
}

class _ReceiptFormPageState extends State<ReceiptFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _merchantCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime _purchaseDate = DateTime.now();
  DateTime? _returnDeadline;
  DateTime? _exchangeDeadline;
  String? _imagePath;
  bool _saving = false;

  bool get _isEditing => widget.receiptId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _hydrate();
  }

  void _hydrate() {
    final r = context
        .read<ReceiptsCubit>()
        .state
        .receipts
        .where((x) => x.id == widget.receiptId)
        .firstOrNull;
    if (r == null) return;
    _merchantCtrl.text = r.merchant;
    _amountCtrl.text = CurrencyFormatter.plain(r.amount);
    _notesCtrl.text = r.notes ?? '';
    _purchaseDate = r.purchaseDate;
    _returnDeadline = r.returnDeadline;
    _exchangeDeadline = r.exchangeDeadline;
    _imagePath = r.imagePath;
  }

  @override
  void dispose() {
    _merchantCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required DateTime? initial,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final d = await DatePickerHelper.pick(context: context, initial: initial);
    if (d != null) onPicked(d);
  }

  Future<void> _pickImage() async {
    final path = await ImagePickerSheet.show(context, sl<ImageStorageService>());
    if (path != null) setState(() => _imagePath = path);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    final receipt = Receipt(
      id: widget.receiptId ?? const Uuid().v4(),
      merchant: _merchantCtrl.text.trim(),
      amount: amount,
      purchaseDate: _purchaseDate,
      returnDeadline: _returnDeadline,
      exchangeDeadline: _exchangeDeadline,
      imagePath: _imagePath,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    await context.read<ReceiptsCubit>().saveReceipt(receipt);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: _isEditing ? AppStrings.editReceipt : AppStrings.addReceipt,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            _ImagePicker(path: _imagePath, onTap: _pickImage),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: AppStrings.merchant,
              controller: _merchantCtrl,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? AppStrings.required
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: '${AppStrings.amount} (${AppStrings.sar})',
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final n = double.tryParse((v ?? '').trim());
                if (n == null || n < 0) return AppStrings.required;
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _DateField(
              label: AppStrings.purchaseDate,
              value: _purchaseDate,
              onTap: () => _pickDate(
                initial: _purchaseDate,
                onPicked: (d) => setState(() => _purchaseDate = d),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _DateField(
              label: AppStrings.returnDeadline,
              value: _returnDeadline,
              optional: true,
              onTap: () => _pickDate(
                initial: _returnDeadline,
                onPicked: (d) => setState(() => _returnDeadline = d),
              ),
              onClear: _returnDeadline == null
                  ? null
                  : () => setState(() => _returnDeadline = null),
            ),
            const SizedBox(height: AppSpacing.md),
            _DateField(
              label: AppStrings.exchangeDeadline,
              value: _exchangeDeadline,
              optional: true,
              onTap: () => _pickDate(
                initial: _exchangeDeadline,
                onPicked: (d) => setState(() => _exchangeDeadline = d),
              ),
              onClear: _exchangeDeadline == null
                  ? null
                  : () => setState(() => _exchangeDeadline = null),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: '${AppStrings.notes} (${AppStrings.optional})',
              controller: _notesCtrl,
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppPrimaryButton(
              label: AppStrings.save,
              icon: Icons.check,
              isLoading: _saving,
              onPressed: _saving ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePicker extends StatelessWidget {
  const _ImagePicker({required this.path, required this.onTap});

  final String? path;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border, width: 0.6),
        ),
        clipBehavior: Clip.antiAlias,
        child: path == null
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined,
                      color: AppColors.primary, size: 32),
                  SizedBox(height: AppSpacing.sm),
                  Text(AppStrings.receiptImage,
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              )
            : Image.file(
                File(path!),
                width: double.infinity,
                fit: BoxFit.contain,
              ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.optional = false,
    this.onClear,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final bool optional;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          optional ? '$label (${AppStrings.optional})' : label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 18, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    value == null
                        ? '—'
                        : DateUtilsX.formatArabic(value!),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                if (onClear != null)
                  GestureDetector(
                    onTap: onClear,
                    child: const Icon(Icons.close,
                        size: 18, color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
