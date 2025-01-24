import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _notificationsEnabled = true;
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    _initializeTimeZone();
    _initializeNotifications();
    _loadSettings();
    _checkPermissions();
  }

  Future<void> _initializeTimeZone() async {
    tz.initializeTimeZones();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: androidInitializationSettings);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.notification.status;
    setState(() {
      _permissionGranted = status.isGranted;
      _notificationsEnabled = status.isGranted;
    });
  }

  Future<void> _requestPermission() async {
    final status = await Permission.notification.request();
    setState(() {
      _permissionGranted = status.isGranted;
      _notificationsEnabled = status.isGranted;
    });
    if (_permissionGranted) {
      await _saveSettings();
    }
  }

  Future<void> _scheduleNotification() async {
    if (!_notificationsEnabled || !_permissionGranted) return;

    await _notificationsPlugin.cancel(0);

    final now = DateTime.now();
    final localTimeZone = tz.local;
    var scheduledTime = tz.TZDateTime(
      localTimeZone,
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Schedule for the next day if the time is in the past
    if (scheduledTime.isBefore(tz.TZDateTime.now(localTimeZone))) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'daily_reminder_channel', // Channel ID
      'Daily Reminder',
      'Reminder to perform your daily voice analysis', // Channel description
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Reminder Ticker',
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    await _notificationsPlugin.zonedSchedule(
      0, // Notification ID
      'Voice Analysis Reminder',
      'It’s time for your daily voice analysis!',
      scheduledTime,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'voice_analysis_reminder',
    );
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      final hour = prefs.getInt('notification_hour') ?? TimeOfDay.now().hour;
      final minute = prefs.getInt('notification_minute') ?? TimeOfDay.now().minute;
      _selectedTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setInt('notification_hour', _selectedTime.hour);
    await prefs.setInt('notification_minute', _selectedTime.minute);

    if (_notificationsEnabled && _permissionGranted) {
      await _scheduleNotification();
    } else {
      await _notificationsPlugin.cancel(0);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
      await _saveSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        children: [
          if (!_permissionGranted)
            ListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Notification permissions are required'),
              trailing: ElevatedButton(
                onPressed: _requestPermission,
                child: const Text('Allow'),
              ),
            ),
          SwitchListTile(
            title: const Text('Enable Daily Notifications'),
            subtitle: const Text('Receive daily reminders for voice analysis'),
            value: _notificationsEnabled && _permissionGranted,
            onChanged: _permissionGranted
                ? (bool value) async {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    await _saveSettings();
                  }
                : null,
          ),
          ListTile(
            title: const Text('Notification Time'),
            subtitle: Text('Reminder time: ${_selectedTime.format(context)}'),
            trailing: const Icon(Icons.access_time),
            enabled: _notificationsEnabled && _permissionGranted,
            onTap: _notificationsEnabled && _permissionGranted ? _selectTime : null,
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Monthly notifications will be sent at the end of each month automatically.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
