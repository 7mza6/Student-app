
import '../Models/Course-model.dart';
import '../Repositories/course_api.dart';
import '../auth/models/userModel.dart';


Future<List<Course>> fetchCoursesFromDatabase() async {
  final CourseApi courseApi = CourseApi();
  try {
    final List<Course> courses = await courseApi.readAll();
    print("Successfully fetched ${courses.length} courses.");
    return courses;
  } catch (e) {
    print("An error occurred while fetching courses from the API: $e");
    return [];
  }
}

Future<List<Course>> fetchUnenrolledCourses() async {
  final currentUser =  CurrentUser.getcurrentUser();
  if (currentUser == null || currentUser.id == null) {
    print("No logged-in user found.");
    return [];
  }
  final courseApi = CourseApi();
  final List<Course> availableCourses = [];
  final userEnrolledIds = currentUser.enrolledCourses;
  final allCourses = await courseApi.readAll();
  for (final course in allCourses) {
    if (!userEnrolledIds.contains(course.id)) {
      availableCourses.add(course);
    }
  }

  return availableCourses;
}


Future<List<Course>> fetchEnrolledCourses() async {
  final currentUser =  CurrentUser.getcurrentUser();
  if (currentUser == null || currentUser.id == null) {
    print("No logged-in user found.");
    return [];
  }

  final userEnrolledIds = currentUser.enrolledCourses;

  if (userEnrolledIds.isEmpty) {
    print("User is not enrolled in any courses.");
    return [];
  }

  final courseApi = CourseApi();
  final List<Course> enrolledCourses = [];
  final allCourses = await courseApi.readAll();

  for (final course in allCourses) {
    if (userEnrolledIds.contains(course.id)) {
      enrolledCourses.add(course);
    }
  }

  return enrolledCourses;
}

