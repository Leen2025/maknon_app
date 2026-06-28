import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../receipts/domain/usecases/receipt_usecases.dart';
import '../../../reminders/domain/entities/reminder.dart';
import '../../../reminders/domain/reminder_builder.dart';
import '../../../subscriptions/domain/usecases/subscription_usecases.dart';
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
    final upcoming = ReminderBuilder.build(
      receipts: receipts,
      warranties: warranties,
      subscriptions: subs,
    ).take(3).toList();

    emit(state.copyWith(
      loading: false,
      receiptsCount: receipts.length,
      warrantiesCount: warranties.length,
      subscriptionsCount: subs.length,
      monthlyTotal: total,
      upcoming: upcoming,
    ));
  }
}
