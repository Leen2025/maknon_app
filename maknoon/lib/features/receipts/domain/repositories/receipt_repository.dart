import '../entities/receipt.dart';

abstract class ReceiptRepository {
  Future<List<Receipt>> getAll();
  Future<Receipt?> getById(String id);
  Future<void> save(Receipt receipt);
  Future<void> delete(String id);
}
