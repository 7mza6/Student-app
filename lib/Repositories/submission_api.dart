import 'package:firebase_database/firebase_database.dart';
import 'package:users/Models/notification_model.dart';
import 'package:users/Repositories/submission_repository.dart';
import '../Models/submission_model.dart';
import '../auth/models/userModel.dart';
import 'TeacherNotificationService.dart';
import 'notification_api.dart';

class SubmissionApi extends SubmissionRepository {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  final DatabaseReference _coursesRef = _database.ref('courses');
  final DatabaseReference _teachersRef = _database.ref('teachers');

  DatabaseReference _getSubmissionsRef(String courseId, String taskId, String type) {
    return _database.ref('courses/$courseId/$type/$taskId/submissions');
  }

  DatabaseReference _getSubmissionCountRef(String courseId, String taskId, String type) {
    return _database.ref('courses/$courseId/$type/$taskId/submissionsCount');
  }

  @override
  Future<Submission> create(String courseId, String taskId, String type, Submission submission) async {
    final newRef = _getSubmissionsRef(courseId, taskId, type).push();
    await newRef.set(submission.toMap());

    await _getSubmissionCountRef(courseId, taskId, type).runTransaction((Object? currentData) {
      int count = (currentData as int?) ?? 0;
      count++;
      return Transaction.success(count);
    });

    _sendTaskNotification(
        courseId: courseId, taskId: taskId, type: type, studentId: submission.studentId);

    return Submission(
      id: newRef.key!,
      studentId: submission.studentId,
      content: submission.content,
      submittedAt: submission.submittedAt,
      grade: submission.grade,
    );
  }

  @override
  Future<List<Submission>> readAllForTask(String courseId, String taskId, String type) async {
    final List<Submission> submissions = [];
    try {
      final snapshot = await _getSubmissionsRef(courseId, taskId, type).get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        data.forEach((submissionId, submissionData) {
          final submissionMap = Map<String, dynamic>.from(submissionData);
          submissions.add(Submission.fromMap(submissionMap, submissionId));
        });
      }
    } catch (e) {
      print('Error reading submissions for task $taskId: $e');
    }
    return submissions;
  }

  @override
  Future<int> update(String courseId, String taskId, String type, Submission submission) async {
    if (submission.id == null) return 0;
    try {
      await _getSubmissionsRef(courseId, taskId, type).child(submission.id!).update(submission.toMap());
      return 1;
    } catch (e) {
      print('Error updating submission ${submission.id}: $e');
      return 0;
    }
  }

  @override
  Future<int> delete(String courseId, String taskId, String type, String submissionId) async {
    try {
      await _getSubmissionsRef(courseId, taskId, type).child(submissionId).remove();
      await _getSubmissionCountRef(courseId, taskId, type).runTransaction((Object? currentData) {
        if (currentData == null) return Transaction.abort();
        int count = currentData as int;
        if (count > 0) count--;
        return Transaction.success(count);
      });
      return 1;
    } catch (e) {
      print('Error deleting submission $submissionId: $e');
      return 0;
    }
  }

  @override
  Future<Submission?> readForStudent(String courseId, String taskId, String type, String studentId) async {
    try {
      final query = _getSubmissionsRef(courseId, taskId, type).orderByChild('studentId').equalTo(studentId);
      final snapshot = await query.get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final submissionId = data.keys.first;
        final submissionData = Map<String, dynamic>.from(data[submissionId]);
        return Submission.fromMap(submissionData, submissionId);
      }
    } catch (e) {
      print('Error reading submission for student $studentId: $e');
    }
    return null;
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
          title: title,
          body: body,
          token: token,
          isStudent: false,
        );
        if(x==0){
          if(response == 200 ){
            await TeacherNotificationService().create(teacherId , NotificationModel(title: title, body: body, timestamp: DateTime.now()));

          }
          x++;
        }
      }
    } catch (e) {
      print("NOTIFICATION ERROR: Could not send submission notification. $e");
    }
  }

}