import '../models/task_model.dart';
import '../../exams/Repositories/exam_local.dart';
import 'assignment_local.dart';
import '../../submissions/Repositories/submission_local.dart';

class TaskLocal {
  final AssignmentLocal _assignmentLocal = AssignmentLocal();
  final ExamLocal _examLocal = ExamLocal();
  final SubmissionLocal _submissionLocal = SubmissionLocal();

  Future<List<Task>> getAllTasksForCourse(String courseId, String studentId) async {
    final List<Task> tasks = [];

    final localAssignments = await _assignmentLocal.readAllForCourse(courseId);
    final localExams = await _examLocal.readAllForCourse(courseId);

    tasks.addAll(localAssignments.map((a) => Task.fromAssignment(a)));
    tasks.addAll(localExams.map((e) => Task.fromExam(e)));

    for (final task in tasks) {
      final typeString = task.type == TaskType.assignment ? 'assignments' : 'exams';
      task.userSubmission = await _submissionLocal.readForStudent(
        courseId,
        task.id,
        typeString,
        studentId,
      );
    }

    tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return tasks;
  }
}

