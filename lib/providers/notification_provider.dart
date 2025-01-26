import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationProvider extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  bool _notificationsEnabled = true;
  bool _healthTipsEnabled = true;
  bool _monthlySummaryEnabled = true;

  TimeOfDay get reminderTime => _reminderTime;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get healthTipsEnabled => _healthTipsEnabled;
  bool get monthlySummaryEnabled => _monthlySummaryEnabled;

  Future<void> initialize() async {
    tz.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(initSettings);
  }

  Future<void> updateSettings({
    TimeOfDay? reminderTime,
    bool? notificationsEnabled,
    bool? healthTipsEnabled,
    bool? monthlySummaryEnabled,
  }) async {
    if (reminderTime != null) _reminderTime = reminderTime;
    if (notificationsEnabled != null) _notificationsEnabled = notificationsEnabled;
    if (healthTipsEnabled != null) _healthTipsEnabled = healthTipsEnabled;
    if (monthlySummaryEnabled != null) _monthlySummaryEnabled = monthlySummaryEnabled;

    if (_notificationsEnabled) {
      await scheduleDailyReminder();
      if (_monthlySummaryEnabled) await scheduleMonthlyReminder();
      if (_healthTipsEnabled) await scheduleHealthTip();
    } else {
      await _notifications.cancelAll();
    }
    
    notifyListeners();
  }

  Future<void> scheduleDailyReminder() async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      _reminderTime.hour,
      _reminderTime.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      1,
      'Voice Analysis Reminder',
      'Time for your daily voice recording!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminder',
          channelDescription: 'Daily voice analysis reminder',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleMonthlyReminder() async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.month == 12 ? now.year + 1 : now.year,
      now.month == 12 ? 1 : now.month + 1,
      1,
      9,
      0,
    );

    await _notifications.zonedSchedule(
      2,
      'Monthly Health Summary',
      'Your health analysis for the past month is ready!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'monthly_summary',
          'Monthly Summary',
          channelDescription: 'Monthly health summary notification',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  Future<void> scheduleHealthTip() async {
    final random = Random();
    final daysToAdd = random.nextInt(7) + 1;
    final scheduledDate = tz.TZDateTime.now(tz.local).add(Duration(days: daysToAdd));

    await _notifications.zonedSchedule(
      3,
      'Health Tip',
      'Did you know? Regular exercise can help reduce T2DM risk!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'health_tips',
          'Health Tips',
          channelDescription: 'Health tips and recommendations',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}