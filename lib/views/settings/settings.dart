import 'package:acousti_care_frontend/views/custom_topbar.dart';
import 'package:acousti_care_frontend/views/settings/height_weight_settings.dart';
import 'package:acousti_care_frontend/views/settings/profile_settings.dart';
import 'package:acousti_care_frontend/views/styles.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String name = 'John Doe';
  String age = '25';
  String height = '22';
  String weight = '222';

  // Update profile data and pass back to the settings screen
  void updateProfile(String updatedName, String updatedAge) {
    setState(() {
      name = updatedName;
      age = updatedAge;
    });
  }

  // Update height and weight data and pass back to the settings screen
  void updateHeightWeight(String updatedHeight, String updatedWeight) {
    setState(() {
      height = updatedHeight;
      weight = updatedWeight;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTopBar(
        title: "Settings",
        hasDrawer: false,
        hasSettings: false,
        withBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileSettingPage(name: name, age: age, onUpdate: updateProfile),
            const Divider(),
            HeightWeightSettingPage(height: height, weight: weight, onUpdate: updateHeightWeight),
            const Divider(),
            const NotificationSettings(),
          ],
        ),
      ),
    );
  }
}

// Notification Settings
class NotificationSettings extends StatelessWidget {
  const NotificationSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Notification Settings'),
      subtitle: const Text('Set reminders for health tips'),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NotificationPage(),
          ),
        );
      },
    );
  }
}

// BMI Details Page
class BMIDetailsPage extends StatelessWidget {
  const BMIDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BMI Settings'), backgroundColor: AppColors.backgroundPrimary),
      body: const Center(child: Text('BMI settings page')),
    );
  }
}

// Weight & Height Page
class WeightHeightPage extends StatelessWidget {
  const WeightHeightPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weight & Height Settings'), backgroundColor: AppColors.backgroundPrimary),
      body: const Center(child: Text('Weight & height settings page')),
    );
  }
}

// Notification Page
class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings'), backgroundColor: AppColors.backgroundPrimary),
      body: const Center(child: Text('Notification settings page')),
    );
  }
}
