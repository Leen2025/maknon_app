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
import '../../../../core/utils/date_picker_helper.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/image_picker_sheet.dart';
import '../../domain/entities/warranty.dart';
import '../cubit/warranties_cubit.dart';

class WarrantyFormPage extends StatefulWidget {
  const WarrantyFormPage({super.key, this.warrantyId});
  final String? warrantyId;

  @override
  State<WarrantyFormPage> createState() => _WarrantyFormPageState();
}

class _WarrantyFormPageState extends State<WarrantyFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _productCtrl = TextEditingController();
  final _merchantCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 365));
  String? _imagePath;
  bool _saving = false;

  bool get _isEditing => widget.warrantyId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _hydrate();
  }

  void _hydrate() {
    final w = context
        .read<WarrantiesCubit>()
        .state
        .warranties
        .where((x) => x.id == widget.warrantyId)
        .firstOrNull;
    if (w == null) return;
    _productCtrl.text = w.productName;
    _merchantCtrl.text = w.merchant ?? '';
    _notesCtrl.text = w.notes ?? '';
    _startDate = w.startDate;
    _endDate = w.endDate;
    _imagePath = w.imagePath;
  }

  @override
  void dispose() {
    _productCtrl.dispose();
    _merchantCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final p = await ImagePickerSheet.show(context, sl<ImageStorageService>());
    if (p != null) setState(() => _imagePath = p);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تاريخ الانتهاء يجب أن يكون بعد البداية')),
      );
      return;
    }
    setState(() => _saving = true);
    final w = Warranty(
      id: widget.warrantyId ?? const Uuid().v4(),
      productName: _productCtrl.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      merchant: _merchantCtrl.text.trim().isEmpty
          ? null
          : _merchantCtrl.text.trim(),
      imagePath: _imagePath,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    await context.read<WarrantiesCubit>().saveWarranty(w);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: _isEditing ? AppStrings.editWarranty : AppStrings.addWarranty,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.border, width: 0.6),
                ),
                clipBehavior: Clip.antiAlias,
                child: _imagePath == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined,
                              color: AppColors.primary, size: 32),
                          SizedBox(height: AppSpacing.sm),
                          Text(AppStrings.warrantyImage,
                              style:
                                  TextStyle(color: AppColors.textSecondary)),
                        ],
                      )
                    : Image.file(File(_imagePath!), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: AppStrings.productName,
              controller: _productCtrl,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? AppStrings.required
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: '${AppStrings.merchant} (${AppStrings.optional})',
              controller: _merchantCtrl,
            ),
            const SizedBox(height: AppSpacing.md),
            _DateRow(
              label: AppStrings.startDate,
              value: _startDate,
              onTap: () async {
                final d = await DatePickerHelper.pick(
                    context: context, initial: _startDate);
                if (d != null) setState(() => _startDate = d);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _DateRow(
              label: AppStrings.endDate,
              value: _endDate,
              onTap: () async {
                final d = await DatePickerHelper.pick(
                    context: context, initial: _endDate);
                if (d != null) setState(() => _endDate = d);
              },
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

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
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
                Text(DateUtilsX.formatArabic(value),
                    style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
