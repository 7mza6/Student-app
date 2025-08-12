import 'package:flutter/material.dart';
import '../../submissions/models/submission_model.dart';
import '../../submissions/Repositories/submission_api.dart';
import '../../auth/models/userModel.dart';

Future<void> submitExam(BuildContext context,var exam) async {
  exam.setState(() => exam.isLoading = true);

  final Map<String, dynamic> answersToSubmit = exam.userAnswers.map(
        (key, value) => MapEntry(key.toString(), value),
  );

  double totalGrade = 0;
  for (int i = 0; i < exam.widget.exam.questions.length; i++) {
    final question = exam.widget.exam.questions[i];
    if (exam.userAnswers.containsKey(i) && exam.userAnswers[i] == question.correctAnswer) {
      totalGrade += question.grade;
    }
  }

  final submissionContent = "Exam completed with a score of $totalGrade / ${exam.widget.exam.questions.fold<double>(0, (sum, item) => sum + item.grade)}";

  final submission = Submission(
    studentId: CurrentUser.getcurrentUser()!.id.toString(),
    content: submissionContent,
    submittedAt: DateTime.now(),
    grade: totalGrade,
    answers: answersToSubmit,
  );

  try {
    await SubmissionApi().create(exam.widget.courseId, exam.widget.exam.id, 'exams', submission);
    if (exam.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Exam submitted successfully!"), backgroundColor: Colors.green));
      Navigator.of(context).pop(true);
    }
  } catch (e) {
    if (exam.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to submit exam: $e"), backgroundColor: Colors.red));
      exam.setState(() => exam.isLoading = false);
    }
  }
}