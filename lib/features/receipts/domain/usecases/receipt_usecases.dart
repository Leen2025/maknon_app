import '../entities/receipt.dart';
import '../repositories/receipt_repository.dart';

class GetAllReceipts {
  GetAllReceipts(this._repo);
  final ReceiptRepository _repo;
  Future<List<Receipt>> call() => _repo.getAll();
}

class GetReceiptById {
  GetReceiptById(this._repo);
  final ReceiptRepository _repo;
  Future<Receipt?> call(String id) => _repo.getById(id);
}

class SaveReceipt {
  SaveReceipt(this._repo);
  final ReceiptRepository _repo;
  Future<void> call(Receipt r) => _repo.save(r);
}

class DeleteReceipt {
  DeleteReceipt(this._repo);
  final ReceiptRepository _repo;
  Future<void> call(String id) => _repo.delete(id);
}
