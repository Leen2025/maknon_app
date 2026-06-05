import 'package:equatable/equatable.dart';

enum ReminderKind { returnDeadline, exchangeDeadline, warrantyExpiry, subscriptionRenewal }

class Reminder extends Equatable {
  const Reminder({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.due,
    required this.kind,
    required this.entityId,
  });

  final int id;
  final String title;
  final String subtitle;
  final DateTime due;
  final ReminderKind kind;
  final String entityId;

  @override
  List<Object?> get props => [id, title, subtitle, due, kind, entityId];
}
