

import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../Repositories/notification_api.dart';
import 'main-view.dart';
import 'notification_body.dart';


PreferredSizeWidget AppHeader(BuildContext context,var mainView) {
  return AppBar(
    centerTitle: true,
    title:  Text(AppLocalizations.of(context)!.kAppHeaderTitle),
    actions: [
      IconButton(
        icon: const Icon(Icons.notifications),
        onPressed: ()  async {
          final token = 'cdz__maITZCYOwkNZWuGjY:APA91bFikor0EeF070PooTktd8AS5jHyV8RJk9IMk6ZaalF43Zpp9TuzZ2fGhcAgjzrJFfZVzVq85DXX975Ee2DCVXzEEQB3MvbBRPO1h3R0y1_sllawmLs';
          await NotificationApi.sendNotification(title: 'title', body: 'body', token: token, isStudent: false);
          mainView.setBody(NotificationBody());
        },
      ),
    ],
  );
}