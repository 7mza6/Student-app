import 'package:flutter/material.dart';
import 'package:users/auth/models/userModel.dart';

import '../Models/notification_model.dart';
import '../Repositories/notification_api.dart';
import '../Viewmodels/notification-viewModel.dart';



class NotificationBody extends StatefulWidget {
  final String userId = CurrentUser.getcurrentUser()?.id.toString()??'15'; // Pass the current user's ID to the widget

   NotificationBody({super.key});

  @override
  State<NotificationBody> createState() => _NotificationBodyState();
}

class _NotificationBodyState extends State<NotificationBody> {
  late Future<List<NotificationModel>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = fetchNotificationsForUser(widget.userId);
  }

  void _markAsRead(NotificationModel notification) {
    // Avoid marking as read if it's already read
    if (notification.isRead) return;

    final NotificationApi api = NotificationApi();
    // Create an updated version of the notification
    final updatedNotification = notification.copyWith(isRead: true);

    // Call the API to update the data in Firebase
    api.update(widget.userId, updatedNotification).then((success) {
      if (success == 1) {
        // If the update is successful, refresh the UI state
        setState(() {
          // Re-fetch the data to show the change
          _notificationsFuture = fetchNotificationsForUser(widget.userId);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NotificationModel>>(
      future: _notificationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "You have no notifications.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        final notifications = snapshot.data!;
        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            final bool isRead = notification.isRead;
            return InkWell(
              onTap: () => _markAsRead(notification),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                color: isRead ? Colors.transparent : Colors.blue.withOpacity(0.08),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isRead ? Icons.notifications_none : Icons.notifications_active,
                      color: isRead ? Colors.grey : Theme.of(context).primaryColor,
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isRead ? Colors.grey[700] : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.body,
                            style: TextStyle(
                              fontSize: 14,
                              color: isRead ? Colors.grey[600] : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            // Simple time formatting for demonstration
                            '${notification.timestamp.hour}:${notification.timestamp.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}