
class UpcomingEventModel {
  final String title;
  final String courseTitle;
  final DateTime eventDate;
  final String eventTime;
  final bool isOnline = true;
  final String location;

  final bool isExam;
  final DateTime? startTime;
  final DateTime? endTime;

  UpcomingEventModel({
    required this.title,
    required this.courseTitle,
    required this.eventDate,
    required this.eventTime,
    required this.location,
    required this.isExam,
    this.startTime,
    this.endTime,
  });
}