
import 'package:sqflite/sqflite.dart';

import '../Models/notification_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> readAllForUser(String userId);

  Future<int> update(String userId, NotificationModel notification,{DatabaseExecutor? txn});

  Future<int> delete(String userId, String notificationId);

  Future<NotificationModel> create(String userId, NotificationModel notification);
}