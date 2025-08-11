import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../Models/submission_model.dart';
import '../Repositories/submission_api.dart';
import '../auth/models/userModel.dart';
import '../services/network_info.dart';
import '../Repositories/local/pending_operation_local.dart';
import '../Repositories/local/submission_local.dart';
import '../Models/pending_operation_model.dart';

Future<void> submitExam(BuildContext context, dynamic examState) async {
  examState.setState(() => examState.isLoading = true);

  final submissionApi = SubmissionApi();
  final submissionLocal = SubmissionLocal();
  final pendingOpLocal = PendingOperationLocal();

  final Map<String, dynamic> answersToSubmit = examState.userAnswers.map((k, v) => MapEntry(k.toString(), v));
  double totalGrade = 0; // Grade calculation logic...
  final submission = Submission(
    id: Uuid().v4(), // Generate a local ID for immediate use
    studentId: CurrentUser.getcurrentUser()!.id.toString(),
    content: "Exam completed...", // Your content logic
    submittedAt: DateTime.now(),
    grade: totalGrade,
    answers: answersToSubmit,
  );

  final courseId = examState.widget.courseId;
  final taskId = examState.widget.exam.id;
  const type = 'exams';

  try {
    await submissionLocal.create(courseId, taskId, type, submission);

    if (await NetworkInfo.isOnline) {
      // --- ONLINE PATH ---
      print("Online: Submitting exam directly to Firebase.");
      await submissionApi.create(courseId, taskId, type, submission);
    } else {
      print("Offline: Queuing exam submission for later sync.");
      final payload = {
        'courseId': courseId,
        'taskId': taskId,
        'type': type,
        'submission': submission.toMap(),
      };

      final operation = PendingOperation(
        type: 'create_submission',
        payload: jsonEncode(payload),
        createdAt: DateTime.now(),
      );
      await pendingOpLocal.create(operation);
    }

    if (examState.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(await NetworkInfo.isOnline ? "Exam submitted successfully!" : "Exam saved. Will submit when online."),
        backgroundColor: Colors.green,
      ));
      Navigator.of(context).pop(true);
    }
  } catch (e) {
    if (examState.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to save exam submission: $e"),
        backgroundColor: Colors.red,
      ));
      examState.setState(() => examState.isLoading = false);
    }
  }
}