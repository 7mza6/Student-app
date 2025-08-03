

import '../Models/notification_model.dart';
import '../Repositories/notification_api.dart';

/// Fetches all notifications for a given user ID from the API.
Future<List<NotificationModel>> fetchNotificationsForUser(String userId) async {
  final NotificationApi notificationApi = NotificationApi();
  try {
    print("Fetching notifications for user: $userId");
    return await notificationApi.readAllForUser(userId);
  } catch (e) {
    print("An error occurred while fetching notifications: $e");
    return []; // Return an empty list on failure
  }
}



Future<void> insertTestNotifications(String userId) async {
  print("--- Inserting Test Notifications for user: $userId ---");
  final NotificationApi api = NotificationApi();

  final List<NotificationModel> testNotifications = [
    NotificationModel(
      title: "Assignment Graded",
      body: "Your submission for 'Calculus Homework 3' has been graded. Your score is 95/100.",
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      title: "New Course Announcement",
      body: "Enrollment is now open for 'Advanced Flutter Widgets'. Sign up today!",
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true, // Mark one as already read
    ),
    NotificationModel(
      title: "Upcoming Deadline",
      body: "Your project for 'Cloud Computing Essentials' is due in 3 days.",
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
  ];

  for (final notification in testNotifications) {
    try {
      await api.create(userId, notification);
      print("SUCCESS: Created notification '${notification.title}'");
    } catch (e) {
      print("ERROR: Failed to create notification. Reason: $e");
    }
  }

  print("--- Test Notification Insertion Complete ---");
}