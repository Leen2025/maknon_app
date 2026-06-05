import '../entities/subscription.dart';

abstract class SubscriptionRepository {
  Future<List<Subscription>> getAll();
  Future<Subscription?> getById(String id);
  Future<void> save(Subscription s);
  Future<void> delete(String id);
}
