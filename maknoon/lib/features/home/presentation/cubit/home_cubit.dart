import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../receipts/domain/entities/receipt.dart';
import '../../../receipts/domain/usecases/receipt_usecases.dart';
import '../../../reminders/domain/entities/reminder.dart';
import '../../../subscriptions/domain/entities/subscription.dart';
import '../../../subscriptions/domain/usecases/subscription_usecases.dart';
import '../../../warranties/domain/entities/warranty.dart';
import '../../../warranties/domain/usecases/warranty_usecases.dart';

class HomeState extends Equatable {
  const HomeState({
    this.loading = true,
    this.receiptsCount = 0,
    this.warrantiesCount = 0,
    this.subscriptionsCount = 0,
    this.monthlyTotal = 0,
    this.upcoming = const [],
  });

  final bool loading;
  final int receiptsCount;
  final int warrantiesCount;
  final int subscriptionsCount;
  final double monthlyTotal;
  final List<Reminder> upcoming;

  HomeState copyWith({
    bool? loading,
    int? receiptsCount,
    int? warrantiesCount,
    int? subscriptionsCount,
    double? monthlyTotal,
    List<Reminder>? upcoming,
  }) {
    return HomeState(
      loading: loading ?? this.loading,
      receiptsCount: receiptsCount ?? this.receiptsCount,
      warrantiesCount: warrantiesCount ?? this.warrantiesCount,
      subscriptionsCount: subscriptionsCount ?? this.subscriptionsCount,
      monthlyTotal: monthlyTotal ?? this.monthlyTotal,
      upcoming: upcoming ?? this.upcoming,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    receiptsCount,
    warrantiesCount,
    subscriptionsCount,
    monthlyTotal,
    upcoming,
  ];
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required GetAllReceipts getAllReceipts,
    required GetAllWarranties getAllWarranties,
    required GetAllSubscriptions getAllSubscriptions,
  })  : _receipts = getAllReceipts,
        _warranties = getAllWarranties,
        _subs = getAllSubscriptions,
        super(const HomeState());

  final GetAllReceipts _receipts;
  final GetAllWarranties _warranties;
  final GetAllSubscriptions _subs;

  Future<void> load() async {
    emit(state.copyWith(loading: true));

    final receipts = await _receipts();
    final warranties = await _warranties();
    final subs = await _subs();

    final total = subs.fold<double>(0, (s, sub) => s + sub.monthlyCost);
    final upcoming = _buildUpcoming(receipts, warranties, subs);

    emit(state.copyWith(
      loading: false,
      receiptsCount: receipts.length,
      warrantiesCount: warranties.length,
      subscriptionsCount: subs.length,
      monthlyTotal: total,
      upcoming: upcoming,
    ));
  }

  List<Reminder> _buildUpcoming(
    List<Receipt> receipts,
    List<Warranty> warranties,
    List<Subscription> subs,
  ) {
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month, now.day);
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
          subtitle: 'تاريخ التجديد',
          due: s.nextRenewalDate,
          kind: ReminderKind.subscriptionRenewal,
          entityId: s.id,
        ));
      }
    }

    all.sort((a, b) => a.due.compareTo(b.due));
    return all.take(3).toList();
  }
}
