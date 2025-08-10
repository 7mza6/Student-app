import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../Repositories/notification_api.dart';
import '../../Views/homePage.dart';
import '../../Views/main-view.dart';
import '../Repositories/user_api.dart';
import '../models/userModel.dart';
import '../Views/reusable_widgets.dart';


class RegisterViewModel {
  final UserApi _userDatabase = UserApi();

  Future<List<user>> getAllUsers() async {
    return await _userDatabase.readAll();
  }

  Future<void> printAllUsers() async {
    List<user> allUsers = await _userDatabase.readAll();
    for (var u in allUsers) {
      print(
          'ID: ${u.id}, Username: ${u.username}, Email: ${u.email}, Name: ${u.fullName}, Age: ${u.age}');
    }
  }

  Future<user?> getUserByUsername(String username) async {
    return await _userDatabase.readUser(username);
  }



  Future<void> registerUserAndShowDialog({
    required BuildContext context,
    required String username,
    required String password,
    required String email,
    required String phone,
    required String fullName,
    required int age,
  }) async {
    final existingUser = await getUserByUsername(username);
    if (existingUser != null) {
      showCustomDialog(
        bodyText: 'This username is already taken. Please choose another.', //TODO: Add Localization
        context: context,
      );
      return;
    }

    List<user> users = await _userDatabase.readAll();
    int newId = users.isNotEmpty ? users.last.id! + 1 : 1;

    user newUser = user(
      id: newId,
      username: username,
      password: password,
      email: email,
      phone: phone,
      fullName: fullName,
      age: age,
    );

    user? createdUser = await _userDatabase.create(newUser);
    await _userDatabase.addToken(newUser.id.toString(),fVMToken!);

    if (createdUser != null) {
      showCustomDialog(
        bodyText: AppLocalizations.of(context)!.regesteraitinDone,
        context: context,
      );
      CurrentUser.setcurrentUser(createdUser);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => mainView(body: HomePage())),
      );

    } else {
      showCustomDialog(
        bodyText: AppLocalizations.of(context)!.regesteraitinfailed,
        context: context,
      );
    }
  }
}
