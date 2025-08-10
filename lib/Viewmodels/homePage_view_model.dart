

import 'package:intl/intl.dart';
import 'package:users/Viewmodels/task_view_model.dart';

import '../Models/Course-model.dart';
import '../Models/dashboard_stats_model.dart';
import '../Models/exam_model.dart';
import '../Models/upcoming_event_model.dart';
import '../auth/models/userModel.dart';
import 'Courses-Model.dart';

Future<DashboardStatsViewModel> fetchDashboardStats() async {
  final currentUser = CurrentUser.getcurrentUser();
  if (currentUser == null || currentUser.id == null) {
    return DashboardStatsViewModel(
      coursesEnrolledCount: 0,
      pendingAssignmentsCount: 0,
      overallProgress: 0.0,
      nextUpcomingQuizDate: null,
    );
  }

  final List<Course> enrolledCourses = await fetchEnrolledCourses();
  final int coursesEnrolledCount = enrolledCourses.length;
  double totalProgress = 0;
  for (final course in enrolledCourses) {
    totalProgress += course.progress;
  }
  final double overallProgress = coursesEnrolledCount > 0 ? totalProgress / coursesEnrolledCount : 0.0;

  int pendingAssignmentsCount = 0;
  final List<Exam> allUpcomingQuizzes = [];
  final now = DateTime.now();

  for (final course in enrolledCourses) {
    final tasks = await fetchTasksAndSubmissions(
      courseId: course.id!,
      studentId: currentUser.id!.toString(),
    );

    for (final assignmentTask in tasks['assignments']!) {
      if (assignmentTask.submission == null && now.isBefore(assignmentTask.dueDate)) {
        pendingAssignmentsCount++;
      }
    }

    for (final examTask in tasks['exams']!) {
      final exam = examTask.task as Exam;
      if (now.isBefore(exam.startDateTime)) {
        allUpcomingQuizzes.add(exam);
      }
    }
  }

  DateTime? nextUpcomingQuizDate;
  if (allUpcomingQuizzes.isNotEmpty) {
    allUpcomingQuizzes.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    nextUpcomingQuizDate = allUpcomingQuizzes.first.startDateTime;
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
  if (currentUser == null || currentUser.id == null) return [];

  final List<UpcomingEventModel> upcomingEvents = [];
  final now = DateTime.now();

  final List<Course> enrolledCourses = await fetchEnrolledCourses();

  for (final course in enrolledCourses) {
    final tasksForCourse = await fetchTasksAndSubmissions(
      courseId: course.id!,
      studentId: currentUser.id!.toString(),
    );

    for (final assignmentTask in tasksForCourse['assignments']!) {
      if (assignmentTask.submission == null && now.isBefore(assignmentTask.dueDate)) {
        upcomingEvents.add(
          UpcomingEventModel(
            title: assignmentTask.title,
            courseTitle: course.title,
            eventDate: assignmentTask.dueDate,
            eventTime: DateFormat.jm().format(assignmentTask.dueDate),
            location: 'Online',
            isExam: false,
          ),
        );
      }
    }

    // Process exams
    for (final examTask in tasksForCourse['exams']!) {
      final exam = examTask.task as Exam;
      if (examTask.submission == null && now.isBefore(exam.endDateTime)) { // Use endDateTime for filtering
        upcomingEvents.add(
          UpcomingEventModel(
            title: exam.title,
            courseTitle: course.title,
            eventDate: exam.startDateTime, // The main event date is the start time
            eventTime: "${DateFormat.jm().format(exam.startDateTime)} - ${DateFormat.jm().format(exam.endDateTime)}",
            location: 'Campus Location',
            isExam: true, // This is an exam
            startTime: exam.startDateTime, // Pass the specific start time
            endTime: exam.endDateTime,   // Pass the specific end time
          ),
        );
      }
    }
  }

  upcomingEvents.sort((a, b) => a.eventDate.compareTo(b.eventDate));
  return upcomingEvents.take(5).toList();
}