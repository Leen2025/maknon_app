import 'package:hive/hive.dart';

import '../models/receipt_model.dart';

abstract class ReceiptLocalDataSource {
  List<ReceiptModel> getAll();
  ReceiptModel? getById(String id);
  Future<void> save(ReceiptModel model);
  Future<void> delete(String id);
}

class ReceiptLocalDataSourceImpl implements ReceiptLocalDataSource {
  ReceiptLocalDataSourceImpl(this._box);

  final Box<ReceiptModel> _box;

  @override
  List<ReceiptModel> getAll() => _box.values.toList();

  @override
  ReceiptModel? getById(String id) => _box.get(id);

  @override
  Future<void> save(ReceiptModel model) => _box.put(model.id, model);

  @override
  Future<void> delete(String id) => _box.delete(id);
}
