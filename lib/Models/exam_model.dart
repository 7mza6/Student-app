import 'question_model.dart';

class Exam {
  final String id;
  final String title;
  final DateTime date;
  final String startTime;
  final String endTime;
  final List<Question> questions;

  Exam({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.questions,
  });

  DateTime get startDateTime {
    final timeParts = startTime.split(':');
    return date.add(Duration(
        hours: int.parse(timeParts[0]), minutes: int.parse(timeParts[1])));
  }

  DateTime get endDateTime {
    final timeParts = endTime.split(':');
    return date.add(Duration(
        hours: int.parse(timeParts[0]), minutes: int.parse(timeParts[1])));
  }

  factory Exam.fromMap(Map<String, dynamic> data, String id) {
    List<Question> parsedQuestions = [];
    if (data['questions'] != null) {
      final questionsList = data['questions'] as List<dynamic>;
      parsedQuestions = questionsList
          .map((q) => Question.fromMap(Map<String, dynamic>.from(q)))
          .toList();
    }

    return Exam(
      id: id,
      title: data['title'] ?? '',
      date: DateTime.parse(data['date'] as String),
      startTime: data['startTime'] ?? '00:00',
      endTime: data['endTime'] ?? '23:59',
      questions: parsedQuestions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }

  Exam copyWith(
      {String? id,
      String? title,
      DateTime? date,
      String? startTime,
      String? endTime,
      List<Question>? questions}) {
    return Exam(
      id: this.id,
      title: this.title,
      date: this.date,
      startTime: this.startTime,
      endTime: this.endTime,
      questions: this.questions,
    );
  }
}
