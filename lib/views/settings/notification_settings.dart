import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acousti_care_frontend/providers/notification_provider.dart';
import 'package:acousti_care_frontend/views/custom_topbar.dart';
import 'package:acousti_care_frontend/views/styles.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      appBar: const CustomTopBar(
        title: 'Notification Settings',
        withBack: true,
        hasDrawer: false,
        hasSettings: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: Text('Enable Notifications', 
              style: normalTextStyle(context, AppColors.textPrimary)),
            value: notificationProvider.notificationsEnabled,
            onChanged: (value) => notificationProvider.updateSettings(
              notificationsEnabled: value
            ),
          ),
          if (notificationProvider.notificationsEnabled) ...[
            ListTile(
              title: Text('Daily Reminder Time', 
                style: normalTextStyle(context, AppColors.textPrimary)),
              subtitle: Text(notificationProvider.reminderTime.format(context)),
              onTap: () async {
                final TimeOfDay? time = await showTimePicker(
                  context: context,
                  initialTime: notificationProvider.reminderTime,
                );
                if (time != null) {
                  await notificationProvider.updateSettings(reminderTime: time);
                }
              },
            ),
            SwitchListTile(
              title: Text('Health Tips', 
                style: normalTextStyle(context, AppColors.textPrimary)),
              value: notificationProvider.healthTipsEnabled,
              onChanged: (value) => notificationProvider.updateSettings(
                healthTipsEnabled: value
              ),
            ),
            SwitchListTile(
              title: Text('Monthly Summary', 
                style: normalTextStyle(context, AppColors.textPrimary)),
              value: notificationProvider.monthlySummaryEnabled,
              onChanged: (value) => notificationProvider.updateSettings(
                monthlySummaryEnabled: value
              ),
            ),
          ],
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              style: primaryButtonStyle(),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings saved successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: Text('Save Settings', 
                style: normalTextStyle(context, AppColors.buttonText)),
            ),
          ),
        ],
      ),
    );
  }
}