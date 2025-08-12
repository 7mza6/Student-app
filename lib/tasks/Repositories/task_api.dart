import 'package:firebase_database/firebase_database.dart';
import '../models/assignment_model.dart';
import '../../exams/models/exam_model.dart';
import '../models/task_model.dart';
import '../../submissions/Repositories/submission_api.dart'; // This API must also be network-only

/// A pure network client responsible for fetching assignments and exams from Firebase
/// and aggregating them into a unified list of Task objects.
class TaskApi {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  final SubmissionApi _submissionApi = SubmissionApi();

  Future<List<Task>> getAllTasksForCourse(String courseId, String studentId) async {
    final List<Task> tasks = [];
    final courseRef = _database.ref('courses/$courseId');

    try {
      final assignmentsSnapshot = await courseRef.child('assignments').get();
      if (assignmentsSnapshot.exists && assignmentsSnapshot.value != null) {
        final data = Map<String, dynamic>.from(assignmentsSnapshot.value as Map);
        data.forEach((id, assignmentData) {
          final map = Map<String, dynamic>.from(assignmentData);
          final a = Assignment.fromMap(map, id);
          tasks.add(Task.fromAssignment(a));
        });
      }

      final examsSnapshot = await courseRef.child('exams').get();
      if (examsSnapshot.exists && examsSnapshot.value != null) {
        final data = Map<String, dynamic>.from(examsSnapshot.value as Map);
        data.forEach((id, examData) {
          final map = Map<String, dynamic>.from(examData);
          final e = Exam.fromMap(map, id);
          tasks.add(Task.fromExam(e));
        });
      }

      await Future.wait(tasks.map((task) async {
        final typeString = task.type == TaskType.assignment ? 'assignments' : 'exams';
        final sub = await _submissionApi.readForStudent(courseId, task.id, typeString, studentId);
        task.userSubmission = sub;
      }));
    } catch (e) {
      print("FATAL: Network error while fetching tasks for sync: $e");
      rethrow;
    }

    tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return tasks;
  }
}