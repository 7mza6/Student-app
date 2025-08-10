import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../Models/notification_model.dart';
import '../auth/models/userModel.dart';
import 'TeacherNotificationService.dart';
import 'notification_repository.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';



String? fVMToken = '';
final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
bool _localInitDone = false;

Future<void> initLocalNotifications() async {
  const androidInit = AndroidInitializationSettings('ic_stat_notify'); // default icon
  const init = InitializationSettings(android: androidInit);
  await _local.initialize(init);
  _localInitDone = true;
  await _local.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
}


Future<void> handleForegroundMessage(RemoteMessage message) async {
  if (!_localInitDone) return; // or await a Completer guarding init

  final n = message.notification;
  final a = message.notification?.android;
  if (n != null && a != null) {
    await _local.show(
      n.hashCode,
      n.title,
      n.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'Foreground Notifications',
          channelDescription: 'Used for foreground notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: 'ic_stat_notify', // explicit small icon
        ),
      ),
      payload: message.data.isNotEmpty ? message.data.toString() : null,
    );
  }
}


Future<void> handleBackgroundMessage(RemoteMessage message) async{
  print('sssas');
  await Firebase.initializeApp();
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');

  if(message.notification?.title != null && message.notification?.body != null && CurrentUser.getcurrentUser() != null) {
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
    fVMToken = await _firebaseMessaging.getToken();
    print(fVMToken);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen(handleForegroundMessage);

  }

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
      return 1;
    } catch (e) {
      print('Error updating notification ${notification.id}: $e');
      return 0;
    }
  }

  @override
  Future<int> delete(String userId, String notificationId) async {
    try {
      await _getRef(userId).child(notificationId).remove();
      return 1;
    } catch (e) {
      print('Error deleting notification $notificationId: $e');
      return 0;
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







  static Future<int> sendNotification({
    required String title,
    required String body,
    required String token,
    required bool isStudent
  }) async {
    late String serviceAccountPath ;
    late String fcmEndpoint;
    const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    late String jsonString ;


    if(isStudent){
      serviceAccountPath= 'assets/service_account.json';
      fcmEndpoint= 'https://fcm.googleapis.com/v1/projects/users-99855/messages:send';
      jsonString =await rootBundle.loadString('assets/service_account.json');

    }else if(!isStudent){
      serviceAccountPath = 'assets/Tserves.json';
      fcmEndpoint= 'https://fcm.googleapis.com/v1/projects/teacher-app-b1621/messages:send';
      jsonString =await rootBundle.loadString('assets/Tserves.json');
    }



    final accountCredentials = ServiceAccountCredentials.fromJson(jsonString);

    final authClient = await clientViaServiceAccount(accountCredentials, scopes);
    final message = {
      "message": {
        "token": token,
        "notification": {"title": title, "body": body}
      }
    };


    final response = await authClient.post(
      Uri.parse(fcmEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(message),
    );


    print('FCM response status: ${response.statusCode}');
    authClient.close();
    return response.statusCode;

  }













}