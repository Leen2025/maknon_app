import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Standard scaffold used across pages. Keeps the sand background and
/// the consistent app bar style in one place.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.showBack = true,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              automaticallyImplyLeading: showBack,
              actions: actions,
            ),
      body: SafeArea(
        // AppBar handles top inset; outer Scaffold/BottomNavBar handles bottom.
        // Only enforce left/right to guard against side cutouts in landscape.
        top: false,
        bottom: false,
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
