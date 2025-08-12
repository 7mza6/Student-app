

import 'package:intl/intl.dart';
import 'package:users/tasks/Viewmodels/task_view_model.dart';

import '../../Models/dashboard_stats_model.dart';
import '../../exams/models/exam_model.dart';
import '../../tasks/models/upcoming_event_model.dart';
import '../../auth/models/userModel.dart';
import '../Models/Course-model.dart';

import 'Courses-Model.dart';

Future<DashboardStatsViewModel> fetchDashboardStats() async {
  final currentUser = CurrentUser.getcurrentUser();
  if (currentUser == null || currentUser.id == null) {
    // Return a default empty state
    return DashboardStatsViewModel(
      coursesEnrolledCount: 0, pendingAssignmentsCount: 0, overallProgress: 0.0,
    );
  }

  // This function is now offline-aware
  final enrolledCourses = await fetchEnrolledCourses();
  final coursesEnrolledCount = enrolledCourses.length;

  double totalProgress = enrolledCourses.fold(0.0, (sum, course) => sum + course.progress);
  final overallProgress = coursesEnrolledCount > 0 ? totalProgress / coursesEnrolledCount : 0.0;

  int pendingAssignmentsCount = 0;
  DateTime? nextUpcomingQuizDate;
  final now = DateTime.now();

  for (final course in enrolledCourses) {
    // This function is now offline-aware
    final tasks = await fetchTasksAndSubmissions(
      courseId: course.id!,
      studentId: currentUser.id!.toString(),
    );

    pendingAssignmentsCount += tasks['assignments']!.where((t) => t.submission == null && now.isBefore(t.dueDate)).length;

    final upcomingQuizzes = tasks['exams']!
        .where((t) => now.isBefore((t.task as Exam).startDateTime))
        .map((t) => (t.task as Exam).startDateTime)
        .toList();

    if (upcomingQuizzes.isNotEmpty) {
      upcomingQuizzes.sort();
      if (nextUpcomingQuizDate == null || upcomingQuizzes.first.isBefore(nextUpcomingQuizDate!)) {
        nextUpcomingQuizDate = upcomingQuizzes.first;
      }
    }
  }

  return DashboardStatsViewModel(
    coursesEnrolledCount: coursesEnrolledCount,
    pendingAssignmentsCount: pendingAssignmentsCount,
    overallProgress: overallProgress,
    nextUpcomingQuizDate: nextUpcomingQuizDate,
  );
}

Future<List<UpcomingEventModel>> fetchUpcomingEvents() async {
  final currentUser = CurrentUser.getcurrentUser();
  if (currentUser == null) return [];

  final upcomingEvents = <UpcomingEventModel>[];
  final now = DateTime.now();
  final enrolledCourses = await fetchEnrolledCourses(); // Offline-aware

  for (final course in enrolledCourses) {
    // Offline-aware
    final tasks = await fetchTasksAndSubmissions(
      courseId: course.id!,
      studentId: currentUser.id!.toString(),
    );

    for (final at in tasks['assignments']!) {
      if (at.submission == null && now.isBefore(at.dueDate)) {
        upcomingEvents.add(UpcomingEventModel(
          title: at.title, courseTitle: course.title, eventDate: at.dueDate,
          eventTime: DateFormat.jm().format(at.dueDate), location: 'Online', isExam: false,
        ));
      }
    }

    for (final et in tasks['exams']!) {
      final exam = et.task as Exam;
      if (et.submission == null && now.isBefore(exam.endDateTime)) {
        upcomingEvents.add(UpcomingEventModel(
          title: exam.title, courseTitle: course.title, eventDate: exam.startDateTime,
          eventTime: "${DateFormat.jm().format(exam.startDateTime)} - ${DateFormat.jm().format(exam.endDateTime)}",
          location: 'Campus Location', isExam: true, startTime: exam.startDateTime, endTime: exam.endDateTime,
        ));
      }
    }
  }

  upcomingEvents.sort((a, b) => a.eventDate.compareTo(b.eventDate));
  return upcomingEvents.take(5).toList();
}