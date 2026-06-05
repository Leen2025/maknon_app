import '../../../../core/services/notification_service.dart';
import '../../../receipts/domain/entities/receipt.dart';

/// Schedules reminders for a receipt's return and exchange deadlines.
/// Each tag (return/exchange) gets its own pre-deadline notification (3 days
/// before) plus a same-day notification.
class ScheduleRemindersForReceipt {
  ScheduleRemindersForReceipt(this._notifications);

  final NotificationService _notifications;

  static const _tags = ['receipt_return_pre', 'receipt_return_day',
      'receipt_exchange_pre', 'receipt_exchange_day'];

  Future<void> call(Receipt r) async {
    // Cancel any old reminders before re-scheduling.
    await cancel(r.id);

    Future<void> schedulePair({
      required String preTag,
      required String dayTag,
      required DateTime? deadline,
      required String label,
    }) async {
      if (deadline == null) return;
      final threeDaysBefore = deadline.subtract(const Duration(days: 3));
      final preWhen = DateTime(
        threeDaysBefore.year,
        threeDaysBefore.month,
        threeDaysBefore.day,
        9,
      );
      final dayWhen = DateTime(deadline.year, deadline.month, deadline.day, 9);

      await _notifications.schedule(
        id: NotificationService.idFor(r.id, preTag),
        title: 'تذكير $label',
        body: 'تبقى ٣ أيام على $label لـ ${r.merchant}',
        when: preWhen,
        payload: 'receipt:${r.id}',
      );
      await _notifications.schedule(
        id: NotificationService.idFor(r.id, dayTag),
        title: '$label اليوم',
        body: 'اليوم آخر يوم لـ$label من ${r.merchant}',
        when: dayWhen,
        payload: 'receipt:${r.id}',
      );
    }

    await schedulePair(
      preTag: 'receipt_return_pre',
      dayTag: 'receipt_return_day',
      deadline: r.returnDeadline,
      label: 'الإرجاع',
    );
    await schedulePair(
      preTag: 'receipt_exchange_pre',
      dayTag: 'receipt_exchange_day',
      deadline: r.exchangeDeadline,
      label: 'الاستبدال',
    );
  }

  Future<void> cancel(String receiptId) async {
    for (final tag in _tags) {
      await _notifications.cancel(NotificationService.idFor(receiptId, tag));
    }
  }
}
