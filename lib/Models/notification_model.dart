


class NotificationModel {
  final String? id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;

  NotificationModel({
    this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      title: map['title'] as String,
      body: map['body'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      isRead: map['isRead'] as bool,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}