import '../../../../core/services/notification_service.dart';
import '../../../warranties/domain/entities/warranty.dart';

class ScheduleRemindersForWarranty {
  ScheduleRemindersForWarranty(this._notifications);
  final NotificationService _notifications;

  static const _tags = ['warranty_30', 'warranty_7', 'warranty_day'];

  Future<void> call(Warranty w) async {
    await cancel(w.id);

    DateTime at9am(DateTime date) =>
        DateTime(date.year, date.month, date.day, 9);

    final reminders = [
      (
        tag: 'warranty_30',
        when: at9am(w.endDate.subtract(const Duration(days: 30))),
        title: 'الضمان ينتهي قريباً',
        body: 'يبقى ٣٠ يوم على انتهاء ضمان ${w.productName}',
      ),
      (
        tag: 'warranty_7',
        when: at9am(w.endDate.subtract(const Duration(days: 7))),
        title: 'الضمان ينتهي خلال أسبوع',
        body: 'يبقى ٧ أيام على انتهاء ضمان ${w.productName}',
      ),
      (
        tag: 'warranty_day',
        when: at9am(w.endDate),
        title: 'الضمان ينتهي اليوم',
        body: 'ضمان ${w.productName} ينتهي اليوم',
      ),
    ];

    for (final r in reminders) {
      await _notifications.schedule(
        id: NotificationService.idFor(w.id, r.tag),
        title: r.title,
        body: r.body,
        when: r.when,
        payload: 'warranty:${w.id}',
      );
    }
  }

  Future<void> cancel(String warrantyId) async {
    for (final tag in _tags) {
      await _notifications.cancel(NotificationService.idFor(warrantyId, tag));
    }
  }
}
