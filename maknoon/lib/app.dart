import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_strings.dart';
import 'core/di/injector.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/receipts/presentation/cubit/receipts_cubit.dart';
import 'features/reminders/presentation/cubit/reminders_cubit.dart';
import 'features/subscriptions/presentation/cubit/subscriptions_cubit.dart';
import 'features/warranties/presentation/cubit/warranties_cubit.dart';

class MaknoonApp extends StatelessWidget {
  const MaknoonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>(create: (_) => sl<HomeCubit>()),
        BlocProvider<ReceiptsCubit>(create: (_) => sl<ReceiptsCubit>()),
        BlocProvider<WarrantiesCubit>(create: (_) => sl<WarrantiesCubit>()),
        BlocProvider<SubscriptionsCubit>(
          create: (_) => sl<SubscriptionsCubit>(),
        ),
        BlocProvider<RemindersCubit>(create: (_) => sl<RemindersCubit>()),
      ],
      child: MaterialApp.router(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: AppRouter.router,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        builder: (context, child) {
          // Force RTL across the app — Maknoon is Arabic-first.
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
