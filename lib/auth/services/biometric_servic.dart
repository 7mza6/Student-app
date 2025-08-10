

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:users/auth/Viewmodels/login_view_model.dart';
import 'package:users/auth/models/userModel.dart';

final storage = FlutterSecureStorage();

biometric_Enabled(bool val,user _user) async {
  if(val){
  await storeUser(_user);
  }
  if(!val){
  await removeUser(_user);
  }

}

Future<bool?> getbiometric_Enabled(user _user) async {

  String? jsonData = await storage.read(key: 'userPasswords');
  Map<String, String> userPasswords;
  if (jsonData == null) {
    print("No credentials found.");
     userPasswords = {
    };
  }else
  userPasswords = Map<String, String>.from(jsonDecode(jsonData));

  print(userPasswords);

  if(userPasswords.containsKey(_user.username))
  return true;
  else
  return false;
}

storeUser(user _user) async {
  String? jsonData = await storage.read(key: 'userPasswords');
  Map<String, String> userPasswords;

  if (jsonData == null) {
    print("No credentials found.");
     userPasswords = {
    };
  }else
  userPasswords = Map<String, String>.from(jsonDecode(jsonData));

  userPasswords[_user.username!] = _user.password!;
  
  jsonData = jsonEncode(userPasswords);
  await storage.write(key: 'userPasswords', value: jsonData);
}


removeUser(user _user) async {
String? jsonData = await storage.read(key: 'userPasswords');
Map<String, String> userPasswords;

userPasswords = Map<String, String>.from(jsonDecode(jsonData!));
userPasswords.remove(_user.username);
jsonData = jsonEncode(userPasswords);
await storage.write(key: 'userPasswords', value: jsonData);

}

biometricLogin(BuildContext context,user _user) async {
  final bool? isBiometricEnabled = await getbiometric_Enabled(_user);


  if (_user.username == null || isBiometricEnabled == 'false' || isBiometricEnabled == null) {
   // Fluttertoast.showToast(msg: "No user linked to biometrics.");
    return;
  }
  if (_user == null) {
    //Fluttertoast.showToast(msg: "User not found in database.");
    return;
  }
  check(context, _user.username!,_user.password!);
  
}


getAllUsers() async {
String? jsonData = await storage.read(key: 'userPasswords');
Map<String, String> userPasswords;

userPasswords = Map<String, String>.from(jsonDecode(jsonData!));
  return userPasswords;
}