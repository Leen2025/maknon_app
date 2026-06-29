import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/number_input_formatter.dart';
import '../../../../core/utils/date_picker_helper.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/subscription.dart';
import '../cubit/subscriptions_cubit.dart';

class SubscriptionFormPage extends StatefulWidget {
  const SubscriptionFormPage({super.key, this.subscriptionId});
  final String? subscriptionId;

  @override
  State<SubscriptionFormPage> createState() => _SubscriptionFormPageState();
}

class _SubscriptionFormPageState extends State<SubscriptionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  BillingCycle _cycle = BillingCycle.monthly;
  DateTime _renewal = DateTime.now().add(const Duration(days: 30));
  bool _saving = false;

  bool get _isEditing => widget.subscriptionId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _hydrate();
  }

  void _hydrate() {
    final s = context
        .read<SubscriptionsCubit>()
        .state
        .subscriptions
        .where((x) => x.id == widget.subscriptionId)
        .firstOrNull;
    if (s == null) return;
    _nameCtrl.text = s.name;
    _priceCtrl.text = CurrencyFormatter.plain(s.price);
    _notesCtrl.text = s.notes ?? '';
    _cycle = s.cycle;
    _renewal = s.nextRenewalDate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final s = Subscription(
      id: widget.subscriptionId ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text.trim()) ?? 0,
      cycle: _cycle,
      nextRenewalDate: _renewal,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    await context.read<SubscriptionsCubit>().saveSubscription(s);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title:
          _isEditing ? AppStrings.editSubscription : AppStrings.addSubscription,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: [
            AppTextField(
              label: AppStrings.subscriptionName,
              controller: _nameCtrl,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? AppStrings.required
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: '${AppStrings.price} (${AppStrings.sar})',
              controller: _priceCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: const [ArabicDigitsFormatter()],
              validator: (v) {
                final n = double.tryParse((v ?? '').trim());
                if (n == null || n < 0) return AppStrings.required;
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _CycleSelector(
              value: _cycle,
              onChanged: (c) => setState(() => _cycle = c),
            ),
            const SizedBox(height: AppSpacing.md),
            _DateRow(
              label: AppStrings.renewalDate,
              value: _renewal,
              onTap: () async {
                final d = await DatePickerHelper.pick(
                    context: context, initial: _renewal);
                if (d != null) setState(() => _renewal = d);
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

class _CycleSelector extends StatelessWidget {
  const _CycleSelector({required this.value, required this.onChanged});

  final BillingCycle value;
  final ValueChanged<BillingCycle> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.billingCycle,
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _CycleChip(
                label: AppStrings.monthly,
                selected: value == BillingCycle.monthly,
                onTap: () => onChanged(BillingCycle.monthly),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _CycleChip(
                label: AppStrings.yearly,
                selected: value == BillingCycle.yearly,
                onTap: () => onChanged(BillingCycle.yearly),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CycleChip extends StatelessWidget {
  const _CycleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
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
