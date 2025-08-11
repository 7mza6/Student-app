

import '../Models/notification_model.dart';
import '../Repositories/local/notification_local.dart';
import '../Repositories/notification_api.dart';
import '../services/network_info.dart';

Future<List<NotificationModel>> fetchNotificationsForUser(String userId) async {
  final notificationApi = NotificationApi();
  final notificationLocal = NotificationLocal();

  if (await NetworkInfo.isOnline) {
    try {
      print("Online: Fetching notifications from API...");
      final remoteNotifications = await notificationApi.readAllForUser(userId);
      await notificationLocal.upsertMany(userId, remoteNotifications); // Cache result
      return remoteNotifications;
    } catch (e) {
      print("Network error fetching notifications, falling back to local. Error: $e");
      return await notificationLocal.readAllForUser(userId);
    }
  } else {
    print("Offline: Fetching notifications from local DB.");
    return await notificationLocal.readAllForUser(userId);
  }
}

