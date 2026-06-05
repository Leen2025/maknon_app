import 'package:equatable/equatable.dart';

enum BillingCycle { monthly, yearly }

class Subscription extends Equatable {
  const Subscription({
    required this.id,
    required this.name,
    required this.price,
    required this.cycle,
    required this.nextRenewalDate,
    this.notes,
  });

  final String id;
  final String name;
  final double price;
  final BillingCycle cycle;
  final DateTime nextRenewalDate;
  final String? notes;

  /// Normalized monthly cost — used for the dashboard total.
  double get monthlyCost =>
      cycle == BillingCycle.monthly ? price : price / 12.0;

  Subscription copyWith({
    String? id,
    String? name,
    double? price,
    BillingCycle? cycle,
    DateTime? nextRenewalDate,
    String? notes,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      cycle: cycle ?? this.cycle,
      nextRenewalDate: nextRenewalDate ?? this.nextRenewalDate,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [id, name, price, cycle, nextRenewalDate, notes];
}
