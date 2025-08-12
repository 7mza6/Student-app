import '../../Models/question_model.dart';

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
    try {
      if (startTime.isEmpty || !startTime.contains(':')) {
        return date;
      }
      final timeParts = startTime.split(':');
      final hours = int.parse(timeParts[0]);
      final minutes = int.parse(timeParts[1]);
      return date.add(Duration(hours: hours, minutes: minutes));
    } catch (e) {
      print("Error parsing startDateTime for exam '$title': $e. Defaulting to date.");
      return date;
    }
  }

  DateTime get endDateTime {
    try {
      if (endTime.isEmpty || !endTime.contains(':')) {
        return startDateTime.add(const Duration(hours: 1));
      }
      final timeParts = endTime.split(':');
      final hours = int.parse(timeParts[0]);
      final minutes = int.parse(timeParts[1]);
      return date.add(Duration(hours: hours, minutes: minutes));
    } catch (e) {
      print("Error parsing endDateTime for exam '$title': $e. Defaulting to safe value.");
      return startDateTime.add(const Duration(hours: 1)); // Fallback
    }
  }

  factory Exam.fromMap(Map<String, dynamic> data, String id) {
    List<Question> parsedQuestions = [];
    if (data['questions'] != null) {
      final questionsList = data['questions'] as List<dynamic>;
      parsedQuestions = questionsList.map((q) => Question.fromMap(Map<String, dynamic>.from(q))).toList();
    }

    return Exam(
      id: id,
      title: data['title'] ?? 'Untitled Exam',
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

  Exam copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? startTime,


    String? endTime,
    List<Question>? questions,
  }) {
    return Exam(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      questions: questions ?? this.questions,
    );
  }
}