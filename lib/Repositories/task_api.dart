import 'package:firebase_database/firebase_database.dart';
import '../Models/assignment_model.dart';
import '../Models/exam_model.dart';
import '../Models/task_model.dart';
import '../services/network_info.dart';
import 'local/assignment_local.dart';
import 'local/exam_local.dart';
import 'local/submission_local.dart';
import 'submission_api.dart';

class TaskApi {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  final SubmissionApi _submissionApi = SubmissionApi();

  final _assignmentLocal = AssignmentLocal();
  final _examLocal = ExamLocal();
  final _submissionLocal = SubmissionLocal();

  Future<List<Task>> getAllTasksForCourse(String courseId, String studentId) async {
    final List<Task> tasks = [];
    final courseRef = _database.ref('courses/$courseId');

    if (await NetworkInfo.isOnline) {
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

        await _assignmentLocal.upsertMany(
            courseId, tasks.where((t) => t.type == TaskType.assignment).map((t) => t.asAssignment).toList()
        );
        await _examLocal.upsertMany(
            courseId, tasks.where((t) => t.type == TaskType.exam).map((t) => t.asExam).toList()
        );

        await Future.wait(tasks.map((task) async {
          final typeString = task.type == TaskType.assignment ? 'assignments' : 'exams';
          final sub = await _submissionApi.readForStudent(courseId, task.id, typeString, studentId);
          task.userSubmission = sub;
        }));

      } catch (e) {
        print("Network error fetching tasks, falling back to local. Error: $e");
        return _offlineTasks(courseId, studentId);
      }
    } else {
      print("Offline: Reading tasks from local DB.");
      return _offlineTasks(courseId, studentId);
    }

    tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return tasks;
  }

  Future<List<Task>> _offlineTasks(String courseId, String studentId) async {
    final List<Task> tasks = [];
    final asg = await _assignmentLocal.readAllForCourse(courseId);
    final exs = await _examLocal.readAllForCourse(courseId);

    tasks.addAll(asg.map((a) => Task.fromAssignment(a)));
    tasks.addAll(exs.map((e) => Task.fromExam(e)));

    for (final t in tasks) {
      final typeString = t.type == TaskType.assignment ? 'assignments' : 'exams';
      t.userSubmission =
      await _submissionLocal.readForStudent(courseId, t.id, typeString, studentId);
    }

    tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return tasks;
  }
}