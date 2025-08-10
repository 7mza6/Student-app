import 'package:flutter/material.dart';
import '../Repositories/user_api.dart';
import 'UserFields.dart';

class user {
  final int? id;
  final String? email;
  final String? password;
  final String? username;
  final String? phone;
  final String? fullName;
  final int? age;
  final List<String> enrolledCourses;
  final Map<String, bool>? notificationSettings;
  final List<String> tokens;

  user({
    @required this.id,
    @required this.email,
    @required this.password,
    @required this.username,
    @required this.phone,
    this.fullName,
    this.age,
    this.enrolledCourses = const [],
    this.notificationSettings,
    this.tokens = const [],
  });

  user copyWith({
    int? id,
    String? email,
    String? password,
    String? username,
    String? phone,
    String? fullName,
    int? age,
    List<String>? enrolledCourses,
    Map<String, bool>? notificationSettings,
    List<String>? tokens,
  }) {
    return user(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      tokens: tokens ?? this.tokens,
    );
  }

  factory user.fromJson(Map<String, dynamic> json, String id) {
    List<String> courses = [];
    if (json[UserFields.enrolledCourses] != null) {
      final coursesMap = json[UserFields.enrolledCourses] as Map<dynamic, dynamic>;
      courses = coursesMap.keys.cast<String>().toList();
    }

    List<String> parsedTokens = [];
    if (json[UserFields.tokens] != null) {
      if (json[UserFields.tokens] is List) {
        parsedTokens = List<String>.from(json[UserFields.tokens].where((t) => t != null));
      } else if (json[UserFields.tokens] is Map) {
        final tokensMap = json[UserFields.tokens] as Map<dynamic, dynamic>;
        parsedTokens = tokensMap.values.cast<String>().toList();
      }
    }

    return user(
      id: int.parse(id),
      email: json[UserFields.email] ?? '',
      username: json[UserFields.username] ?? '',
      password: json[UserFields.password] ?? '',
      phone: json[UserFields.phone] ?? '',
      fullName: json[UserFields.fullName] as String?,
      age: json[UserFields.age] as int?,
      enrolledCourses: courses,
      notificationSettings: json[UserFields.notificationSettings] != null
          ? Map<String, bool>.from(json[UserFields.notificationSettings])
          : null,
      tokens: parsedTokens,
    );
  }

  factory user.fromMap(Map<dynamic, dynamic> map) {
    return user.fromJson(Map<String, dynamic>.from(map), map[UserFields.id].toString());
  }

  Map<String, dynamic> toJson() {
    Map<String, bool> coursesMap = {
      for (var courseId in enrolledCourses) courseId: true
    };

    return {
      UserFields.id: id,
      UserFields.email: email,
      UserFields.username: username,
      UserFields.password: password,
      UserFields.phone: phone,
      UserFields.fullName: fullName,
      UserFields.age: age,
      UserFields.enrolledCourses: coursesMap,
      UserFields.notificationSettings: notificationSettings,
      UserFields.tokens: tokens,
    };
  }
}

class CurrentUser {
  static user? currentUser;

  static Future<void> updateCurrentUser() async {
    final currentId = currentUser?.id?.toString();
    if(currentId != null) {
      currentUser =  await UserApi().readById(currentId);
    }
  }

  static user? getcurrentUser() => currentUser;

  static void setcurrentUser(user? user) {
    currentUser = user;
    if (user != null) {
      print('currentUser updated: ${currentUser?.email}, Name: ${currentUser?.fullName}');
    }
  }

  static void clearCurrentUser() {
    currentUser = null;
  }
}