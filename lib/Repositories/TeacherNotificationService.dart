import 'package:firebase_database/firebase_database.dart';
import '../Models/notification_model.dart';

class TeacherNotificationService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  DatabaseReference _getRef(String teacherId) {
    return _database.ref('teacherNotifications/$teacherId');
  }

  Future<List<NotificationModel>> readAllForTeacher(String teacherId) async {
    final List<NotificationModel> notifications = [];
    try {
      final snapshot = await _getRef(teacherId).get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        data.forEach((notificationId, notificationData) {
          final notificationMap = Map<String, dynamic>.from(notificationData);
          notifications.add(
              NotificationModel.fromMap(notificationMap, notificationId));
        });
        notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
    } catch (e) {
      print('Error reading teacher notifications for $teacherId: $e');
    }
    return notifications;
  }

  Future<int> update(String teacherId, NotificationModel notification) async {
    if (notification.id == null) return 0;
    try {
      await _getRef(teacherId).child(notification.id!).update(
          notification.toMap());
      return 1;
    } catch (e) {
      print('Error updating teacher notification ${notification.id}: $e');
      return 0;
    }
  }

  Future<int> delete(String teacherId, String notificationId) async {
    try {
      await _getRef(teacherId).child(notificationId).remove();
      return 1;
    } catch (e) {
      print('Error deleting teacher notification $notificationId: $e');
      return 0;
    }
  }

  Future<NotificationModel> create(String teacherId,
      NotificationModel notification) async {
    final newRef = _getRef(teacherId).push();
    await newRef.set(notification.toMap());
    return NotificationModel(
      id: newRef.key,
      title: notification.title,
      body: notification.body,
      timestamp: notification.timestamp,
      isRead: notification.isRead,
    );
  }
}
