

class Submission {
  final String? id;
  final String studentId;
  final String content;
  final DateTime submittedAt;
  final double? grade;
  final Map<String, dynamic>? answers;

  Submission({
    this.id,
    required this.studentId,
    required this.content,
    required this.submittedAt,
    this.grade,
    this.answers

  });

  factory Submission.fromMap(Map<String, dynamic> map, String id) {
    return Submission(
      id: id,
      studentId: map['studentId'] as String,
      content: map['content'] as String,
      submittedAt: DateTime.parse(map['submittedAt'] as String),
      grade: (map['grade'] as num?)?.toDouble(),
      answers: map['answers'] != null ? Map<String, dynamic>.from(map['answers']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'content': content,
      'submittedAt': submittedAt.toIso8601String(),
      'grade': grade,
      'answers':answers,

    };
  }
}



