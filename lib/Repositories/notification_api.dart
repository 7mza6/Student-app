import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../Models/notification_model.dart';
import '../auth/models/userModel.dart';
import 'notification_repository.dart';
import '../services/network_info.dart';
import 'local/notification_local.dart';

String? fVMToken = '';
final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
bool _localInitDone = false;

Future<void> initLocalNotifications() async {
  const androidInit = AndroidInitializationSettings('ic_stat_notify');
  const init = InitializationSettings(android: androidInit);
  await _localNotificationsPlugin.initialize(init);
  _localInitDone = true;
  await _localNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
}

Future<void> handleForegroundMessage(RemoteMessage message) async {
  if (!_localInitDone) return;
  final n = message.notification;
  if (n != null) {
    await _localNotificationsPlugin.show(
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
          icon: 'ic_stat_notify',
        ),
      ),
      payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
    );
  }
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  if(message.notification?.title != null && message.notification?.body != null && CurrentUser.getcurrentUser() != null) {
    final NotificationApi notificationApi = NotificationApi();
    await notificationApi.create(CurrentUser.getcurrentUser()!.id.toString(), NotificationModel(
        title: message.notification!.title!,
        body: message.notification!.body!,
        timestamp: DateTime.now()));
  }
}

class NotificationApi implements NotificationRepository {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _local = NotificationLocal();
  final _uuid = const Uuid();

  Future<void> initNotifications() async{
    await _firebaseMessaging.requestPermission();
    fVMToken = await _firebaseMessaging.getToken();
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen(handleForegroundMessage);
  }

  DatabaseReference _getRef(String userId) => _database.ref('notifications/$userId');

  @override
  Future<NotificationModel> create(String userId, NotificationModel notification) async {
    final notificationWithId = notification.id == null || notification.id!.isEmpty
        ? notification.copyWith(id: _uuid.v4())
        : notification;
    await _local.create(userId, notificationWithId);
    if (await NetworkInfo.isOnline) {
      try {
        await _getRef(userId).child(notificationWithId.id!).set(notification.toMap());
      } catch (e) {
        print("Network error on Notification create, saved locally. Error: $e");
      }
    }
    return notificationWithId;
  }

  @override
  Future<List<NotificationModel>> readAllForUser(String userId) async {
    if (await NetworkInfo.isOnline) {
      try {
        final List<NotificationModel> remoteNotifications = [];
        final snapshot = await _getRef(userId).get();
        if (snapshot.exists && snapshot.value != null) {
          final data = Map<String, dynamic>.from(snapshot.value as Map);
          data.forEach((id, notifData) {
            remoteNotifications.add(NotificationModel.fromMap(Map<String, dynamic>.from(notifData), id));
          });
        }
        await _local.upsertMany(userId, remoteNotifications);
        return remoteNotifications;
      } catch (e) {
        print("Network error on Notification readAll, falling back to local. Error: $e");
        return _local.readAllForUser(userId);
      }
    } else {
      print("Offline: Reading all Notifications from local DB.");
      return _local.readAllForUser(userId);
    }
  }

  @override
  Future<int> update(String userId, NotificationModel notification,{DatabaseExecutor? txn}) async {
    final localResult = await _local.update(userId, notification);
    if (await NetworkInfo.isOnline) {
      try {
        if (notification.id != null) {
          await _getRef(userId).child(notification.id!).update(notification.toMap());
        }
      } catch (e) {
        print("Network error on Notification update, saved locally. Error: $e");
      }
    }
    return localResult;
  }

  @override
  Future<int> delete(String userId, String notificationId) async {
    final localResult = await _local.delete(userId, notificationId);
    if (await NetworkInfo.isOnline) {
      try {
        await _getRef(userId).child(notificationId).remove();
      } catch (e) {
        print("Network error on Notification delete, deleted locally. Error: $e");
      }
    }
    return localResult;
  }

  static Future<int> sendNotification({
    required String title,
    required String body,
    required String token,
    required bool isStudent
  }) async {
    late String fcmEndpoint;
    const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    late String jsonString;

    if(isStudent){
      fcmEndpoint= 'https://fcm.googleapis.com/v1/projects/users-99855/messages:send';
      jsonString = await rootBundle.loadString('assets/service_account.json');
    } else {
      fcmEndpoint= 'https://fcm.googleapis.com/v1/projects/teacher-app-b1621/messages:send';
      jsonString = await rootBundle.loadString('assets/Tserves.json');
    }

    final accountCredentials = ServiceAccountCredentials.fromJson(jsonString);
    final authClient = await clientViaServiceAccount(accountCredentials, scopes);
    final message = { "message": { "token": token, "notification": {"title": title, "body": body} } };
    final response = await authClient.post( Uri.parse(fcmEndpoint), headers: {'Content-Type': 'application/json'}, body: jsonEncode(message));
    authClient.close();
    return response.statusCode;
  }
}