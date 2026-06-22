import '../../domain/entities/subscription.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_local_datasource.dart';
import '../models/subscription_model.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl(this._local);
  final SubscriptionLocalDataSource _local;

  @override
  Future<List<Subscription>> getAll() async {
    final list = _local.getAll().map((m) => m.toEntity()).toList();
    list.sort((a, b) => a.nextRenewalDate.compareTo(b.nextRenewalDate));
    return list;
  }

  @override
  Future<Subscription?> getById(String id) async =>
      _local.getById(id)?.toEntity();

  @override
  Future<void> save(Subscription s) =>
      _local.save(SubscriptionModel.fromEntity(s));

  @override
  Future<void> delete(String id) => _local.delete(id);
}
