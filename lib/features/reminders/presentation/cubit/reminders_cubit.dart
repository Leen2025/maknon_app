import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../receipts/domain/usecases/receipt_usecases.dart';
import '../../../subscriptions/domain/usecases/subscription_usecases.dart';
import '../../../warranties/domain/usecases/warranty_usecases.dart';
import '../../domain/entities/reminder.dart';

class RemindersState extends Equatable {
  const RemindersState({this.reminders = const [], this.loading = false});

  final List<Reminder> reminders;
  final bool loading;

  RemindersState copyWith({List<Reminder>? reminders, bool? loading}) {
    return RemindersState(
      reminders: reminders ?? this.reminders,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [reminders, loading];
}

/// Builds an in-memory list of upcoming reminders from all data sources.
/// This is the view-model the Reminders page consumes — it doesn't manage
/// notifications themselves (that's done by the per-feature schedule use cases).
class RemindersCubit extends Cubit<RemindersState> {
  RemindersCubit({
    required GetAllReceipts getAllReceipts,
    required GetAllWarranties getAllWarranties,
    required GetAllSubscriptions getAllSubscriptions,
  })  : _receipts = getAllReceipts,
        _warranties = getAllWarranties,
        _subscriptions = getAllSubscriptions,
        super(const RemindersState());

  final GetAllReceipts _receipts;
  final GetAllWarranties _warranties;
  final GetAllSubscriptions _subscriptions;

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month, now.day);

    final receipts = await _receipts();
    final warranties = await _warranties();
    final subs = await _subscriptions();

    final all = <Reminder>[];

    for (final r in receipts) {
      if (r.returnDeadline != null && !r.returnDeadline!.isBefore(cutoff)) {
        all.add(Reminder(
          id: r.id.hashCode,
          title: 'إرجاع - ${r.merchant}',
          subtitle: 'آخر موعد للإرجاع',
          due: r.returnDeadline!,
          kind: ReminderKind.returnDeadline,
          entityId: r.id,
        ));
      }
      if (r.exchangeDeadline != null &&
          !r.exchangeDeadline!.isBefore(cutoff)) {
        all.add(Reminder(
          id: '${r.id}ex'.hashCode,
          title: 'استبدال - ${r.merchant}',
          subtitle: 'آخر موعد للاستبدال',
          due: r.exchangeDeadline!,
          kind: ReminderKind.exchangeDeadline,
          entityId: r.id,
        ));
      }
    }

    for (final w in warranties) {
      if (!w.endDate.isBefore(cutoff)) {
        all.add(Reminder(
          id: w.id.hashCode,
          title: 'ضمان - ${w.productName}',
          subtitle: 'انتهاء الضمان',
          due: w.endDate,
          kind: ReminderKind.warrantyExpiry,
          entityId: w.id,
        ));
      }
    }

    for (final s in subs) {
      if (!s.nextRenewalDate.isBefore(cutoff)) {
        all.add(Reminder(
          id: s.id.hashCode,
          title: 'تجديد - ${s.name}',
          subtitle: 'تاريخ التجديد القادم',
          due: s.nextRenewalDate,
          kind: ReminderKind.subscriptionRenewal,
          entityId: s.id,
        ));
      }
    }

    all.sort((a, b) => a.due.compareTo(b.due));
    emit(state.copyWith(reminders: all, loading: false));
  }
}
