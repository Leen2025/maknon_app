import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:maknoon/core/constants/app_colors.dart';
import 'package:maknoon/core/constants/app_strings.dart';
import 'package:maknoon/features/home/presentation/cubit/home_cubit.dart';
import 'package:maknoon/features/reminders/presentation/cubit/reminders_cubit.dart';

/// Shell that holds the bottom-navigation bar around the 5 root tabs.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      body: SafeArea(
        // No AppBar at shell level — guard top and sides for all device types.
        // bottom is handled by BottomNavigationBar automatically.
        bottom: false,
        child: navigationShell,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          // Refresh data-dependent tabs whenever re-selected so counts stay current.
          if (index == 0) context.read<HomeCubit>().load();
          if (index == 4) context.read<RemindersCubit>().load();
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: AppStrings.navHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: AppStrings.navReceipts,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield_outlined),
            activeIcon: Icon(Icons.shield),
            label: AppStrings.navWarranties,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.autorenew_outlined),
            activeIcon: Icon(Icons.autorenew),
            label: AppStrings.navSubscriptions,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_outlined),
            activeIcon: Icon(Icons.notifications),
            label: AppStrings.navReminders,
          ),
        ],
      ),
    );
  }
}
