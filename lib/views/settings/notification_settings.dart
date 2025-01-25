import 'package:acousti_care_frontend/views/custom_topbar.dart';
import 'package:acousti_care_frontend/views/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String _selectedPeriod = 'AM';
  TextEditingController _hourController = TextEditingController();
  TextEditingController _minuteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeTimeZone();
    _initializeNotifications();
    _loadSettings();
    _updateTimeControllers();
  }

  void _updateTimeControllers() {
    int displayHour = _selectedTime.hourOfPeriod;
    if (displayHour == 0) displayHour = 12;
    
    _hourController.text = displayHour.toString().padLeft(2, '0');
    _minuteController.text = _selectedTime.minute.toString().padLeft(2, '0');
    _selectedPeriod = _selectedTime.period == DayPeriod.am ? 'AM' : 'PM';
  }

  Future<void> _initializeTimeZone() async {
    tz.initializeTimeZones();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings = 
      AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = 
      InitializationSettings(android: androidInitializationSettings);
    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final hour = prefs.getInt('notification_hour') ?? TimeOfDay.now().hour;
      final minute = prefs.getInt('notification_minute') ?? TimeOfDay.now().minute;
      _selectedTime = TimeOfDay(hour: hour, minute: minute);
      _updateTimeControllers();
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_hour', _selectedTime.hour);
    await prefs.setInt('notification_minute', _selectedTime.minute);
    await _scheduleNotification();

  }

  Future<void> _scheduleNotification() async {
    await _notificationsPlugin.cancel(0);
    
    final now = tz.TZDateTime.now(tz.local);
    var scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // If scheduled time is in the past, add 1 day
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }
    
    // Schedule daily repeating notification
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminder',
      channelDescription: 'Reminder to perform your daily voice analysis',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails
    );

    await _notificationsPlugin.zonedSchedule(
      0,
      'Voice Analysis Reminder',
      'It is time for your daily voice analysis!',
      scheduledTime,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // This makes it repeat daily
    );

    await _notificationsPlugin.zonedSchedule(
      0,
      'Voice Analysis Reminder',
      'It is time for your daily voice analysis!',
      scheduledTime,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void _updateTime() {
    int hour = int.tryParse(_hourController.text) ?? 12;
    int minute = int.tryParse(_minuteController.text) ?? 0;
    
    if (hour < 1) hour = 12;
    if (hour > 12) hour = 12;
    if (minute > 59) minute = 59;
    
    hour = _selectedPeriod == 'PM' ? (hour % 12) + 12 : hour % 12;
    
    setState(() {
      _selectedTime = TimeOfDay(hour: hour, minute: minute);
    });
    _saveSettings();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notification time saved successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTopBar(title: 'Notification Settings', withBack: true,hasDrawer: false, hasSettings: false),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set Daily Reminder Time',
              style: subtitleStyle(context, AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hour Input
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _hourController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: titleStyle(context, AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: '12',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) => _updateTime(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    ':',
                    style: titleStyle(context, AppColors.textPrimary),
                  ),
                ),
                // Minute Input
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _minuteController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: titleStyle(context, AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: '00',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) => _updateTime(),
                  ),
                ),
                const SizedBox(width: 16),
                // AM/PM Toggle
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.buttonPrimary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: ['AM', 'PM'].map((period) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPeriod = period;
                            _updateTime();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedPeriod == period
                                ? AppColors.buttonPrimary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            period,
                            style: boldTextStyle(
                              context,
                              _selectedPeriod == period
                                  ? AppColors.buttonText
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                style: primaryButtonStyle(),
                onPressed: _updateTime,
                child: Text(
                  'Save Reminder Time',
                  style: normalTextStyle(context, AppColors.buttonText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}