import '../entities/warranty.dart';

abstract class WarrantyRepository {
  Future<List<Warranty>> getAll();
  Future<Warranty?> getById(String id);
  Future<void> save(Warranty w);
  Future<void> delete(String id);
}
