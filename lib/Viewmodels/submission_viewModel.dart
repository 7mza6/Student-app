import 'package:users/Viewmodels/task_view_model.dart';
import '../Models/Course-model.dart';
import '../auth/models/userModel.dart';
import 'Courses-Model.dart';

Future<Map<Course, Map<String, List<TaskWithSubmission>>>> fetchAllTasksForEnrolledCourses() async {
  final currentUser = CurrentUser.getcurrentUser();
  if (currentUser == null || currentUser.id == null) {
    print("No user logged in to fetch tasks for.");
    return {};
  }
  final Map<Course, Map<String, List<TaskWithSubmission>>> allTasksByCourse = {};
  final List<Course> enrolledCourses = await fetchEnrolledCourses();
  for (final course in enrolledCourses) {
    final tasksForThisCourse = await fetchTasksAndSubmissions(
      courseId: course.id!,
      studentId: currentUser.id!.toString(),
    );
    allTasksByCourse[course] = tasksForThisCourse;
  }
  return allTasksByCourse;
}