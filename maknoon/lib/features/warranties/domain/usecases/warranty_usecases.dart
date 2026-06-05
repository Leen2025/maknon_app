import '../entities/warranty.dart';
import '../repositories/warranty_repository.dart';

class GetAllWarranties {
  GetAllWarranties(this._repo);
  final WarrantyRepository _repo;
  Future<List<Warranty>> call() => _repo.getAll();
}

class SaveWarranty {
  SaveWarranty(this._repo);
  final WarrantyRepository _repo;
  Future<void> call(Warranty w) => _repo.save(w);
}

class DeleteWarranty {
  DeleteWarranty(this._repo);
  final WarrantyRepository _repo;
  Future<void> call(String id) => _repo.delete(id);
}
