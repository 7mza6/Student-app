import 'package:firebase_database/firebase_database.dart';
import '../Models/notification_model.dart';
import '../auth/models/userModel.dart';
import 'notification_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';


Future<void> handleBackgroundMessage(RemoteMessage message) async{
  await Firebase.initializeApp();
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');

  if(message.notification?.title != null && message.notification?.body != null) {
    final NotificationApi notificationApi = NotificationApi();
    await notificationApi.create(CurrentUser
        .getcurrentUser()
        ?.id
        .toString() ?? '15', NotificationModel(
        title: (message.notification?.title)!,
        body: (message.notification?.body)!,
        timestamp: DateTime.now()));
  }
}

class NotificationApi extends NotificationRepository {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  final _firebaseMessaging = FirebaseMessaging.instance;


  Future<void> initNotifications() async{
    await _firebaseMessaging.requestPermission();
    final fVMToken = await _firebaseMessaging.getToken();
    print('Token : $fVMToken');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

  }





  // Helper to get the reference to a user's notifications
  DatabaseReference _getRef(String userId) {
    return _database.ref('notifications/$userId');
  }

  @override
  Future<List<NotificationModel>> readAllForUser(String userId) async {
    final List<NotificationModel> notifications = [];
    try {
      final snapshot = await _getRef(userId).get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        data.forEach((notificationId, notificationData) {
          final notificationMap = Map<String, dynamic>.from(notificationData);
          notifications.add(NotificationModel.fromMap(notificationMap, notificationId));
        });
        // Sort notifications by timestamp, newest first.
        notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
    } catch (e) {
      print('Error reading notifications for user $userId: $e');
    }
    return notifications;
  }

  @override
  Future<int> update(String userId, NotificationModel notification) async {
    if (notification.id == null) return 0;
    try {
      await _getRef(userId).child(notification.id!).update(notification.toMap());
      return 1; // Success
    } catch (e) {
      print('Error updating notification ${notification.id}: $e');
      return 0; // Failure
    }
  }

  @override
  Future<int> delete(String userId, String notificationId) async {
    try {
      await _getRef(userId).child(notificationId).remove();
      return 1; // Success
    } catch (e) {
      print('Error deleting notification $notificationId: $e');
      return 0; // Failure
    }
  }

  @override
  Future<NotificationModel> create(String userId, NotificationModel notification) async {
    final newRef = _getRef(userId).push();
    await newRef.set(notification.toMap());
    return NotificationModel(
        id: newRef.key,
        title: notification.title,
        body: notification.body,
        timestamp: notification.timestamp,
        isRead: notification.isRead);
  }


}