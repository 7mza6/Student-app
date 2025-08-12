// lib/auth/Views/reusable_widgets.dart

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../shared/Viewmodels/constants.dart';

void showCustomDialog({required BuildContext context, required String bodyText, bool? swich}) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => Dialog(
      child: Padding(
        padding: kDialogPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(bodyText),
            kHeightSpacer15,
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.close),
            ),
            Visibility(
              visible: swich ?? false,
              child: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
          ],
        ),
      ),
    ),
  );
}