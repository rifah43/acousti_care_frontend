import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:acousti_care_frontend/views/styles.dart';
import 'package:acousti_care_frontend/views/custom_topbar.dart';
import 'package:acousti_care_frontend/services/http_provider.dart';
import 'package:acousti_care_frontend/models/notification.dart';

class NotificationListPage extends StatefulWidget {
  const NotificationListPage({super.key});

  @override
  State<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  final ApiProvider _api = ApiProvider();
  List<NotificationClass> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final response = await _api.getRequest('notifications');
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _notifications = data.map((json) => NotificationClass.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading notifications: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'daily': return Icons.access_time;
      case 'monthly': return Icons.calendar_today;
      case 'health_tip': return Icons.favorite;
      default: return Icons.notifications;
    }
  }

  Future<void> _markAsRead(NotificationClass notification) async {
    try {
      await _api.postRequest('notifications/mark-read/${notification.id}', {});
      setState(() => notification.isRead = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error marking notification as read: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Widget _buildNotificationCard(NotificationClass notification) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            _markAsRead(notification);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getNotificationIcon(notification.type),
                    color: notification.isRead 
                        ? AppColors.textSecondary.withOpacity(0.5)
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      notification.title,
                      style: nameTitleStyle(context, AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.message,
                      style: normalTextStyle(context, AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy HH:mm').format(notification.scheduledTime),
                      style: subtitleStyle(context, AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.buttonPrimary)),
      );
    }

    return Scaffold(
      appBar: const CustomTopBar(
        title: 'Notifications',
        withBack: true,
        hasDrawer: false,
        hasSettings: false,
      ),
      backgroundColor: AppColors.backgroundPrimary,
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_none, size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text('No notifications', style: subtitleStyle(context, AppColors.textPrimary)),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              color: AppColors.buttonPrimary,
              child: ListView.builder(
                itemCount: _notifications.length,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemBuilder: (context, index) => _buildNotificationCard(_notifications[index]),
              ),
            ),
    );
  }
}