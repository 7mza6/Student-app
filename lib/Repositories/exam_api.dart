import 'package:firebase_database/firebase_database.dart';
import '../Models/exam_model.dart';

class ExamApi {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<List<Exam>> readAllForCourse(String courseId) async {
    final ref = _database.ref('courses/$courseId/exams');
    final List<Exam> exams = [];
    try {
      final snapshot = await ref.get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        data.forEach((id, examData) {
          final map = Map<String, dynamic>.from(examData);
          exams.add(Exam.fromMap(map, id));
        });
      }
    } catch (e) {
      print('Error reading exams for course $courseId: $e');
    }
    return exams;
  }
}