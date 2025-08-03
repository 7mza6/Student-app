class Submission {
  final String studentId;
  final String courseId;
  final String taskId;
  final String type;
  final String content;
  final DateTime submittedAt;

  Submission({
    required this.studentId,
    required this.courseId,
    required this.taskId,
    required this.type,
    required this.content,
    required this.submittedAt,
  });

  factory Submission.fromMap(Map<String, dynamic> map) {
    return Submission(
      studentId: map['studentId'],
      courseId: map['courseId'],
      taskId: map['taskId'],
      type: map['type'],
      content: map['content'],
      submittedAt: DateTime.parse(map['submittedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'courseId': courseId,
      'taskId': taskId,
      'type': type,
      'content': content,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }
}