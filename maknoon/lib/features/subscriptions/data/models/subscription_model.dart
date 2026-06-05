import 'package:hive/hive.dart';

import '../../../../core/constants/hive_boxes.dart';
import '../../domain/entities/subscription.dart';

class BillingCycleAdapter extends TypeAdapter<BillingCycle> {
  @override
  final int typeId = HiveTypeIds.billingCycle;

  @override
  BillingCycle read(BinaryReader reader) {
    final i = reader.readByte();
    return i == 1 ? BillingCycle.yearly : BillingCycle.monthly;
  }

  @override
  void write(BinaryWriter writer, BillingCycle obj) {
    writer.writeByte(obj == BillingCycle.yearly ? 1 : 0);
  }
}

class SubscriptionModel {
  SubscriptionModel({
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

  factory SubscriptionModel.fromEntity(Subscription s) => SubscriptionModel(
    id: s.id,
    name: s.name,
    price: s.price,
    cycle: s.cycle,
    nextRenewalDate: s.nextRenewalDate,
    notes: s.notes,
  );

  Subscription toEntity() => Subscription(
    id: id,
    name: name,
    price: price,
    cycle: cycle,
    nextRenewalDate: nextRenewalDate,
    notes: notes,
  );
}

class SubscriptionModelAdapter extends TypeAdapter<SubscriptionModel> {
  @override
  final int typeId = HiveTypeIds.subscription;

  @override
  SubscriptionModel read(BinaryReader reader) {
    final m = Map<String, dynamic>.from(reader.readMap());
    return SubscriptionModel(
      id: m['id'] as String,
      name: m['name'] as String,
      price: (m['price'] as num).toDouble(),
      cycle: (m['cycle'] as int) == 1
          ? BillingCycle.yearly
          : BillingCycle.monthly,
      nextRenewalDate: DateTime.fromMillisecondsSinceEpoch(
        m['nextRenewalDate'] as int,
      ),
      notes: m['notes'] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SubscriptionModel obj) {
    writer.writeMap({
      'id': obj.id,
      'name': obj.name,
      'price': obj.price,
      'cycle': obj.cycle == BillingCycle.yearly ? 1 : 0,
      'nextRenewalDate': obj.nextRenewalDate.millisecondsSinceEpoch,
      'notes': obj.notes,
    });
  }
}
