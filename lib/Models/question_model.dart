enum QuestionType { trueFalse, multipleChoice }

class Question {
  final String questionText;
  final QuestionType type;
  final int grade;
  final dynamic correctAnswer;
  final List<String>? options;

  Question({
    required this.questionText,
    required this.type,
    required this.grade,
    required this.correctAnswer,
    this.options,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    QuestionType questionType;
    if (map['type'] == 'true_false') {
      questionType = QuestionType.trueFalse;
    } else if (map['type'] == 'multiple_choice') {
      questionType = QuestionType.multipleChoice;
    } else {
      throw ArgumentError('Unknown question type: ${map['type']}');
    }

    List<String>? questionOptions;
    if (map['options'] != null) {
      questionOptions = List<String>.from(map['options']);
    }

    return Question(
      questionText: map['questionText'] ?? '',
      type: questionType,
      grade: (map['grade'] as num?)?.toInt() ?? 0,
      correctAnswer: map['correctAnswer'],
      options: questionOptions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'type': type == QuestionType.trueFalse ? 'true_false' : 'multiple_choice',
      'grade': grade,
      'correctAnswer': correctAnswer,
      'options': options,
    };
  }
}