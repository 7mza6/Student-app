
class DashboardStatsViewModel {
  final int coursesEnrolledCount;
  final int pendingAssignmentsCount;
  final DateTime? nextUpcomingQuizDate;
  final double overallProgress;

  DashboardStatsViewModel({
    required this.coursesEnrolledCount,
    required this.pendingAssignmentsCount,
    this.nextUpcomingQuizDate,
    required this.overallProgress,
  });
}