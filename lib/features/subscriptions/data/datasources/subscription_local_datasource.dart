import 'package:hive/hive.dart';

import '../models/subscription_model.dart';

abstract class SubscriptionLocalDataSource {
  List<SubscriptionModel> getAll();
  SubscriptionModel? getById(String id);
  Future<void> save(SubscriptionModel m);
  Future<void> delete(String id);
}

class SubscriptionLocalDataSourceImpl implements SubscriptionLocalDataSource {
  SubscriptionLocalDataSourceImpl(this._box);
  final Box<SubscriptionModel> _box;

  @override
  List<SubscriptionModel> getAll() => _box.values.toList();

  @override
  SubscriptionModel? getById(String id) => _box.get(id);

  @override
  Future<void> save(SubscriptionModel m) => _box.put(m.id, m);

  @override
  Future<void> delete(String id) => _box.delete(id);
}
