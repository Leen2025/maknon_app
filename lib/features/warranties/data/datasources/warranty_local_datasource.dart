import 'package:hive/hive.dart';

import '../models/warranty_model.dart';

abstract class WarrantyLocalDataSource {
  List<WarrantyModel> getAll();
  WarrantyModel? getById(String id);
  Future<void> save(WarrantyModel m);
  Future<void> delete(String id);
}

class WarrantyLocalDataSourceImpl implements WarrantyLocalDataSource {
  WarrantyLocalDataSourceImpl(this._box);
  final Box<WarrantyModel> _box;

  @override
  List<WarrantyModel> getAll() => _box.values.toList();

  @override
  WarrantyModel? getById(String id) => _box.get(id);

  @override
  Future<void> save(WarrantyModel m) => _box.put(m.id, m);

  @override
  Future<void> delete(String id) => _box.delete(id);
}
