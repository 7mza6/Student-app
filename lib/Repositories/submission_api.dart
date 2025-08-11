import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import '../Models/notification_model.dart';
import '../Repositories/submission_repository.dart';
import '../Models/submission_model.dart';
import '../auth/models/userModel.dart';
import '../services/network_info.dart';
import 'TeacherNotificationService.dart';
import 'notification_api.dart';
import 'local/submission_local.dart';
import 'package:sqflite/sqflite.dart' as sql;


class SubmissionApi extends SubmissionRepository {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  final DatabaseReference _coursesRef = _database.ref('courses');
  final DatabaseReference _teachersRef = _database.ref('teachers');

  final SubmissionLocal _local = SubmissionLocal();
  final _uuid = const Uuid();

  DatabaseReference _getSubmissionsRef(String courseId, String taskId, String type) {
    return _database.ref('courses/$courseId/$type/$taskId/submissions');
  }

  DatabaseReference _getSubmissionCountRef(String courseId, String taskId, String type) {
    return _database.ref('courses/$courseId/$type/$taskId/submissionsCount');
  }

  @override
  Future<Submission> create(String courseId, String taskId, String type, Submission submission , {sql.DatabaseExecutor? txn}) async {
    final submissionWithId = submission.id == null || submission.id!.isEmpty
        ? submission.copyWith(id: _uuid.v4())
        : submission;

    await _local.create(courseId, taskId, type, submissionWithId);

    if (await NetworkInfo.isOnline) {
      try {
        await _getSubmissionsRef(courseId, taskId, type).child(submissionWithId.id!).set(submission.toMap());
        await _getSubmissionCountRef(courseId, taskId, type).runTransaction((Object? currentData) {
          int count = (currentData as int?) ?? 0;
          count++;
          return Transaction.success(count);
        });
        _sendTaskNotification(
            courseId: courseId, taskId: taskId, type: type, studentId: submission.studentId);
      } catch (e) {
        print("Network error on Submission create, saved locally. Error: $e");
      }
    }
    return submissionWithId;
  }

  @override
  Future<List<Submission>> readAllForTask(String courseId, String taskId, String type) async {
    if (await NetworkInfo.isOnline) {
      try {
        final List<Submission> remoteSubmissions = [];
        final snapshot = await _getSubmissionsRef(courseId, taskId, type).get();
        if (snapshot.exists && snapshot.value != null) {
          final data = Map<String, dynamic>.from(snapshot.value as Map);
          data.forEach((submissionId, submissionData) {
            final submissionMap = Map<String, dynamic>.from(submissionData);
            remoteSubmissions.add(Submission.fromMap(submissionMap, submissionId));
          });
        }
        await _local.upsertMany(courseId, taskId, type, remoteSubmissions);
        return remoteSubmissions;
      } catch (e) {
        print("Network error fetching submissions, falling back to local. Error: $e");
        return _local.readAllForTask(courseId, taskId, type);
      }
    } else {
      print("Offline: Reading all submissions for task from local DB.");
      return _local.readAllForTask(courseId, taskId, type);
    }
  }

  @override
  Future<Submission?> readForStudent(String courseId, String taskId, String type, String studentId) async {
    if (await NetworkInfo.isOnline) {
      try {
        final query = _getSubmissionsRef(courseId, taskId, type).orderByChild('studentId').equalTo(studentId);
        final snapshot = await query.get();
        if (snapshot.exists && snapshot.value != null) {
          final data = Map<String, dynamic>.from(snapshot.value as Map);
          final submissionId = data.keys.first;
          final submissionData = Map<String, dynamic>.from(data[submissionId]);
          final submission = Submission.fromMap(submissionData, submissionId);
          await _local.create(courseId, taskId, type, submission);
          return submission;
        }
        return _local.readForStudent(courseId, taskId, type, studentId);
      } catch (e) {
        print("Network error fetching submission, falling back to local. Error: $e");
        return _local.readForStudent(courseId, taskId, type, studentId);
      }
    } else {
      print("Offline: Reading student submission from local DB.");
      return _local.readForStudent(courseId, taskId, type, studentId);
    }
  }

  @override
  Future<int> update(String courseId, String taskId, String type, Submission submission) async {
    final localResult = await _local.update(courseId, taskId, type, submission);
    if (await NetworkInfo.isOnline) {
      try {
        if (submission.id != null) {
          await _getSubmissionsRef(courseId, taskId, type).child(submission.id!).update(submission.toMap());
        }
      } catch (e) {
        print("Network error updating submission, but saved locally. Error: $e");
      }
    }
    return localResult;
  }

  @override
  Future<int> delete(String courseId, String taskId, String type, String submissionId) async {
    final localResult = await _local.delete(courseId, taskId, type, submissionId);
    if (await NetworkInfo.isOnline) {
      try {
        await _getSubmissionsRef(courseId, taskId, type).child(submissionId).remove();
        await _getSubmissionCountRef(courseId, taskId, type).runTransaction((Object? currentData) {
          if (currentData == null) return Transaction.abort();
          int count = currentData as int;
          if (count > 0) count--;
          return Transaction.success(count);
        });
      } catch (e) {
        print("Network error deleting submission, but deleted locally. Error: $e");
      }
    }
    return localResult;
  }

  Future<void> _sendTaskNotification({
    required String courseId,
    required String taskId,
    required String type,
    required String studentId,
  }) async {
    try {
      final courseSnapshot = await _coursesRef.child(courseId).get();
      if (!courseSnapshot.exists) return;
      final courseData = Map<String, dynamic>.from(courseSnapshot.value as Map);
      final teacherId = courseData['teacherId'] as String?;
      final courseTitle = courseData['title'] as String? ?? 'your course';

      final taskSnapshot = await _coursesRef.child(courseId).child(type).child(taskId).get();
      if (!taskSnapshot.exists) return;
      final taskData = Map<String, dynamic>.from(taskSnapshot.value as Map);
      final taskTitle = taskData['title'] as String? ?? 'a task';

      if (teacherId == null || teacherId.isEmpty) return;

      final teacherTokensSnapshot = await _teachersRef.child(teacherId).child('fcmTokens').get();
      if (!teacherTokensSnapshot.exists || teacherTokensSnapshot.value == null) return;

      List<String> tokens = [];
      if (teacherTokensSnapshot.value is List) {
        tokens = List<String>.from((teacherTokensSnapshot.value as List).where((t) => t != null));
      } else if (teacherTokensSnapshot.value is Map) {
        tokens = (teacherTokensSnapshot.value as Map).values.cast<String>().toList();
      }

      if (tokens.isEmpty) return;

      final studentName = CurrentUser.getcurrentUser()?.fullName ?? 'A student';
      final String title = 'New Submission Received';
      final String body = '$studentName submitted their work for "$taskTitle" in $courseTitle.';
      int x = 0;
      for (final token in tokens) {
        final response = await NotificationApi.sendNotification(
          title: title, body: body, token: token, isStudent: false,
        );
        if (x == 0) {
          if (response == 200) {
            await TeacherNotificationService().create(teacherId,
                NotificationModel(title: title, body: body, timestamp: DateTime.now()));
          }
          x++;
        }
      }
    } catch (e) {
      print("NOTIFICATION ERROR: Could not send submission notification. $e");
    }
  }
}