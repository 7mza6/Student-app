
import '../Models/Course-model.dart';
import '../Models/exam_model.dart';
import '../Models/submission_model.dart';
import '../Models/task_model.dart';
import '../Repositories/assignment_api.dart';
import '../Repositories/exam_api.dart';
import '../Models/assignment_model.dart';
import '../Repositories/local/task_local.dart';
import '../Repositories/submission_api.dart';
import '../Repositories/task_api.dart';
import '../auth/models/userModel.dart';
import '../services/network_info.dart';
import 'Courses-Model.dart';

class TaskWithSubmission {
  final dynamic task;
  final Submission? submission;

  TaskWithSubmission({required this.task, this.submission});

  String get id => task.id;
  String get title => task.title;

  DateTime get dueDate {
    if (task is Assignment) {
      return (task as Assignment).dueDate;
    } else if (task is Exam) {
      return (task as Exam).date;
    } else {
      throw UnsupportedError('Unsupported task type: ${task.runtimeType}');
    }
  }
}


  Future<Map<String, List<TaskWithSubmission>>> fetchTasksAndSubmissions({
    required String courseId,
    required String studentId,
  }) async {
    final taskApi = TaskApi();
    final taskLocal = TaskLocal();
    List<Task> tasks;

    if (await NetworkInfo.isOnline) {
      try {
        print("Online: Fetching tasks for course $courseId from API...");
        tasks = await taskApi.getAllTasksForCourse(courseId, studentId);
        // The TaskApi's responsibility is to also cache the data it fetches.
      } catch (e) {
        print("Network error fetching tasks, falling back to local. Error: $e");
        tasks = await taskLocal.getAllTasksForCourse(courseId, studentId);
      }
    } else {
      print("Offline: Fetching tasks for course $courseId from local DB.");
      tasks = await taskLocal.getAllTasksForCourse(courseId, studentId);
    }

    // Convert List<Task> to the required Map<String, List<TaskWithSubmission>> format
    final assignmentTasks = tasks
        .where((t) => t.type == TaskType.assignment)
        .map((t) => TaskWithSubmission(task: t.asAssignment, submission: t.userSubmission))
        .toList();

    final examTasks = tasks
        .where((t) => t.type == TaskType.exam)
        .map((t) => TaskWithSubmission(task: t.asExam, submission: t.userSubmission))
        .toList();

    return {'assignments': assignmentTasks, 'exams': examTasks};
  }

  Future<Map<Course, Map<String, List<TaskWithSubmission>>>> fetchAllGradedTasksByCourse() async {
    final currentUser = CurrentUser.getcurrentUser();
    if (currentUser == null || currentUser.id == null) return {};

    final gradedTasksByCourse = <Course, Map<String, List<TaskWithSubmission>>>{};
    final enrolledCourses = await fetchEnrolledCourses(); // Now offline-aware

    for (final course in enrolledCourses) {
      // This function is now also offline-aware
      final tasksForThisCourse = await fetchTasksAndSubmissions(
        courseId: course.id!,
        studentId: currentUser.id!.toString(),
      );

      final gradedAssignments = tasksForThisCourse['assignments']!.where((t) => t.submission?.grade != null).toList();
      final gradedExams = tasksForThisCourse['exams']!.where((t) => t.submission?.grade != null).toList();

      if (gradedAssignments.isNotEmpty || gradedExams.isNotEmpty) {
        gradedTasksByCourse[course] = {
          'assignments': gradedAssignments,
          'exams': gradedExams,
        };
      }
    }
    return gradedTasksByCourse;
  }

  Future<Map<Course, Map<String, List<TaskWithSubmission>>>> fetchAllTasksForEnrolledCourses() async {
    final currentUser = CurrentUser.getcurrentUser();
    if (currentUser == null || currentUser.id == null) return {};

    final allTasksByCourse = <Course, Map<String, List<TaskWithSubmission>>>{};
    final enrolledCourses = await fetchEnrolledCourses();

    for (final course in enrolledCourses) {
      allTasksByCourse[course] = await fetchTasksAndSubmissions(
        courseId: course.id!,
        studentId: currentUser.id!.toString(),
      );
    }
    return allTasksByCourse;
  }