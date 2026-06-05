import 'package:equatable/equatable.dart';

class Receipt extends Equatable {
  const Receipt({
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

  Receipt copyWith({
    String? id,
    String? merchant,
    double? amount,
    DateTime? purchaseDate,
    DateTime? returnDeadline,
    DateTime? exchangeDeadline,
    String? imagePath,
    String? notes,
  }) {
    return Receipt(
      id: id ?? this.id,
      merchant: merchant ?? this.merchant,
      amount: amount ?? this.amount,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      returnDeadline: returnDeadline ?? this.returnDeadline,
      exchangeDeadline: exchangeDeadline ?? this.exchangeDeadline,
      imagePath: imagePath ?? this.imagePath,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    merchant,
    amount,
    purchaseDate,
    returnDeadline,
    exchangeDeadline,
    imagePath,
    notes,
  ];
}
