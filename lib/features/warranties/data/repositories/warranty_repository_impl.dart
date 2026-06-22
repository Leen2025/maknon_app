import '../../domain/entities/warranty.dart';
import '../../domain/repositories/warranty_repository.dart';
import '../datasources/warranty_local_datasource.dart';
import '../models/warranty_model.dart';

class WarrantyRepositoryImpl implements WarrantyRepository {
  WarrantyRepositoryImpl(this._local);
  final WarrantyLocalDataSource _local;

  @override
  Future<List<Warranty>> getAll() async {
    final list = _local.getAll().map((m) => m.toEntity()).toList();
    list.sort((a, b) => a.endDate.compareTo(b.endDate));
    return list;
  }

  @override
  Future<Warranty?> getById(String id) async => _local.getById(id)?.toEntity();

  @override
  Future<void> save(Warranty w) => _local.save(WarrantyModel.fromEntity(w));

  @override
  Future<void> delete(String id) => _local.delete(id);
}
