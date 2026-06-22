import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/di/injector.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait — Maknoon is a phone-first app.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Local Arabic date formatting.
  await initializeDateFormatting('ar', null);

  // Hive setup.
  await Hive.initFlutter();

  // Register adapters, open boxes, register all dependencies.
  await initInjector();

  // Init notifications (requests permissions, sets up timezone).
  await sl<NotificationService>().init();

  runApp(const MaknoonApp());
}
