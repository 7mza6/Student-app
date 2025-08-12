import 'package:users/courses/Repositories/courseLocal.dart';

import '../../auth/models/userModel.dart';
import '../../shared/services/network_info.dart';
import '../Models/Course-model.dart';
import '../Repositories/course_api.dart';


Future<List<Course>> fetchCoursesFromDatabase() async {
  final courseApi = CourseApi();
  final courseLocal = CourseLocal();

  if (await NetworkInfo.isOnline) {
    try {
      print("Online: Fetching all courses from API...");
      final remoteCourses = await courseApi.readAll();
      await courseLocal.upsertMany(remoteCourses); // Cache the result
      return remoteCourses;
    } catch (e) {
      print("Network error fetching all courses, falling back to local. Error: $e");
      return await courseLocal.readAll();
    }
  } else {
    print("Offline: Fetching all courses from local DB.");
    return await courseLocal.readAll();
  }
}

Future<List<Course>> fetchUnenrolledCourses() async {
  final currentUser = CurrentUser.getcurrentUser();
  if (currentUser == null) return [];

  final allCourses = await fetchCoursesFromDatabase();
  final userEnrolledIds = currentUser.enrolledCourses;

  return allCourses.where((course) => !userEnrolledIds.contains(course.id)).toList();
}

Future<List<Course>> fetchEnrolledCourses() async {
  final currentUser = CurrentUser.getcurrentUser();
  if (currentUser == null) return [];

  final allCourses = await fetchCoursesFromDatabase();
  final userEnrolledIds = currentUser.enrolledCourses;

  if (userEnrolledIds.isEmpty) return [];

  return allCourses.where((course) => userEnrolledIds.contains(course.id)).toList();
}