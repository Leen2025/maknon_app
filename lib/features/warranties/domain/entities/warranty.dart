import 'package:equatable/equatable.dart';

class Warranty extends Equatable {
  const Warranty({
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

  Warranty copyWith({
    String? id,
    String? productName,
    DateTime? startDate,
    DateTime? endDate,
    String? merchant,
    String? imagePath,
    String? notes,
  }) {
    return Warranty(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      merchant: merchant ?? this.merchant,
      imagePath: imagePath ?? this.imagePath,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props =>
      [id, productName, startDate, endDate, merchant, imagePath, notes];
}
