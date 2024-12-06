import 'package:flutter/foundation.dart';
import 'package:acousti_care_frontend/models/notification.dart';

class NotificationProvider with ChangeNotifier {
  final List<Notification> _notifications = [];
  int _unreadCount = 0;

  List<Notification> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  void addNotification(Notification notification) {
    _notifications.insert(0, notification);
    if (!notification.isRead) {
      _unreadCount++;
    }
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final notification = _notifications[index];
      if (!notification.isRead) {
        _notifications[index] = notification.copyWith(isRead: true);
        _unreadCount--;
        notifyListeners();
      }
    }
  }

  void clearNotifications() {
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }
}

