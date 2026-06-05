import '../entities/subscription.dart';
import '../repositories/subscription_repository.dart';

class GetAllSubscriptions {
  GetAllSubscriptions(this._r);
  final SubscriptionRepository _r;
  Future<List<Subscription>> call() => _r.getAll();
}

class SaveSubscription {
  SaveSubscription(this._r);
  final SubscriptionRepository _r;
  Future<void> call(Subscription s) => _r.save(s);
}

class DeleteSubscription {
  DeleteSubscription(this._r);
  final SubscriptionRepository _r;
  Future<void> call(String id) => _r.delete(id);
}
