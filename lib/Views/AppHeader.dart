

import 'package:flutter/material.dart';
import '../Viewmodels/Courses-Model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Viewmodels/notification-viewModel.dart';
import '../auth/models/userModel.dart';
import 'Courses.dart';


PreferredSizeWidget AppHeader(BuildContext context) {
  return AppBar(
    centerTitle: true,
    title:  Text(AppLocalizations.of(context)!.kAppHeaderTitle),
    actions: [
      IconButton(
        icon: const Icon(Icons.notifications),
        onPressed: () async {
         //await insertTestData();

          //insertTestNotifications(CurrentUser.getcurrentUser()?.id.toString()??'15');

        },
      ),
    ],
  );
}