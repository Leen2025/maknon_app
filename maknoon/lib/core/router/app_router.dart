import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/widgets/home_shell.dart';
import '../../features/receipts/presentation/pages/receipt_details_page.dart';
import '../../features/receipts/presentation/pages/receipt_form_page.dart';
import '../../features/receipts/presentation/pages/receipts_list_page.dart';
import '../../features/reminders/presentation/pages/reminders_page.dart';
import '../../features/subscriptions/presentation/pages/subscription_details_page.dart';
import '../../features/subscriptions/presentation/pages/subscription_form_page.dart';
import '../../features/subscriptions/presentation/pages/subscriptions_list_page.dart';
import '../../features/warranties/presentation/pages/warranties_list_page.dart';
import '../../features/warranties/presentation/pages/warranty_details_page.dart';
import '../../features/warranties/presentation/pages/warranty_form_page.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          // ── Home tab ──────────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: AppRoutes.home,
                builder: (_, __) => const HomePage(),
              ),
            ],
          ),

          // ── Receipts tab ──────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/receipts',
                name: AppRoutes.receipts,
                builder: (_, __) => const ReceiptsListPage(),
                routes: [
                  GoRoute(
                    path: 'form',
                    name: AppRoutes.receiptForm,
                    builder: (_, state) => ReceiptFormPage(
                      receiptId: state.uri.queryParameters['id'],
                    ),
                  ),
                  GoRoute(
                    path: ':id',
                    name: AppRoutes.receiptDetails,
                    builder: (_, state) => ReceiptDetailsPage(
                      id: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Warranties tab ────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/warranties',
                name: AppRoutes.warranties,
                builder: (_, __) => const WarrantiesListPage(),
                routes: [
                  GoRoute(
                    path: 'form',
                    name: AppRoutes.warrantyForm,
                    builder: (_, state) => WarrantyFormPage(
                      warrantyId: state.uri.queryParameters['id'],
                    ),
                  ),
                  GoRoute(
                    path: ':id',
                    name: AppRoutes.warrantyDetails,
                    builder: (_, state) => WarrantyDetailsPage(
                      id: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Subscriptions tab ─────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/subscriptions',
                name: AppRoutes.subscriptions,
                builder: (_, __) => const SubscriptionsListPage(),
                routes: [
                  GoRoute(
                    path: 'form',
                    name: AppRoutes.subscriptionForm,
                    builder: (_, state) => SubscriptionFormPage(
                      subscriptionId: state.uri.queryParameters['id'],
                    ),
                  ),
                  GoRoute(
                    path: ':id',
                    name: AppRoutes.subscriptionDetails,
                    builder: (_, state) => SubscriptionDetailsPage(
                      id: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Reminders tab ─────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reminders',
                name: AppRoutes.reminders,
                builder: (_, __) => const RemindersPage(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
}
