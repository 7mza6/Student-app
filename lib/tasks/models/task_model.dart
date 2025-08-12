

import 'assignment_model.dart';
import '../../exams/models/exam_model.dart';
import '../../submissions/models/submission_model.dart';

enum TaskType {
  assignment,
  exam,
}

class Task {
  final String id;
  final String title;
  final DateTime dueDate;
  final TaskType type;

  Submission? userSubmission;

  Task({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.type,
    this.userSubmission,
  });

  factory Task.fromAssignment(Assignment assignment) {
    return Task(
      id: assignment.id,
      title: assignment.title,
      dueDate: assignment.dueDate,
      type: TaskType.assignment,
    );
  }

  factory Task.fromExam(Exam exam) {
    return Task(
      id: exam.id,
      title: exam.title,
      dueDate: exam.startDateTime,
      type: TaskType.exam,
    );
  }

  Assignment get asAssignment {
    if (type != TaskType.assignment) {
      throw StateError('Cannot get Assignment from a task of type $type.');
    }
    return Assignment(
      id: this.id,
      title: this.title,
      dueDate: this.dueDate,
    );
  }

  Exam get asExam {
    if (type != TaskType.exam) {
      throw StateError('Cannot get Exam from a task of type $type.');
    }
    return Exam(
      id: this.id,
      title: this.title,
      date: DateTime(this.dueDate.year, this.dueDate.month, this.dueDate.day),
      startTime: '${this.dueDate.hour.toString().padLeft(2, '0')}:${this.dueDate.minute.toString().padLeft(2, '0')}',
      endTime: '',
      questions: [],
    );
  }
}