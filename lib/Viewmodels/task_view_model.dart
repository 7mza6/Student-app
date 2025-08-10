
import '../Models/Course-model.dart';
import '../Models/exam_model.dart';
import '../Models/submission_model.dart';
import '../Repositories/assignment_api.dart';
import '../Repositories/exam_api.dart';
import '../Models/assignment_model.dart';
import '../Repositories/submission_api.dart';
import '../auth/models/userModel.dart';
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
  final assignmentApi = AssignmentApi();
  final examApi = ExamApi();
  final submissionApi = SubmissionApi();

  final results = await Future.wait([
    assignmentApi.readAllForCourse(courseId),
    examApi.readAllForCourse(courseId),
  ]);

  final assignments = results[0] as List<Assignment>;
  final exams = results[1] as List<Exam>;

  final List<TaskWithSubmission> assignmentTasks = [];
  for (var assignment in assignments) {
    final submission = await submissionApi.readForStudent(courseId, assignment.id, 'assignments', studentId);
    assignmentTasks.add(TaskWithSubmission(task: assignment, submission: submission));
  }

  final List<TaskWithSubmission> examTasks = [];
  for (var exam in exams) {
    final submission = await submissionApi.readForStudent(courseId, exam.id, 'exams', studentId);
    examTasks.add(TaskWithSubmission(task: exam, submission: submission));
  }

  return {
    'assignments': assignmentTasks,
    'exams': examTasks,
  };
}

Future<Map<Course, Map<String, List<TaskWithSubmission>>>> fetchAllGradedTasksByCourse() async {
  final currentUser = CurrentUser.getcurrentUser();
  if (currentUser == null || currentUser.id == null) return {};

  final Map<Course, Map<String, List<TaskWithSubmission>>> gradedTasksByCourse = {};

  final List<Course> enrolledCourses = await fetchEnrolledCourses();

  for (final course in enrolledCourses) {
    final tasksForThisCourse = await fetchTasksAndSubmissions(
      courseId: course.id!,
      studentId: currentUser.id!.toString(),
    );

    final gradedAssignments = tasksForThisCourse['assignments']!
        .where((task) => task.submission != null && task.submission!.grade != null)
        .toList();

    final gradedExams = tasksForThisCourse['exams']!
        .where((task) => task.submission != null && task.submission!.grade != null)
        .toList();

    if (gradedAssignments.isNotEmpty || gradedExams.isNotEmpty) {
      gradedTasksByCourse[course] = {
        'assignments': gradedAssignments,
        'exams': gradedExams,
      };
    }
  }

  return gradedTasksByCourse;
}