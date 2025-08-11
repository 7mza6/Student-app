import 'package:firebase_database/firebase_database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:users/auth/Repositories/userRepository.dart'; // Adjust path
import '../../Repositories/notification_api.dart';
import '../models/UserFields.dart';
import '../models/userModel.dart';                       // Adjust path

class UserApi extends userRepository {
  static final FirebaseDatabase database = FirebaseDatabase.instance;
  final DatabaseReference _usersRef = database.ref('users');
  final DatabaseReference _coursesRef = database.ref('courses');
  final DatabaseReference _teachersRef = database.ref('teachers');

  @override
  Future<user> create(user _user ,{DatabaseExecutor? txn}) {
    return _usersRef.child(_user.id.toString()).set(_user.toJson()).then((_) {
      return _user;
    });
  }

  @override
  Future<user?> readUser(String username) async {
    DataSnapshot snapshot = await _usersRef.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic>? usersData = snapshot.value as Map<dynamic, dynamic>?;
      if (usersData != null) {
        for (var entry in usersData.entries) {
          Map<String, dynamic> userData = Map<String, dynamic>.from(entry.value);
          if (userData['username'] == username) {
            return user.fromJson(userData, entry.key);
          }
        }
      }
    }
    return null;
  }

  @override
  Future<user?> readById(String id) async {
    try {
      final snapshot = await _usersRef.child(id).get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return user.fromJson(data, id);
      }
    } catch (e) {
      print('Error reading user by ID $id: $e');
    }
    return null;
  }

  @override
  Future<List<user>> readAll() async {
    List<user> users = [];
    try {
      final snapshot = await _usersRef.get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        data.forEach((key, value) {
          final userMap = Map<String, dynamic>.from(value);
          users.add(user.fromJson(userMap, key));
        });
      }
    } catch (e) {
      print('Error reading all users: $e');
    }
    return users;
  }

  @override
  Future<int> update(user _user) {
    return _usersRef.child(_user.id.toString()).update(_user.toJson()).then((_) {
      return 1;
    }).catchError((error) {
      print("Failed to update user: $error");
      return 0;
    });
  }

  @override
  Future<int> updatePassword(user _user, String newPassword) {
    return _usersRef.child(_user.id.toString()).update({
      'Password': newPassword,
    }).then((_) {
      return 1;
    }).catchError((error) {
      print("Failed to update password: $error");
      return 0;
    });
  }

  @override
  Future<int> delete(int id) {
    return _usersRef.child(id.toString()).remove().then((_) {
      return 1;
    }).catchError((error) {
      print("Failed to delete user: $error");
      return 0;
    });
  }

  @override
  Future<void> addToken(String userId, String newToken) async {
    if (newToken.isEmpty || newToken == null) {
      print("Token is empty, skipping save.");
      return;
    }

    final tokensRef = _usersRef.child(userId).child('tokens');

    try {
      final snapshot = await tokensRef.get();
      List<String> currentTokens = [];

      if (snapshot.exists && snapshot.value != null) {
        if (snapshot.value is List) {
          currentTokens = List<String>.from((snapshot.value as List).where((t) => t != null));
        } else if (snapshot.value is Map) {
          final tokensMap = snapshot.value as Map<dynamic, dynamic>;
          currentTokens = tokensMap.values.cast<String>().toList();
        }
      }

      if (!currentTokens.contains(newToken)) {
        print("Adding new FCM token for user $userId.");
        currentTokens.add(newToken);
        await tokensRef.set(currentTokens);
      } else {
        print("Token already exists for user $userId.");
      }
    } catch (e) {
      print("Error adding token for user $userId: $e");
      rethrow;
    }
  }




  @override
  Future<void> enrollInCourse(String userId, String courseId) async {
    try {
      await _usersRef
          .child(userId)
          .child(UserFields.enrolledCourses)
          .child(courseId)
          .set(true);

      await _coursesRef
          .child(courseId)
          .child('enrolledStudents')
          .child(userId)
          .set(true);

      final currentUser = CurrentUser.getcurrentUser();
      if (currentUser != null && !currentUser.enrolledCourses.contains(courseId)) {
        final updatedCourses = List<String>.from(currentUser.enrolledCourses)..add(courseId);
        CurrentUser.setcurrentUser(currentUser.copyWith(enrolledCourses: updatedCourses));
      }
      print("SUCCESS: User $userId enrolled in course $courseId");

      await _sendEnrollmentNotification(courseId: courseId, studentName: currentUser?.fullName ?? 'A student', enrolling: true);

    } catch (e) {
      print("ERROR enrolling user $userId in course $courseId: $e");
      rethrow;
    }
  }

  @override
  Future<void> unenrollFromCourse(String userId, String courseId) async {
    try {
      await _usersRef
          .child(userId)
          .child(UserFields.enrolledCourses)
          .child(courseId)
          .remove();

      await _coursesRef
          .child(courseId)
          .child('enrolledStudents')
          .child(userId)
          .remove();

      final currentUser = CurrentUser.getcurrentUser();
      if (currentUser != null && currentUser.enrolledCourses.contains(courseId)) {
        final updatedCourses = List<String>.from(currentUser.enrolledCourses)..remove(courseId);
        CurrentUser.setcurrentUser(currentUser.copyWith(enrolledCourses: updatedCourses));
      }
      print("SUCCESS: User $userId unenrolled from course $courseId");

      await _sendEnrollmentNotification(courseId: courseId, studentName: currentUser?.fullName ?? 'A student', enrolling: false);

    } catch (e) {
      print("ERROR unenrolling user $userId from course $courseId: $e");
      rethrow;
    }
  }

  Future<void> _sendEnrollmentNotification({
    required String courseId,
    required String studentName,
    required bool enrolling,
  }) async {
    try {
      final courseSnapshot = await _coursesRef.child(courseId).get();
      if (!courseSnapshot.exists) return;

      final courseData = Map<String, dynamic>.from(courseSnapshot.value as Map);
      final teacherId = courseData['teacherId'] as String?;
      final courseTitle = courseData['title'] as String? ?? 'your course';

      if (teacherId == null || teacherId.isEmpty) return;

      final teacherTokensSnapshot = await _teachersRef.child(teacherId).child('fcmTokens').get();
      if (!teacherTokensSnapshot.exists || teacherTokensSnapshot.value == null) return;

      List<String> tokens = [];
      if (teacherTokensSnapshot.value is List) {
        tokens = List<String>.from((teacherTokensSnapshot.value as List).where((t) => t != null));
      } else if (teacherTokensSnapshot.value is Map) {
        tokens = (teacherTokensSnapshot.value as Map).values.cast<String>().toList();
      }

      if (tokens.isEmpty) return;
      final String title = enrolling ? 'New Enrollment' : 'Course Unenrollment';
      final String body = enrolling
          ? '$studentName has enrolled in $courseTitle.'
          : '$studentName has unenrolled from $courseTitle.';

      for (final token in tokens) {
        await NotificationApi.sendNotification(
          title: title,
          body: body,
          token: token,
          isStudent: false,
        );
      }
    } catch (e) {
      print("NOTIFICATION ERROR: Could not send enrollment notification. $e");
    }
  }


}