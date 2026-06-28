import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/image_storage_service.dart';
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
    required ImageStorageService imageStorage,
  })  : _getAll = getAll,
        _save = save,
        _delete = delete,
        _schedule = scheduleReminders,
        _imageStorage = imageStorage,
        super(const WarrantiesState());

  final GetAllWarranties _getAll;
  final SaveWarranty _save;
  final DeleteWarranty _delete;
  final ScheduleRemindersForWarranty _schedule;
  final ImageStorageService _imageStorage;

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
    final w = state.warranties.where((x) => x.id == id).firstOrNull;
    await _delete(id);
    await _schedule.cancel(id);
    await _imageStorage.delete(w?.imagePath);
    await load();
  }
}
