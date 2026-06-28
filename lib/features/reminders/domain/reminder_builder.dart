import '../../receipts/domain/entities/receipt.dart';
import '../../subscriptions/domain/entities/subscription.dart';
import '../../warranties/domain/entities/warranty.dart';
import 'entities/reminder.dart';

/// Builds the in-memory list of upcoming reminders shared by the Home and
/// Reminders views. Includes only items due today or later, sorted ascending.
class ReminderBuilder {
  ReminderBuilder._();

  static List<Reminder> build({
    required List<Receipt> receipts,
    required List<Warranty> warranties,
    required List<Subscription> subscriptions,
    DateTime? now,
  }) {
    final ref = now ?? DateTime.now();
    final cutoff = DateTime(ref.year, ref.month, ref.day);
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
      if (r.exchangeDeadline != null && !r.exchangeDeadline!.isBefore(cutoff)) {
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

    for (final s in subscriptions) {
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
    return all;
  }
}
