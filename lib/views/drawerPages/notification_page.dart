import 'package:acousti_care_frontend/views/styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:acousti_care_frontend/views/dashboard/trend_visualization.dart';
import 'package:acousti_care_frontend/views/settings/notification_settings.dart';
import 'package:acousti_care_frontend/views/voiceRecorder/record_voice.dart';

enum NotificationType { voiceCheck, monthlyReport, healthSuggestion }

class Notification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final Map<String, dynamic>? additionalData;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.additionalData,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'type': type.toString(),
    'isRead': isRead,
    'additionalData': additionalData,
  };

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      isRead: json['isRead'] ?? false,
      additionalData: json['additionalData'],
    );
  }
}

class NotificationListPage extends StatefulWidget {
  const NotificationListPage({super.key});

  @override
  State<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  List<Notification> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString('notifications') ?? '[]';
    
    setState(() {
      notifications = List<Notification>.from(
        jsonDecode(notificationsJson).map((x) => Notification.fromJson(x))
      )..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      isLoading = false;
    });
  }

  Future<void> _markAsRead(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final updatedNotifications = notifications.map((notification) {
      if (notification.id == notificationId) {
        return Notification(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          timestamp: notification.timestamp,
          type: notification.type,
          isRead: true,
          additionalData: notification.additionalData,
        );
      }
      return notification;
    }).toList();

    await prefs.setString('notifications', jsonEncode(updatedNotifications));
    setState(() => notifications = updatedNotifications);
  }

  void _handleNotificationTap(Notification notification) async {
    await _markAsRead(notification.id);

    if (!mounted) return;

    switch (notification.type) {
      case NotificationType.voiceCheck:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RecordVoice()),
        );
        break;
      case NotificationType.monthlyReport:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TrendVisualization()),
        );
        break;
      case NotificationType.healthSuggestion:
        _showHealthSuggestionDialog(notification);
        break;
    }
  }

  void _showHealthSuggestionDialog(Notification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title, 
          style: nameTitleStyle(context, AppColors.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification.message,
                style: normalTextStyle(context, AppColors.textPrimary)),
              const SizedBox(height: 16),
              if (notification.additionalData?['link'] != null)
                ElevatedButton(
                  style: primaryButtonStyle(),
                  onPressed: () {
                    // Launch URL using url_launcher package
                  },
                  child: Text('Learn More',
                    style: normalTextStyle(context, AppColors.buttonText)),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close',
              style: normalTextStyle(context, AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(Notification notification) {
    final IconData icon;
    final Color iconColor;

    switch (notification.type) {
      case NotificationType.voiceCheck:
        icon = Icons.mic;
        iconColor = AppColors.iconSecondary;
        break;
      case NotificationType.monthlyReport:
        icon = Icons.assessment;
        iconColor = AppColors.success;
        break;
      case NotificationType.healthSuggestion:
        icon = Icons.favorite;
        iconColor = AppColors.alert;
        break;
    }

    return Card(
      elevation: notification.isRead ? 1 : 3,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          notification.title,
          style: notification.isRead 
            ? normalTextStyle(context, AppColors.textPrimary)
            : boldTextStyle(context, AppColors.textPrimary),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: subtitleStyle(context, AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d, y HH:mm').format(notification.timestamp),
              style: subtitleStyle(context, AppColors.textSecondary),
            ),
          ],
        ),
        onTap: () => _handleNotificationTap(notification),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: Text('Notifications',
          style: titleStyle(context, AppColors.buttonText)),
        backgroundColor: AppColors.backgroundSecondary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.drawerIcon),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationSettingsPage()),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(
              color: AppColors.buttonPrimary,
            ))
          : notifications.isEmpty
              ? Center(
                  child: Text('No notifications yet',
                    style: normalTextStyle(context, AppColors.textPrimary)),
                )
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) => _buildNotificationTile(
                    notifications[index],
                  ),
                ),
    );
  }
}