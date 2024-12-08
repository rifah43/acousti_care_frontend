import 'package:acousti_care_frontend/home_page.dart';
import 'package:acousti_care_frontend/views/styles.dart';
import 'package:flutter/material.dart';
import 'package:acousti_care_frontend/views/settings/settings_page.dart';

class CustomTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool withBack;
  final bool hasSettings;
  final bool hasDrawer;

  const CustomTopBar({
    super.key,
    required this.title,
    this.withBack = false,
    this.hasSettings = false,
    this.hasDrawer = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.backgroundSecondary,
      elevation: 4.0,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (withBack)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                );
              },
            ),
          if (hasDrawer)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
        ],
      ),
      actions: hasSettings
          ? [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsPage()),
                  );
                },
              ),
            ]
          : [],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
