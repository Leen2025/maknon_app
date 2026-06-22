import 'package:hive/hive.dart';

import '../../../../core/constants/hive_boxes.dart';
import '../../domain/entities/warranty.dart';

class WarrantyModel {
  WarrantyModel({
    required this.id,
    required this.productName,
    required this.startDate,
    required this.endDate,
    this.merchant,
    this.imagePath,
    this.notes,
  });

  final String id;
  final String productName;
  final DateTime startDate;
  final DateTime endDate;
  final String? merchant;
  final String? imagePath;
  final String? notes;

  factory WarrantyModel.fromEntity(Warranty w) => WarrantyModel(
    id: w.id,
    productName: w.productName,
    startDate: w.startDate,
    endDate: w.endDate,
    merchant: w.merchant,
    imagePath: w.imagePath,
    notes: w.notes,
  );

  Warranty toEntity() => Warranty(
    id: id,
    productName: productName,
    startDate: startDate,
    endDate: endDate,
    merchant: merchant,
    imagePath: imagePath,
    notes: notes,
  );
}

class WarrantyModelAdapter extends TypeAdapter<WarrantyModel> {
  @override
  final int typeId = HiveTypeIds.warranty;

  @override
  WarrantyModel read(BinaryReader reader) {
    final m = Map<String, dynamic>.from(reader.readMap());
    return WarrantyModel(
      id: m['id'] as String,
      productName: m['productName'] as String,
      startDate: DateTime.fromMillisecondsSinceEpoch(m['startDate'] as int),
      endDate: DateTime.fromMillisecondsSinceEpoch(m['endDate'] as int),
      merchant: m['merchant'] as String?,
      imagePath: m['imagePath'] as String?,
      notes: m['notes'] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WarrantyModel obj) {
    writer.writeMap({
      'id': obj.id,
      'productName': obj.productName,
      'startDate': obj.startDate.millisecondsSinceEpoch,
      'endDate': obj.endDate.millisecondsSinceEpoch,
      'merchant': obj.merchant,
      'imagePath': obj.imagePath,
      'notes': obj.notes,
    });
  }
}
