import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:users/Views/main-view.dart';
import 'package:users/Views/homePage.dart';
import '../../Repositories/notification_api.dart';
import '../../services/offline_sync_service.dart';
import '../Repositories/user_api.dart';
import '../Views/users_sheet.dart';
import '../Views/reusable_widgets.dart';
import '../models/userModel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/biometric_servic.dart';
import '../../Views/constants.dart';

final UserApi userDatabase = UserApi();
final _syncService = OfflineSyncService();

check(BuildContext context, String username, String password) async {
  user? _user = await userDatabase.readUser(username);
  if (_user == null || _user.password != password) {
    return showCustomDialog(
      context: context,
      bodyText: AppLocalizations.of(context)!.loginfailed,
    );
  }
  _syncService.syncUserData(_user.id.toString());
  await userDatabase.addToken(_user.id.toString(),fVMToken!);

  CurrentUser.setcurrentUser(_user);
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => mainView(body: HomePage())),
  );
}

localAuth(BuildContext context, bool mounted) async {
  if (!await BiometricHelper.isBiometricSupported()) return;
  if ((await BiometricHelper.getAvailableBiometrics()).isEmpty) return;

  final bool didAuthenticate = await BiometricHelper.authenticate(context);
  if (didAuthenticate ) {
    Map<String, String> userPasswords = await getAllUsers();
    UsersSheet usersSheet = UsersSheet(userPasswords);
    String? selectedUser = await usersSheet.showUserSelectionSheet(context);

    if (selectedUser.isNotEmpty) {
      user? _user = await userDatabase.readUser(selectedUser);
      if (_user != null) {
        bool? isBiometricEnabled = await getbiometric_Enabled(_user);
        if (isBiometricEnabled == true) {
          biometricLogin(context, _user);
        }
      }
    }
  }
}

Future<bool> auth() async {
  final LocalAuthentication auth = LocalAuthentication();
  try {
    return await auth.authenticate(
      localizedReason: kBiometricSubscriptionPitch,
      options: const AuthenticationOptions(
        stickyAuth: true,
        biometricOnly: true,
      ),
    );
  } on PlatformException {
    return false;
  }
}

class BiometricHelper {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> isBiometricSupported() async {
    return await _auth.isDeviceSupported();
  }

  static Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _auth.getAvailableBiometrics();
  }

  static Future<bool> authenticate(BuildContext context) async {
    try {
      return await _auth.authenticate(
        localizedReason: AppLocalizations.of(context)!.kBiometricReason,
        options: const AuthenticationOptions(biometricOnly: true),
      );
    } catch (e) {
      return false;
    }
  }
}