
import 'package:sqflite/sqflite.dart';

import '../Models/submission_model.dart';

abstract class SubmissionRepository {
  Future<Submission> create(String courseId, String taskId, String type, Submission submission, {DatabaseExecutor? txn});

  Future<List<Submission>> readAllForTask(String courseId, String taskId, String type);

  Future<Submission?> readForStudent(String courseId, String taskId, String type, String studentId);

  Future<int> update(String courseId, String taskId, String type, Submission submission);

  Future<int> delete(String courseId, String taskId, String type, String submissionId);
}