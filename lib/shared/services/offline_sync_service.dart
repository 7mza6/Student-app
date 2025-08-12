import 'package:sqflite/sqflite.dart';
import '../Repositories/app_db.dart';

// --- Import all Firebase APIs (Network Layer) ---
import '../../tasks/Repositories/task_api.dart'; // This is a network-only API now
import '../../submissions/Repositories/submission_api.dart';
import '../../notifications/Repositories/notification_api.dart';

// --- Import all Local DB Repositories (Persistence Layer) ---
import '../../courses/Repositories/courseLocal.dart';
import '../../tasks/Repositories/assignment_local.dart';
import '../../submissions/Repositories/submission_local.dart';
import '../../notifications/Repositories/notification_local.dart';

// --- Import all Data Models ---
import '../../tasks/models/task_model.dart';
import '../../tasks/models/assignment_model.dart';
import '../../exams/Repositories/exam_local.dart';
import '../../exams/models/exam_model.dart';
import '../../submissions/models/submission_model.dart';
import '../../notifications/models/notification_model.dart';
import '../../auth/Repositories/user_api.dart';
import '../../auth/Repositories/usersLocal.dart';
import '../../auth/models/userModel.dart';
import '../../courses/Repositories/course_api.dart';

class OfflineSyncService {
  final _userApi = UserApi();
  final _courseApi = CourseApi();
  final _taskApi = TaskApi();
  final _submissionApi = SubmissionApi();
  final _notificationApi = NotificationApi();

  // Local DB repository instances
  final _userLocal = UserLocal();
  final _courseLocal = CourseLocal();
  final _assignmentLocal = AssignmentLocal();
  final _examLocal = ExamLocal();
  final _submissionLocal = SubmissionLocal();
  final _notificationLocal = NotificationLocal();

  Future<void> syncUserData(String userId) async {
    print("--- STARTING OFFLINE DATA SYNC for user: $userId ---");

    try {
      final db = await AppDb.instance.database;

      await db.transaction((txn) async {
        await _clearAllLocalData(txn);
        print("Cleared old offline data.");

        final userProfile = await _userApi.readById(userId);
        if (userProfile == null) {
          throw Exception("Cannot sync: User not found in Firebase.");
        }
        await _userLocal.create(userProfile, txn: txn);
        print("Synced user profile: ${userProfile.fullName}");

        if (userProfile.enrolledCourses.isNotEmpty) {
          // --- THIS METHOD CALL IS NOW MORE ROBUST ---
          await _syncAllCourseData(userProfile, txn);
        } else {
          print("User has no enrolled courses to sync.");
        }

        // This part is also fine.
        final notifications = await _notificationApi.readAllForUser(userId);
        await _notificationLocal.upsertMany(userId, notifications, txn: txn);
        print("Synced ${notifications.length} notifications.");
      });

      print("--- OFFLINE DATA SYNC COMPLETE ---");

    } catch (e) {
      print("--- OFFLINE DATA SYNC FAILED: $e ---");
    }
  }
  Future<void> _syncAllCourseData(user userProfile, DatabaseExecutor txn) async {
    final allCourses = await _courseApi.readAll();
    final enrolledCourses = allCourses.where((c) => userProfile.enrolledCourses.contains(c.id)).toList();

    if (enrolledCourses.isEmpty) return;

    await _courseLocal.upsertMany(enrolledCourses, txn: txn);
    print("Synced details for ${enrolledCourses.length} courses.");

    for (final course in enrolledCourses) {
      final courseId = course.id!;
      final courseTitle = course.title;

      try {
        print("--> Syncing tasks for course: '$courseTitle' ($courseId)");
        final allTasks = await _taskApi.getAllTasksForCourse(courseId, userProfile.id.toString());

        final assignments = allTasks.where((t) => t.type == TaskType.assignment).map((t) => t.asAssignment).toList();
        final exams = allTasks.where((t) => t.type == TaskType.exam).map((t) => t.asExam).toList();

        if (assignments.isNotEmpty) {
          await _assignmentLocal.upsertMany(courseId, assignments, txn: txn);
        }
        if (exams.isNotEmpty) {
          await _examLocal.upsertMany(courseId, exams, txn: txn);
        }

        for (final task in allTasks) {
          if (task.userSubmission != null) {
            final type = task.type == TaskType.assignment ? 'assignments' : 'exams';
            await _submissionLocal.create(courseId, task.id, type, task.userSubmission!, txn: txn);
          }
        }
        print("--> Successfully synced tasks for '$courseTitle'.");

      } catch (e) {
        print("!!!!!! FAILED to sync tasks for course '$courseTitle' ($courseId). Error: $e. Continuing to next course. !!!!!!");
      }
    }
  }

  Future<void> _clearAllLocalData(DatabaseExecutor txn) async {
    await Future.wait([
      txn.delete('users'),
      txn.delete('courses'),
      txn.delete('assignments'),
      txn.delete('exams'),
      txn.delete('submissions'),
      txn.delete('notifications'),
    ]);
  }
}