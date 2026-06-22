import '../../../../core/services/notification_service.dart';
import '../../../subscriptions/domain/entities/subscription.dart';

class ScheduleRemindersForSubscription {
  ScheduleRemindersForSubscription(this._notifications);
  final NotificationService _notifications;

  static const _tags = ['sub_3', 'sub_day'];

  Future<void> call(Subscription s) async {
    await cancel(s.id);

    DateTime at9am(DateTime date) =>
        DateTime(date.year, date.month, date.day, 9);

    final reminders = [
      (
        tag: 'sub_3',
        when: at9am(s.nextRenewalDate.subtract(const Duration(days: 3))),
        title: 'تجديد قادم',
        body: 'سيتم تجديد اشتراك ${s.name} خلال ٣ أيام',
      ),
      (
        tag: 'sub_day',
        when: at9am(s.nextRenewalDate),
        title: 'تجديد اليوم',
        body: 'سيتم تجديد اشتراك ${s.name} اليوم',
      ),
    ];

    for (final r in reminders) {
      await _notifications.schedule(
        id: NotificationService.idFor(s.id, r.tag),
        title: r.title,
        body: r.body,
        when: r.when,
        payload: 'subscription:${s.id}',
      );
    }
  }

  Future<void> cancel(String subId) async {
    for (final tag in _tags) {
      await _notifications.cancel(NotificationService.idFor(subId, tag));
    }
  }
}
