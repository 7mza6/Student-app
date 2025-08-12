import 'package:firebase_database/firebase_database.dart';
import '../models/assignment_model.dart';


class AssignmentApi {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<List<Assignment>> readAllForCourse(String courseId) async {
    final ref = _database.ref('courses/$courseId/assignments');
    final List<Assignment> assignments = [];
    try {
      final snapshot = await ref.get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        data.forEach((id, assignmentData) {
          final map = Map<String, dynamic>.from(assignmentData);
          assignments.add(Assignment.fromMap(map, id));
        });
      }
    } catch (e) {
      print('Error reading assignments for course $courseId: $e');
    }
    return assignments;
  }
}