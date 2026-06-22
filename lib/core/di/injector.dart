import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../features/receipts/data/datasources/receipt_local_datasource.dart';
import '../../features/receipts/data/models/receipt_model.dart';
import '../../features/receipts/data/repositories/receipt_repository_impl.dart';
import '../../features/receipts/domain/repositories/receipt_repository.dart';
import '../../features/receipts/domain/usecases/receipt_usecases.dart';
import '../../features/receipts/presentation/cubit/receipts_cubit.dart';
import '../../features/reminders/domain/usecases/schedule_reminders_for_receipt.dart';
import '../../features/reminders/domain/usecases/schedule_reminders_for_subscription.dart';
import '../../features/reminders/domain/usecases/schedule_reminders_for_warranty.dart';
import '../../features/reminders/presentation/cubit/reminders_cubit.dart';
import '../../features/subscriptions/data/datasources/subscription_local_datasource.dart';
import '../../features/subscriptions/data/models/subscription_model.dart';
import '../../features/subscriptions/data/repositories/subscription_repository_impl.dart';
import '../../features/subscriptions/domain/repositories/subscription_repository.dart';
import '../../features/subscriptions/domain/usecases/subscription_usecases.dart';
import '../../features/subscriptions/presentation/cubit/subscriptions_cubit.dart';
import '../../features/warranties/data/datasources/warranty_local_datasource.dart';
import '../../features/warranties/data/models/warranty_model.dart';
import '../../features/warranties/data/repositories/warranty_repository_impl.dart';
import '../../features/warranties/domain/repositories/warranty_repository.dart';
import '../../features/warranties/domain/usecases/warranty_usecases.dart';
import '../../features/warranties/presentation/cubit/warranties_cubit.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../constants/hive_boxes.dart';
import '../services/image_storage_service.dart';
import '../services/notification_service.dart';

final sl = GetIt.instance;

/// Wires up all dependencies. Must be called once in main() after Hive is
/// initialized but before runApp().
Future<void> initInjector() async {
  // ── Hive: register adapters & open boxes ───────────────────────────────
  Hive.registerAdapter(ReceiptModelAdapter());
  Hive.registerAdapter(WarrantyModelAdapter());
  Hive.registerAdapter(SubscriptionModelAdapter());
  Hive.registerAdapter(BillingCycleAdapter());

  final receiptsBox = await Hive.openBox<ReceiptModel>(HiveBoxes.receipts);
  final warrantiesBox =
      await Hive.openBox<WarrantyModel>(HiveBoxes.warranties);
  final subscriptionsBox =
      await Hive.openBox<SubscriptionModel>(HiveBoxes.subscriptions);

  // ── External singletons ────────────────────────────────────────────────
  sl.registerLazySingleton(() => const Uuid());
  sl.registerLazySingleton(() => ImagePicker());
  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());

  // ── Core services ──────────────────────────────────────────────────────
  sl.registerLazySingleton<NotificationService>(
    () => NotificationService(sl()),
  );
  sl.registerLazySingleton<ImageStorageService>(
    () => ImageStorageService(sl(), sl()),
  );

  // ── Receipts ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<ReceiptLocalDataSource>(
    () => ReceiptLocalDataSourceImpl(receiptsBox),
  );
  sl.registerLazySingleton<ReceiptRepository>(
    () => ReceiptRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetAllReceipts(sl()));
  sl.registerLazySingleton(() => GetReceiptById(sl()));
  sl.registerLazySingleton(() => SaveReceipt(sl()));
  sl.registerLazySingleton(() => DeleteReceipt(sl()));

  // ── Warranties ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<WarrantyLocalDataSource>(
    () => WarrantyLocalDataSourceImpl(warrantiesBox),
  );
  sl.registerLazySingleton<WarrantyRepository>(
    () => WarrantyRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetAllWarranties(sl()));
  sl.registerLazySingleton(() => SaveWarranty(sl()));
  sl.registerLazySingleton(() => DeleteWarranty(sl()));

  // ── Subscriptions ──────────────────────────────────────────────────────
  sl.registerLazySingleton<SubscriptionLocalDataSource>(
    () => SubscriptionLocalDataSourceImpl(subscriptionsBox),
  );
  sl.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetAllSubscriptions(sl()));
  sl.registerLazySingleton(() => SaveSubscription(sl()));
  sl.registerLazySingleton(() => DeleteSubscription(sl()));

  // ── Reminders use cases ────────────────────────────────────────────────
  sl.registerLazySingleton(() => ScheduleRemindersForReceipt(sl()));
  sl.registerLazySingleton(() => ScheduleRemindersForWarranty(sl()));
  sl.registerLazySingleton(() => ScheduleRemindersForSubscription(sl()));

  // ── Cubits (factories — fresh instance per provider) ───────────────────
  sl.registerFactory(() => ReceiptsCubit(
        getAllReceipts: sl(),
        saveReceipt: sl(),
        deleteReceipt: sl(),
        scheduleReminders: sl(),
      ));
  sl.registerFactory(() => WarrantiesCubit(
        getAll: sl(),
        save: sl(),
        delete: sl(),
        scheduleReminders: sl(),
      ));
  sl.registerFactory(() => SubscriptionsCubit(
        getAll: sl(),
        save: sl(),
        delete: sl(),
        scheduleReminders: sl(),
      ));
  sl.registerFactory(() => RemindersCubit(
        getAllReceipts: sl(),
        getAllWarranties: sl(),
        getAllSubscriptions: sl(),
      ));
  sl.registerFactory(() => HomeCubit(
        getAllReceipts: sl(),
        getAllWarranties: sl(),
        getAllSubscriptions: sl(),
      ));
}
