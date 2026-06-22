import 'package:equatable/equatable.dart';

import '../../domain/entities/receipt.dart';

enum ReceiptsStatus { initial, loading, loaded, error }

class ReceiptsState extends Equatable {
  const ReceiptsState({
    this.status = ReceiptsStatus.initial,
    this.receipts = const [],
    this.errorMessage,
  });

  final ReceiptsStatus status;
  final List<Receipt> receipts;
  final String? errorMessage;

  ReceiptsState copyWith({
    ReceiptsStatus? status,
    List<Receipt>? receipts,
    String? errorMessage,
  }) {
    return ReceiptsState(
      status: status ?? this.status,
      receipts: receipts ?? this.receipts,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, receipts, errorMessage];
}
