import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/image_storage_service.dart';
import '../../../reminders/domain/usecases/schedule_reminders_for_receipt.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/usecases/receipt_usecases.dart';
import 'receipts_state.dart';

class ReceiptsCubit extends Cubit<ReceiptsState> {
  ReceiptsCubit({
    required GetAllReceipts getAllReceipts,
    required SaveReceipt saveReceipt,
    required DeleteReceipt deleteReceipt,
    required ScheduleRemindersForReceipt scheduleReminders,
    required ImageStorageService imageStorage,
  })  : _getAll = getAllReceipts,
        _save = saveReceipt,
        _delete = deleteReceipt,
        _scheduleReminders = scheduleReminders,
        _imageStorage = imageStorage,
        super(const ReceiptsState());

  final GetAllReceipts _getAll;
  final SaveReceipt _save;
  final DeleteReceipt _delete;
  final ScheduleRemindersForReceipt _scheduleReminders;
  final ImageStorageService _imageStorage;

  Future<void> load() async {
    emit(state.copyWith(status: ReceiptsStatus.loading));
    try {
      final list = await _getAll();
      emit(state.copyWith(status: ReceiptsStatus.loaded, receipts: list));
    } catch (e) {
      emit(state.copyWith(
        status: ReceiptsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> saveReceipt(Receipt r) async {
    await _save(r);
    await _scheduleReminders(r);
    await load();
  }

  Future<void> deleteReceipt(String id) async {
    final r = state.receipts.where((x) => x.id == id).firstOrNull;
    await _delete(id);
    await _scheduleReminders.cancel(id);
    await _imageStorage.delete(r?.imagePath);
    await load();
  }
}
