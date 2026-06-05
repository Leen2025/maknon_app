import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../reminders/domain/usecases/schedule_reminders_for_warranty.dart';
import '../../domain/entities/warranty.dart';
import '../../domain/usecases/warranty_usecases.dart';

enum WarrantiesStatus { initial, loading, loaded, error }

class WarrantiesState extends Equatable {
  const WarrantiesState({
    this.status = WarrantiesStatus.initial,
    this.warranties = const [],
    this.errorMessage,
  });

  final WarrantiesStatus status;
  final List<Warranty> warranties;
  final String? errorMessage;

  WarrantiesState copyWith({
    WarrantiesStatus? status,
    List<Warranty>? warranties,
    String? errorMessage,
  }) {
    return WarrantiesState(
      status: status ?? this.status,
      warranties: warranties ?? this.warranties,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, warranties, errorMessage];
}

class WarrantiesCubit extends Cubit<WarrantiesState> {
  WarrantiesCubit({
    required GetAllWarranties getAll,
    required SaveWarranty save,
    required DeleteWarranty delete,
    required ScheduleRemindersForWarranty scheduleReminders,
  })  : _getAll = getAll,
        _save = save,
        _delete = delete,
        _schedule = scheduleReminders,
        super(const WarrantiesState());

  final GetAllWarranties _getAll;
  final SaveWarranty _save;
  final DeleteWarranty _delete;
  final ScheduleRemindersForWarranty _schedule;

  Future<void> load() async {
    emit(state.copyWith(status: WarrantiesStatus.loading));
    try {
      final list = await _getAll();
      emit(state.copyWith(status: WarrantiesStatus.loaded, warranties: list));
    } catch (e) {
      emit(state.copyWith(
        status: WarrantiesStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> saveWarranty(Warranty w) async {
    await _save(w);
    await _schedule(w);
    await load();
  }

  Future<void> deleteWarranty(String id) async {
    await _delete(id);
    await _schedule.cancel(id);
    await load();
  }
}
