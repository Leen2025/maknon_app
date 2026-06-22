import '../../domain/entities/receipt.dart';
import '../../domain/repositories/receipt_repository.dart';
import '../datasources/receipt_local_datasource.dart';
import '../models/receipt_model.dart';

class ReceiptRepositoryImpl implements ReceiptRepository {
  ReceiptRepositoryImpl(this._local);

  final ReceiptLocalDataSource _local;

  @override
  Future<List<Receipt>> getAll() async {
    final list = _local.getAll().map((m) => m.toEntity()).toList();
    list.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
    return list;
  }

  @override
  Future<Receipt?> getById(String id) async => _local.getById(id)?.toEntity();

  @override
  Future<void> save(Receipt r) =>
      _local.save(ReceiptModel.fromEntity(r));

  @override
  Future<void> delete(String id) => _local.delete(id);
}
