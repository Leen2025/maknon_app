import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../reminders/domain/usecases/schedule_reminders_for_subscription.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/usecases/subscription_usecases.dart';

enum SubscriptionsStatus { initial, loading, loaded, error }

class SubscriptionsState extends Equatable {
  const SubscriptionsState({
    this.status = SubscriptionsStatus.initial,
    this.subscriptions = const [],
    this.errorMessage,
  });

  final SubscriptionsStatus status;
  final List<Subscription> subscriptions;
  final String? errorMessage;

  double get monthlyTotal => subscriptions.fold(
    0.0,
    (sum, s) => sum + s.monthlyCost,
  );

  SubscriptionsState copyWith({
    SubscriptionsStatus? status,
    List<Subscription>? subscriptions,
    String? errorMessage,
  }) {
    return SubscriptionsState(
      status: status ?? this.status,
      subscriptions: subscriptions ?? this.subscriptions,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, subscriptions, errorMessage];
}

class SubscriptionsCubit extends Cubit<SubscriptionsState> {
  SubscriptionsCubit({
    required GetAllSubscriptions getAll,
    required SaveSubscription save,
    required DeleteSubscription delete,
    required ScheduleRemindersForSubscription scheduleReminders,
  })  : _getAll = getAll,
        _save = save,
        _delete = delete,
        _schedule = scheduleReminders,
        super(const SubscriptionsState());

  final GetAllSubscriptions _getAll;
  final SaveSubscription _save;
  final DeleteSubscription _delete;
  final ScheduleRemindersForSubscription _schedule;

  Future<void> load() async {
    emit(state.copyWith(status: SubscriptionsStatus.loading));
    try {
      var list = await _getAll();

      // Roll forward any subscription whose renewal date has passed so the
      // total, dates, and notifications always reflect the next real cycle.
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      var advancedAny = false;
      for (final s in list) {
        if (s.nextRenewalDate.isBefore(today)) {
          final advanced =
              s.copyWith(nextRenewalDate: _nextRenewal(s, today));
          await _save(advanced);
          await _schedule(advanced);
          advancedAny = true;
        }
      }
      if (advancedAny) list = await _getAll();

      emit(state.copyWith(
        status: SubscriptionsStatus.loaded,
        subscriptions: list,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SubscriptionsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Advances [s]'s renewal date by whole cycles until it lands on or after
  /// [today].
  DateTime _nextRenewal(Subscription s, DateTime today) {
    var d = s.nextRenewalDate;
    while (d.isBefore(today)) {
      d = s.cycle == BillingCycle.monthly
          ? DateTime(d.year, d.month + 1, d.day)
          : DateTime(d.year + 1, d.month, d.day);
    }
    return d;
  }

  Future<void> saveSubscription(Subscription s) async {
    await _save(s);
    await _schedule(s);
    await load();
  }

  Future<void> deleteSubscription(String id) async {
    await _delete(id);
    await _schedule.cancel(id);
    await load();
  }
}
