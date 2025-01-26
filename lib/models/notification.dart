class NotificationClass {
  final String id;
  final String type;
  final String title;
  final String message;
  final DateTime scheduledTime;
  bool isRead;

  NotificationClass({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.scheduledTime,
    this.isRead = false,
  });

  factory NotificationClass.fromJson(Map<String, dynamic> json) {
    return NotificationClass(
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      scheduledTime: DateTime.parse(json['scheduled_time']),
      isRead: json['is_read'] ?? false,
    );
  }
}
