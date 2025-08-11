


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

  NotificationModel copyWith({bool? isRead,
     String? id,
     String? title,
     String? body,
     DateTime? timestamp,

  }) {
    return NotificationModel(
      id: this.id,
      title: this.title,
      body: this.body,
      timestamp: this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}