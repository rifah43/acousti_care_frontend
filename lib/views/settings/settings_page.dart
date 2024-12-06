import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Language'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to language settings
            },
          ),
          ListTile(
            title: const Text('Notifications'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to notification settings
            },
          ),
          ListTile(
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to help and support page
            },
          ),
        ],
      ),
    );
  }
}

