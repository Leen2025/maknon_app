import 'package:hive/hive.dart';

import '../../../../core/constants/hive_boxes.dart';
import '../../domain/entities/receipt.dart';

class ReceiptModel {
  ReceiptModel({
    required this.id,
    required this.merchant,
    required this.amount,
    required this.purchaseDate,
    this.returnDeadline,
    this.exchangeDeadline,
    this.imagePath,
    this.notes,
  });

  final String id;
  final String merchant;
  final double amount;
  final DateTime purchaseDate;
  final DateTime? returnDeadline;
  final DateTime? exchangeDeadline;
  final String? imagePath;
  final String? notes;

  factory ReceiptModel.fromEntity(Receipt r) => ReceiptModel(
    id: r.id,
    merchant: r.merchant,
    amount: r.amount,
    purchaseDate: r.purchaseDate,
    returnDeadline: r.returnDeadline,
    exchangeDeadline: r.exchangeDeadline,
    imagePath: r.imagePath,
    notes: r.notes,
  );

  Receipt toEntity() => Receipt(
    id: id,
    merchant: merchant,
    amount: amount,
    purchaseDate: purchaseDate,
    returnDeadline: returnDeadline,
    exchangeDeadline: exchangeDeadline,
    imagePath: imagePath,
    notes: notes,
  );
}

class ReceiptModelAdapter extends TypeAdapter<ReceiptModel> {
  @override
  final int typeId = HiveTypeIds.receipt;

  @override
  ReceiptModel read(BinaryReader reader) {
    final map = Map<String, dynamic>.from(reader.readMap());
    return ReceiptModel(
      id: map['id'] as String,
      merchant: map['merchant'] as String,
      amount: (map['amount'] as num).toDouble(),
      purchaseDate: DateTime.fromMillisecondsSinceEpoch(
        map['purchaseDate'] as int,
      ),
      returnDeadline: map['returnDeadline'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['returnDeadline'] as int),
      exchangeDeadline: map['exchangeDeadline'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              map['exchangeDeadline'] as int,
            ),
      imagePath: map['imagePath'] as String?,
      notes: map['notes'] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ReceiptModel obj) {
    writer.writeMap({
      'id': obj.id,
      'merchant': obj.merchant,
      'amount': obj.amount,
      'purchaseDate': obj.purchaseDate.millisecondsSinceEpoch,
      'returnDeadline': obj.returnDeadline?.millisecondsSinceEpoch,
      'exchangeDeadline': obj.exchangeDeadline?.millisecondsSinceEpoch,
      'imagePath': obj.imagePath,
      'notes': obj.notes,
    });
  }
}
